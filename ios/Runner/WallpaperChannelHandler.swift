import AVFoundation
import Flutter
import ImageIO
import Photos
import UIKit

/// iOS half of `com.livecanvas/wallpaper`.
///
/// Apple exposes no public API for setting a video wallpaper, so the app's job
/// ends at putting something into the Photos library that iOS itself accepts as
/// an animated wallpaper — and the only such thing is a **Live Photo**. A plain
/// `.mp4` cannot be used: the system wallpaper picker and the Shortcuts
/// "Set Wallpaper Photo" action both take a photo, never a video.
///
/// So the video is paired into a Live Photo (still + paired video sharing one
/// content identifier) before it is saved. If that pairing fails for any
/// reason, the plain video is saved instead — a library the user can still work
/// with beats an error.
final class WallpaperChannelHandler {

    static let channelName = "com.livecanvas/wallpaper"

    private enum Method {
        static let setLiveWallpaper = "setLiveWallpaper"
        static let saveVideoToPhotos = "saveVideoToPhotos"
        static let isLiveWallpaperSupported = "isLiveWallpaperSupported"
        static let openPhotos = "openPhotos"
    }

    /// Contract with the Dart side, which is the only place these become an
    /// AppFailure (see contracts/method-channel.md).
    private enum ErrorCode {
        static let unsupported = "UNSUPPORTED"
        static let fileMissing = "FILE_MISSING"
        static let permissionDenied = "PERMISSION_DENIED"
        static let saveFailed = "SAVE_FAILED"
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case Method.isLiveWallpaperSupported:
            // Always false on iOS — and this is a capability answer, not a
            // platform answer; the Dart side picks its UI branch elsewhere.
            result(false)

        case Method.setLiveWallpaper:
            result(
                FlutterError(
                    code: ErrorCode.unsupported,
                    message: "Android only",
                    details: nil
                )
            )

        case Method.saveVideoToPhotos:
            saveVideoToPhotos(call, result: result)

        case Method.openPhotos:
            openPhotos(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Asks only for permission to ADD to the library — the app writes one
    /// video and never reads, so requesting full access would over-reach and
    /// show the user a scarier prompt.
    ///
    /// The add-only scope arrived in iOS 14; the project still targets 13, so
    /// older systems fall back to the single combined permission.
    private func requestAddOnlyAuthorization(
        _ completion: @escaping (Bool) -> Void
    ) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                completion(status == .authorized || status == .limited)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized)
            }
        }
    }

    /// Opens the Photos app, where the Live Photo just landed and where the
    /// wallpaper is actually set from.
    ///
    /// Reported as `opened: false` rather than an error — a scheme that will
    /// not open is not a failure the user can act on, it just needs different
    /// wording (FR-022).
    private func openPhotos(result: @escaping FlutterResult) {
        // `photos-redirect` is the scheme that survives across iOS versions;
        // `photos` is kept as a fallback rather than assumed.
        let candidates = ["photos-redirect://", "photos://"]
            .compactMap(URL.init(string:))
            .filter { UIApplication.shared.canOpenURL($0) }

        guard let url = candidates.first else {
            result(["opened": false])
            return
        }
        UIApplication.shared.open(url, options: [:]) { opened in
            result(["opened": opened])
        }
    }

    private func saveVideoToPhotos(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard
            let args = call.arguments as? [String: Any],
            let path = args["filePath"] as? String,
            FileManager.default.fileExists(atPath: path)
        else {
            result(
                FlutterError(
                    code: ErrorCode.fileMissing,
                    message: "video file not found",
                    details: nil
                )
            )
            return
        }

        requestAddOnlyAuthorization { granted in
            guard granted else {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: ErrorCode.permissionDenied,
                            message: "photo library access denied",
                            details: nil
                        )
                    )
                }
                return
            }

            let source = URL(fileURLWithPath: path)
            LivePhotoExporter.export(videoAt: source) { pair in
                self.saveToLibrary(pair: pair, fallbackVideo: source, result: result)
            }
        }
    }

    /// Writes the Live Photo pair, or the bare video when the pairing failed.
    private func saveToLibrary(
        pair: LivePhotoExporter.Pair?,
        fallbackVideo: URL,
        result: @escaping FlutterResult
    ) {
        PHPhotoLibrary.shared().performChanges {
            guard let pair else {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(
                    atFileURL: fallbackVideo
                )
                return
            }

            let request = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            // The temporary pair is ours alone; letting Photos move it saves
            // copying a few hundred MB for a 4K master.
            options.shouldMoveFile = true
            request.addResource(with: .photo, fileURL: pair.still, options: options)
            request.addResource(
                with: .pairedVideo,
                fileURL: pair.video,
                options: options
            )
        } completionHandler: { success, error in
            if let pair {
                LivePhotoExporter.discard(pair)
            }
            DispatchQueue.main.async {
                if success {
                    result(["saved": true])
                } else {
                    result(
                        FlutterError(
                            code: ErrorCode.saveFailed,
                            message: error?.localizedDescription
                                ?? "could not save the video",
                            details: nil
                        )
                    )
                }
            }
        }
    }
}

/// Builds the (still, paired video) pair that Photos accepts as a Live Photo.
///
/// The pairing is pure metadata, and BOTH halves are required:
///  - the same content identifier in the still's Apple maker note and in the
///    movie's asset-level metadata — this is what makes them one asset;
///  - a `still-image-time` timed-metadata track in the movie, marking the frame
///    the still came from.
///
/// Miss either and Photos silently imports two ordinary, unrelated assets —
/// which is exactly the failure the user sees as "it saved but I still can't
/// set it as wallpaper".
enum LivePhotoExporter {

    struct Pair {
        let still: URL
        let video: URL
    }

    private static let contentIdentifierKey = "com.apple.quicktime.content.identifier"
    private static let stillImageTimeKey = "com.apple.quicktime.still-image-time"
    private static let logTag = "LivePhotoExporter"

    /// How much of the master ends up in the paired video.
    ///
    /// A Live Photo the camera produces is ~3 seconds, and that is the shape
    /// the system is built around — handing it a 26-second movie is outside
    /// anything iOS ever has to render.
    private static let pairedDuration = CMTime(seconds: 3, preferredTimescale: 600)

    /// Longest side of the paired video. Kept well under the 4096 that many
    /// hardware decoders stop at, and far under it there is nothing to gain:
    /// the tallest iPhone screen is under 2800px.
    private static let maxPairedSide: CGFloat = 2048

    /// Returns nil on any failure: the caller falls back to the plain video
    /// rather than turning a cosmetic problem into a dead end.
    static func export(videoAt source: URL, completion: @escaping (Pair?) -> Void) {
        let identifier = UUID().uuidString
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("livephoto-\(identifier)", isDirectory: true)

        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            let asset = AVURLAsset(url: source)
            let poster = try posterFrame(of: asset)
            let still = try writeStill(
                poster.image,
                identifier: identifier,
                into: directory
            )
            writePairedVideo(
                from: asset,
                identifier: identifier,
                stillTime: poster.time,
                into: directory
            ) { video in
                guard let video else {
                    try? FileManager.default.removeItem(at: directory)
                    completion(nil)
                    return
                }
                completion(Pair(still: still, video: video))
            }
        } catch {
            NSLog("\(logTag): could not build the pair - \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: directory)
            completion(nil)
        }
    }

    /// Drops the working directory. Safe after a save with `shouldMoveFile`:
    /// the files are already gone, only the empty directory is left.
    static func discard(_ pair: Pair) {
        try? FileManager.default.removeItem(at: pair.still.deletingLastPathComponent())
    }

    /// Picks the frame the Live Photo shows when it is not playing.
    ///
    /// NOT frame zero: a great many of these clips open on a black fade-in, and
    /// frame zero is then a black rectangle — which is all the user sees in
    /// Photos and in the wallpaper picker, since the still is what shows until
    /// you touch and hold. So a few frames spread over the clip are sampled and
    /// the first one that is not near-black wins.
    ///
    /// Returns the frame's ACTUAL time, which the `still-image-time` marker
    /// then has to match — a still taken at 2s with a marker at 0s makes Photos
    /// treat the pair as unrelated files.
    private static func posterFrame(
        of asset: AVURLAsset
    ) throws -> (image: CGImage, time: CMTime) {
        let generator = AVAssetImageGenerator(asset: asset)
        // Portrait masters carry their orientation in the track transform;
        // without this the still lands sideways next to an upright video.
        generator.appliesPreferredTrackTransform = true
        // The default tolerance is INFINITE, which lets the generator answer
        // every request with the nearest keyframe — in practice frame zero for
        // all of them, so the sampling below would compare one frame to itself.
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        let duration = asset.duration
        let fractions: [Double] =
            duration.isValid && duration.seconds > 0.5
            ? [0.10, 0.25, 0.50, 0.75, 0.0]
            : [0.0]

        var fallback: (image: CGImage, time: CMTime)?
        for fraction in fractions {
            let requested = CMTime(
                seconds: duration.seconds * fraction,
                preferredTimescale: 600
            )
            var actual = CMTime.zero
            guard
                let image = try? generator.copyCGImage(
                    at: requested,
                    actualTime: &actual
                )
            else { continue }

            if !isNearlyBlack(image) { return (image, actual) }
            if fallback == nil { fallback = (image, actual) }
        }

        // Everything sampled was dark — the clip may genuinely be a night
        // scene, so ship the first frame rather than failing the whole save.
        guard let fallback else { throw ExportError.stillNotWritten }
        return fallback
    }

    /// Averages the frame down to 8x8 and looks at the mean channel value.
    ///
    /// Deliberately crude: this only has to tell "fade-in black" from "an
    /// actual picture", and a dark-but-real night shot must survive it.
    private static func isNearlyBlack(_ image: CGImage) -> Bool {
        let side = 8
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        guard
            let context = CGContext(
                data: &pixels,
                width: side,
                height: side,
                bitsPerComponent: 8,
                bytesPerRow: side * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            return false
        }
        context.draw(
            image,
            in: CGRect(x: 0, y: 0, width: side, height: side)
        )

        var total = 0
        for index in stride(from: 0, to: pixels.count, by: 4) {
            total += Int(pixels[index]) + Int(pixels[index + 1])
                + Int(pixels[index + 2])
        }
        let mean = Double(total) / Double(side * side * 3)
        return mean < 12.0  // ~5% of full scale
    }

    /// Writes the poster frame, carrying the identifier in the Apple maker note.
    private static func writeStill(
        _ image: CGImage,
        identifier: String,
        into directory: URL
    ) throws -> URL {
        let url = directory.appendingPathComponent("still.jpg")
        guard
            let destination = CGImageDestinationCreateWithURL(
                url as CFURL,
                "public.jpeg" as CFString,
                1,
                nil
            )
        else {
            throw ExportError.stillNotWritten
        }

        // "17" is the maker-note key Photos reads the asset identifier from.
        let properties: [String: Any] = [
            kCGImagePropertyMakerAppleDictionary as String: ["17": identifier],
            kCGImageDestinationLossyCompressionQuality as String: 0.9,
        ]
        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw ExportError.stillNotWritten
        }
        return url
    }

    private static func writePairedVideo(
        from asset: AVURLAsset,
        identifier: String,
        stillTime: CMTime,
        into directory: URL,
        completion: @escaping (URL?) -> Void
    ) {
        let url = directory.appendingPathComponent("paired.mov")

        do {
            guard let track = asset.tracks(withMediaType: .video).first else {
                throw ExportError.noVideoTrack
            }

            // The clip runs from the poster frame, so the still is the first
            // thing shown and the marker sits inside the range that was kept.
            let range = CMTimeRange(
                start: stillTime,
                duration: CMTimeMinimum(
                    pairedDuration,
                    CMTimeSubtract(asset.duration, stillTime)
                )
            )

            let reader = try AVAssetReader(asset: asset)
            reader.timeRange = range

            let output = AVAssetReaderTrackOutput(
                track: track,
                outputSettings: [
                    kCVPixelBufferPixelFormatTypeKey as String:
                        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                ]
            )
            guard reader.canAdd(output) else { throw ExportError.readerRejected }
            reader.add(output)

            let writer = try AVAssetWriter(outputURL: url, fileType: .mov)
            writer.metadata = [contentIdentifierItem(identifier)]

            // Sized in the track's OWN orientation and rotated by the transform
            // below, exactly as passthrough did — measuring the rotated size
            // here and also keeping the transform would rotate it twice.
            let target = scaledSize(of: track.naturalSize)
            let videoInput = AVAssetWriterInput(
                mediaType: .video,
                outputSettings: [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: Int(target.width),
                    AVVideoHeightKey: Int(target.height),
                ]
            )
            videoInput.expectsMediaDataInRealTime = false
            videoInput.transform = track.preferredTransform
            guard writer.canAdd(videoInput) else { throw ExportError.writerRejected }
            writer.add(videoInput)

            let metadataInput = AVAssetWriterInput(
                mediaType: .metadata,
                outputSettings: nil,
                sourceFormatHint: try stillImageTimeFormat()
            )
            let adaptor = AVAssetWriterInputMetadataAdaptor(
                assetWriterInput: metadataInput
            )
            guard writer.canAdd(metadataInput) else { throw ExportError.writerRejected }
            writer.add(metadataInput)

            guard reader.startReading(), writer.startWriting() else {
                throw ExportError.writerRejected
            }
            // Sample timestamps stay on the SOURCE timeline even when the
            // reader is trimmed, so the session has to start where the trim
            // does — starting at zero would prepend seconds of nothing.
            writer.startSession(atSourceTime: range.start)

            // Placed at the frame the still was actually taken from: this
            // marker is how Photos knows which frame the poster is.
            try adaptor.append(
                AVTimedMetadataGroup(
                    items: [stillImageTimeItem()],
                    timeRange: CMTimeRange(
                        start: stillTime,
                        duration: CMTime(value: 1, timescale: 30)
                    )
                )
            )
            metadataInput.markAsFinished()

            let queue = DispatchQueue(label: "com.livecanvas.livephoto")
            videoInput.requestMediaDataWhenReady(on: queue) {
                while videoInput.isReadyForMoreMediaData {
                    guard
                        reader.status == .reading,
                        let buffer = output.copyNextSampleBuffer()
                    else {
                        videoInput.markAsFinished()
                        let readCompleted = reader.status == .completed
                        writer.finishWriting {
                            let ok = readCompleted && writer.status == .completed
                            if !ok {
                                NSLog(
                                    "\(logTag): writer=\(writer.status.rawValue) "
                                        + "reader=\(reader.status.rawValue)"
                                )
                            }
                            completion(ok ? url : nil)
                        }
                        return
                    }
                    videoInput.append(buffer)
                }
            }
        } catch {
            NSLog("\(logTag): could not write the paired video - \(error)")
            completion(nil)
        }
    }

    /// Caps the longest side at [maxPairedSide], keeping the aspect ratio and
    /// landing on even numbers — H.264 cannot encode odd dimensions in 4:2:0.
    private static func scaledSize(of size: CGSize) -> CGSize {
        let longest = max(size.width, size.height)
        let scale = longest > maxPairedSide ? maxPairedSide / longest : 1
        func even(_ value: CGFloat) -> CGFloat {
            max(2, (value * scale / 2).rounded() * 2)
        }
        return CGSize(width: even(size.width), height: even(size.height))
    }

    private static func contentIdentifierItem(_ identifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = contentIdentifierKey as NSString
        item.keySpace = .quickTimeMetadata
        item.value = identifier as NSString
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }

    private static func stillImageTimeItem() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = stillImageTimeKey as NSString
        item.keySpace = .quickTimeMetadata
        item.value = 0 as NSNumber
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }

    private static func stillImageTimeFormat() throws -> CMFormatDescription {
        let specification: [String: Any] = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as String:
                "mdta/\(stillImageTimeKey)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as String:
                "com.apple.metadata.datatype.int8",
        ]
        var description: CMFormatDescription?
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(
            allocator: kCFAllocatorDefault,
            metadataType: kCMMetadataFormatType_Boxed,
            metadataSpecifications: [specification] as CFArray,
            formatDescriptionOut: &description
        )
        guard let description else { throw ExportError.metadataTrackFailed }
        return description
    }

    private enum ExportError: Error {
        case stillNotWritten
        case noVideoTrack
        case readerRejected
        case writerRejected
        case metadataTrackFailed
    }
}

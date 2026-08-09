import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/constants/channel_methods.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart';

const _file = WallpaperFile(
  wallpaperId: 101,
  path: '/tmp/wallpapers/101.mp4',
  sizeBytes: 1024,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(WallpaperChannel.name);
  late WallpaperPlatformService service;
  late List<MethodCall> calls;

  void mockChannel(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          calls.add(call);
          return handler(call);
        });
  }

  void mockThrows(String code) =>
      mockChannel((_) async => throw PlatformException(code: code));

  setUp(() {
    calls = [];
    service = WallpaperPlatformServiceImpl.withChannel(channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('setLiveWallpaper', () {
    test(
      'passes primitives only across the boundary (Principle VIII)',
      () async {
        mockChannel((_) async => {'applied': true});

        await service.setLiveWallpaper(_file);

        expect(calls.single.method, WallpaperChannel.setLiveWallpaper);
        expect(calls.single.arguments, {
          'filePath': '/tmp/wallpapers/101.mp4',
          'wallpaperId': 101,
        });
      },
    );

    test('applied=true is Ok(true)', () async {
      mockChannel((_) async => {'applied': true});

      expect((await service.setLiveWallpaper(_file) as Ok<bool>).value, isTrue);
    });

    test(
      'applied=false is Ok(false), NOT an error — backing out of the system '
      'preview is a normal action (FR-016, INV-7)',
      () async {
        mockChannel((_) async => {'applied': false});

        final result = await service.setLiveWallpaper(_file);

        expect(result, isA<Ok<bool>>());
        expect((result as Ok<bool>).value, isFalse);
      },
    );
  });

  group('native error codes map to AppFailure (and nothing leaks)', () {
    test('UNSUPPORTED', () async {
      mockThrows(WallpaperChannelError.unsupported);
      final result = await service.setLiveWallpaper(_file);
      expect(
        (result as Err<bool>).failure,
        isA<PlatformUnsupportedFailure>(),
      );
    });

    test('FILE_MISSING', () async {
      mockThrows(WallpaperChannelError.fileMissing);
      final result = await service.setLiveWallpaper(_file);
      expect((result as Err<bool>).failure, isA<FileWriteFailedFailure>());
    });

    test('PERMISSION_DENIED', () async {
      mockThrows(WallpaperChannelError.permissionDenied);
      final result = await service.saveVideoToPhotos(_file);
      expect((result as Err<bool>).failure, isA<FileWriteFailedFailure>());
    });

    test('SET_FAILED', () async {
      mockThrows(WallpaperChannelError.setFailed);
      final result = await service.setLiveWallpaper(_file);
      expect((result as Err<bool>).failure, isA<WallpaperSetFailedFailure>());
    });

    test('SAVE_FAILED', () async {
      mockThrows(WallpaperChannelError.saveFailed);
      final result = await service.saveVideoToPhotos(_file);
      expect((result as Err<bool>).failure, isA<WallpaperSetFailedFailure>());
    });

    test('an unknown code never escapes as a PlatformException', () async {
      mockThrows('SOMETHING_NEW');

      final result = await service.setLiveWallpaper(_file);

      expect((result as Err<bool>).failure, isA<UnknownFailure>());
    });
  });

  group('saveVideoToPhotos', () {
    test('sends only the file path', () async {
      mockChannel((_) async => {'saved': true});

      await service.saveVideoToPhotos(_file);

      expect(calls.single.method, WallpaperChannel.saveVideoToPhotos);
      expect(calls.single.arguments, {'filePath': '/tmp/wallpapers/101.mp4'});
    });
  });

  group('openShortcuts', () {
    test('reports what native opened', () async {
      mockChannel((_) async => {'opened': true});

      expect(await service.openShortcuts(), isTrue);
      expect(calls.single.method, WallpaperChannel.openShortcuts);
    });

    test(
      'a missing Shortcuts app is false, not an error — the user has not hit '
      'a failure, they just need different wording (FR-022)',
      () async {
        mockChannel((_) async => {'opened': false});

        expect(await service.openShortcuts(), isFalse);
      },
    );

    test('UNSUPPORTED (Android) is false rather than a thrown error', () async {
      mockThrows(WallpaperChannelError.unsupported);

      expect(await service.openShortcuts(), isFalse);
    });
  });

  group('isLiveWallpaperSupported', () {
    test('returns what native says', () async {
      mockChannel((_) async => true);

      expect(await service.isLiveWallpaperSupported(), isTrue);
    });

    test('a missing native implementation means "no", not a crash', () async {
      // No mock handler installed at all.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      expect(await service.isLiveWallpaperSupported(), isFalse);
    });
  });
}

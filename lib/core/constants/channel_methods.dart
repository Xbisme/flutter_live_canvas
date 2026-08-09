/// Method-channel names, centralised (Principle VIII) — never hardcode the
/// channel or a method string at a call site.
///
/// One channel per domain: `com.livecanvas/{domain}`. Data crossing the
/// boundary uses primitives only (see `specs/MO-005-*/contracts/method-channel.md`),
/// and native error codes are mapped to `AppFailure` in exactly one place
/// (`WallpaperPlatformService`).
abstract final class WallpaperChannel {
  /// The channel itself.
  static const name = 'com.livecanvas/wallpaper';

  /// Android only: write the video path natively, then open the system
  /// live-wallpaper preview. Returns `{"applied": bool}` — `false` means the
  /// user backed out of the preview, which is NOT an error (FR-016).
  static const setLiveWallpaper = 'setLiveWallpaper';

  /// iOS only: request add-only Photos permission, then save the video as-is
  /// (no Live Photo conversion — FR-019). Returns `{"saved": bool}`.
  static const saveVideoToPhotos = 'saveVideoToPhotos';

  /// Whether this device can set a live wallpaper at all.
  ///
  /// This is a CAPABILITY question, not a platform question: an Android device
  /// with no live-wallpaper picker also returns false. Never use it to choose
  /// the Android/iOS UI branch (use `defaultTargetPlatform` for that) — doing so
  /// would show such a user the iOS Shortcuts guide and make FR-017's
  /// "device not supported" message unreachable.
  static const isLiveWallpaperSupported = 'isLiveWallpaperSupported';

  /// iOS only: opens the system Shortcuts app so the user can finish the flow.
  /// Handled here rather than pulling in `url_launcher` for a single scheme
  /// (Principle XIV) — we already own a native handler on both platforms.
  /// Returns `{"opened": bool}`; false means the app is not installed.
  static const openShortcuts = 'openShortcuts';
}

/// Error codes native raises; mapped to `AppFailure` by
/// `WallpaperPlatformService` and never surfaced to the UI (FR-029).
abstract final class WallpaperChannelError {
  static const unsupported = 'UNSUPPORTED';
  static const fileMissing = 'FILE_MISSING';
  static const permissionDenied = 'PERMISSION_DENIED';
  static const setFailed = 'SET_FAILED';
  static const saveFailed = 'SAVE_FAILED';
}

import 'package:flutter/foundation.dart';

/// The build flavors this app ships with.
///
/// EXACTLY two — adding a value here requires a constitution amendment
/// (Principle XII).
enum AppEnvironment { development, production }

/// Immutable per-flavor configuration — the single source for every
/// environment-dependent value (backend base URL, app key).
///
/// Instantiated once by the flavor entrypoint and registered in DI by
/// `bootstrap`; feature code must read it from `getIt<AppConfig>()`, never
/// import a flavor file directly.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appKey,
  });

  /// Development flavor — points at the locally running backend by default.
  ///
  /// The Android emulator reaches the host machine via 10.0.2.2; everything
  /// else (iOS simulator, desktop) uses localhost. Run with
  /// `--dart-define=USE_MOCK=true` to target the Prism mock server
  /// (`scripts/mock_server.sh`, port 4010) instead — UI dev without the real
  /// backend (MO-002 US4 / FR-014).
  factory AppConfig.development() {
    const useMock = bool.fromEnvironment('USE_MOCK');
    const backendPort = 8000;
    const mockPort = 4010;
    const port = useMock ? mockPort : backendPort;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final host = isAndroid ? '10.0.2.2' : 'localhost';
    return AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://$host:$port',
      // Dev key matches the backend's .env.dev default; committed on
      // purpose (clarified 2026-07-23) — an app key inside a binary is
      // hygiene, not a secret.
      appKey: 'dev-app-key',
    );
  }

  /// Production flavor — real key is injected at build time:
  /// `flutter build ... --dart-define=APP_KEY=<key>`.
  factory AppConfig.production() => const AppConfig(
    environment: AppEnvironment.production,
    // TODO(release): replace with the real production domain before
    // MO-007 store submission.
    apiBaseUrl: 'https://api.livecanvas.example',
    appKey: String.fromEnvironment('APP_KEY'),
  );

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String appKey;
}

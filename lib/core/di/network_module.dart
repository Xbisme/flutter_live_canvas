import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/network/app_key_interceptor.dart';

/// Provides the shared HTTP client, pre-configured from the flavor config.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AppConfig config) => Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      // Explicit, because Dio's default is "wait forever": a backend that
      // accepts the socket and then stalls would leave the UI spinning with no
      // failure to show and no retry to offer. Generous enough for a cold
      // start on mobile data — these bound a JSON call, never a file transfer
      // (that one has its own bare Dio in WallpaperDownloadRepository).
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  )..interceptors.add(AppKeyInterceptor(config.appKey));
}

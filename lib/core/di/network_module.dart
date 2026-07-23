import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/network/app_key_interceptor.dart';

/// Provides the shared HTTP client, pre-configured from the flavor config.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AppConfig config) =>
      Dio(BaseOptions(baseUrl: config.apiBaseUrl))
        ..interceptors.add(AppKeyInterceptor(config.appKey));
}

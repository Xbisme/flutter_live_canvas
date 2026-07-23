import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/di/injection.dart';

void main() {
  group('AppKeyInterceptor', () {
    setUp(() => configureDependencies(AppConfig.development()));

    tearDown(getIt.reset);

    test('DI-provided Dio attaches X-App-Key from the flavor config', () async {
      final dio = getIt<Dio>();
      final config = getIt<AppConfig>();

      expect(dio.options.baseUrl, config.apiBaseUrl);

      // Short-circuit the request right after interceptors run so we can
      // observe the outgoing headers without a real network call.
      dio.httpClientAdapter = _CapturingAdapter();
      final response = await dio.get<dynamic>('/categories');

      expect(
        response.requestOptions.headers['X-App-Key'] as String?,
        config.appKey,
      );
    });
  });
}

class _CapturingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', 200);
  }
}

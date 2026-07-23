import 'package:dio/dio.dart';

/// Attaches the `X-App-Key` header to every outgoing request (FR-005).
///
/// Registered on the shared [Dio] instance in DI — feature code never sets
/// the header itself.
class AppKeyInterceptor extends Interceptor {
  AppKeyInterceptor(this._appKey);

  final String _appKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-App-Key'] = _appKey;
    handler.next(options);
  }
}

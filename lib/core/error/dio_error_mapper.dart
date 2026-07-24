import 'dart:io';

import 'package:dio/dio.dart';
import 'package:livecanvas/core/domain/app_failure.dart';

/// Maps a thrown error (usually a [DioException] from the generated client)
/// to an [AppFailure] (Principle IV / research R5). Repositories call this in
/// their catch blocks so the rest of the app only ever sees `AppFailure`.
AppFailure mapDioError(Object error) {
  if (error is! DioException) {
    return UnknownFailure(message: error.toString(), error: error);
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badCertificate:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return UnknownFailure(message: 'request cancelled', error: error);
    case DioExceptionType.badResponse:
      return _fromStatus(error.response?.statusCode, error);
    case DioExceptionType.unknown:
      if (error.error is SocketException) return const NetworkFailure();
      return UnknownFailure(message: error.message, error: error);
  }
}

AppFailure _fromStatus(int? status, DioException error) {
  switch (status) {
    case 404:
      return const NotFoundFailure();
    case 400:
      return const ValidationFailure();
    case 500:
    case 502:
    case 503:
      return const ServerUnavailableFailure();
    case null:
      return UnknownFailure(message: error.message, error: error);
    default:
      // 401 INVALID_APP_KEY and any other status: a config/unexpected error the
      // user can't act on — surfaced as a generic failure, never raw.
      return UnknownFailure(message: 'HTTP $status', error: error);
  }
}

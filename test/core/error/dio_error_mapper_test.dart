import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/error/dio_error_mapper.dart';

void main() {
  final req = RequestOptions(path: '/wallpapers');

  DioException dio(DioExceptionType type, {int? status, Object? error}) =>
      DioException(
        requestOptions: req,
        type: type,
        error: error,
        response: status == null
            ? null
            : Response<dynamic>(requestOptions: req, statusCode: status),
      );

  group('mapDioError', () {
    test('timeouts → TimeoutFailure', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ]) {
        expect(mapDioError(dio(t)), isA<TimeoutFailure>());
      }
    });

    test('connectionError → NetworkFailure', () {
      expect(
        mapDioError(dio(DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
    });

    test('unknown wrapping SocketException → NetworkFailure', () {
      expect(
        mapDioError(
          dio(DioExceptionType.unknown, error: const SocketException('x')),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('badResponse 404 → NotFoundFailure', () {
      expect(
        mapDioError(dio(DioExceptionType.badResponse, status: 404)),
        isA<NotFoundFailure>(),
      );
    });

    test('badResponse 400 → ValidationFailure', () {
      expect(
        mapDioError(dio(DioExceptionType.badResponse, status: 400)),
        isA<ValidationFailure>(),
      );
    });

    test('badResponse 500/503 → ServerUnavailableFailure', () {
      expect(
        mapDioError(dio(DioExceptionType.badResponse, status: 500)),
        isA<ServerUnavailableFailure>(),
      );
      expect(
        mapDioError(dio(DioExceptionType.badResponse, status: 503)),
        isA<ServerUnavailableFailure>(),
      );
    });

    test('badResponse 401 → UnknownFailure (config error, never raw)', () {
      expect(
        mapDioError(dio(DioExceptionType.badResponse, status: 401)),
        isA<UnknownFailure>(),
      );
    });

    test('non-Dio error → UnknownFailure', () {
      expect(mapDioError(Exception('boom')), isA<UnknownFailure>());
    });
  });
}

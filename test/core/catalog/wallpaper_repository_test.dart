import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockPublicApi extends Mock implements PublicApi {}

Response<T> _resp<T>(T data) => Response<T>(
  requestOptions: RequestOptions(path: '/'),
  data: data,
);

void main() {
  late _MockPublicApi api;
  late WallpaperRepository repo;

  setUp(() {
    api = _MockPublicApi();
    repo = WallpaperRepositoryImpl(api);
  });

  When<Future<Response<WallpaperCursorPage>>> whenList() => when(
    () => api.wallpapersGet(
      cursor: any(named: 'cursor'),
      limit: any(named: 'limit'),
      category: any(named: 'category'),
      tags: any(named: 'tags'),
      orientation: any(named: 'orientation'),
      search: any(named: 'search'),
      isPremium: any(named: 'isPremium'),
      cancelToken: any(named: 'cancelToken'),
      headers: any(named: 'headers'),
      extra: any(named: 'extra'),
      validateStatus: any(named: 'validateStatus'),
      onSendProgress: any(named: 'onSendProgress'),
      onReceiveProgress: any(named: 'onReceiveProgress'),
    ),
  );

  group('list', () {
    test('forwards tags + search and returns Ok on success', () async {
      final page = WallpaperCursorPage(items: const [], hasMore: false);
      whenList().thenAnswer((_) async => _resp(page));

      final result = await repo.list(tags: 'neon', search: 'ne');

      expect(result, isA<Ok<WallpaperCursorPage>>());
      verify(
        () => api.wallpapersGet(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          category: any(named: 'category'),
          tags: 'neon',
          orientation: any(named: 'orientation'),
          search: 'ne',
          isPremium: any(named: 'isPremium'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
          validateStatus: any(named: 'validateStatus'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).called(1);
    });

    test('DioException → Err(mapped failure)', () async {
      whenList().thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repo.list();

      expect(result, isA<Err<WallpaperCursorPage>>());
      expect((result as Err).failure, isA<NetworkFailure>());
    });
  });

  group('getById', () {
    test('404 → Err(NotFoundFailure)', () async {
      when(() => api.wallpapersIdGet(id: any(named: 'id'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 404,
          ),
        ),
      );

      final result = await repo.getById(9);

      expect(result, isA<Err<Wallpaper>>());
      expect((result as Err).failure, isA<NotFoundFailure>());
    });
  });

  group('batch', () {
    setUpAll(() {
      registerFallbackValue(WallpaperBatchRequest(ids: const []));
    });

    When<Future<Response<List<Wallpaper>>>> whenBatch() => when(
      () => api.wallpapersBatchPost(
        wallpaperBatchRequest: any(named: 'wallpaperBatchRequest'),
        cancelToken: any(named: 'cancelToken'),
        headers: any(named: 'headers'),
        extra: any(named: 'extra'),
        validateStatus: any(named: 'validateStatus'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    );

    test('forwards ids and returns Ok on success', () async {
      final wallpapers = <Wallpaper>[Wallpaper(id: 1), Wallpaper(id: 2)];
      whenBatch().thenAnswer((_) async => _resp(wallpapers));

      final result = await repo.batch(const [1, 2]);

      expect(result, isA<Ok<List<Wallpaper>>>());
      expect((result as Ok).value, hasLength(2));
      final captured =
          verify(
                () => api.wallpapersBatchPost(
                  wallpaperBatchRequest: captureAny(
                    named: 'wallpaperBatchRequest',
                  ),
                  cancelToken: any(named: 'cancelToken'),
                  headers: any(named: 'headers'),
                  extra: any(named: 'extra'),
                  validateStatus: any(named: 'validateStatus'),
                  onSendProgress: any(named: 'onSendProgress'),
                  onReceiveProgress: any(named: 'onReceiveProgress'),
                ),
              ).captured.single
              as WallpaperBatchRequest;
      expect(captured.ids, const [1, 2]);
    });

    test('DioException → Err(mapped failure)', () async {
      whenBatch().thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repo.batch(const [1]);

      expect(result, isA<Err<List<Wallpaper>>>());
      expect((result as Err).failure, isA<TimeoutFailure>());
    });

    test('null body → Err(UnknownFailure)', () async {
      whenBatch().thenAnswer(
        (_) async => Response<List<Wallpaper>>(
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      final result = await repo.batch(const [1]);

      expect(result, isA<Err<List<Wallpaper>>>());
      expect((result as Err).failure, isA<UnknownFailure>());
    });
  });
}

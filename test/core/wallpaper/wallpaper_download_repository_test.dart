import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_download_repository.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockPublicApi extends Mock implements PublicApi {}

class _MockDio extends Mock implements Dio {}

Response<T> _resp<T>(T data) => Response<T>(
  requestOptions: RequestOptions(path: '/'),
  data: data,
);

DioException _http(int status) => DioException(
  requestOptions: RequestOptions(path: '/'),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/'),
    statusCode: status,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late _MockPublicApi api;
  late _MockDio dio;
  late WallpaperDownloadRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('lc_dl_test');
    // path_provider talks over a platform channel; point it at a temp dir.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempRoot.path,
        );

    api = _MockPublicApi();
    dio = _MockDio();
    repo = WallpaperDownloadRepositoryImpl.withDio(api, dio);
  });

  tearDown(() {
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  When<Future<Response<DownloadUrlResponse>>> whenLink() => when(
    () => api.wallpapersIdDownloadUrlGet(
      id: any(named: 'id'),
      transactionId: any(named: 'transactionId'),
      cancelToken: any(named: 'cancelToken'),
      headers: any(named: 'headers'),
      extra: any(named: 'extra'),
      validateStatus: any(named: 'validateStatus'),
      onSendProgress: any(named: 'onSendProgress'),
      onReceiveProgress: any(named: 'onReceiveProgress'),
    ),
  );

  void stubLink(String url) => whenLink().thenAnswer(
    (_) async => _resp(DownloadUrlResponse(downloadUrl: url)),
  );

  /// Makes the mocked transfer actually write bytes, so rename/length work.
  void stubTransferWrites(String bytes) {
    when(
      () => dio.download(
        any(),
        any<dynamic>(),
        cancelToken: any(named: 'cancelToken'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    ).thenAnswer((invocation) async {
      final target = invocation.positionalArguments[1] as String;
      File(target).writeAsStringSync(bytes);
      final onProgress =
          invocation.namedArguments[#onReceiveProgress]
              as void Function(int, int)?;
      onProgress?.call(bytes.length, bytes.length);
      return _resp<dynamic>(null);
    });
  }

  Directory wallpapersDir() => Directory('${tempRoot.path}/wallpapers');

  group('download', () {
    test('asks for a FRESH link on every transfer (FR-005, INV-2)', () async {
      stubLink('https://s3.example.com/masters/a.mp4?X-Amz-Signature=x');
      stubTransferWrites('abc');

      // Each round starts with nothing on disk, so each one really transfers —
      // the invariant is about the link, and a link is never carried over.
      for (var round = 0; round < 3; round++) {
        await repo.download(101);
        await repo.delete(101);
      }

      verify(
        () => api.wallpapersIdDownloadUrlGet(
          id: 101,
          transactionId: any(named: 'transactionId'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
          validateStatus: any(named: 'validateStatus'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).called(3);
    });

    test('reuses a master already on disk (FR-016)', () async {
      stubLink('https://s3.example.com/masters/a.mp4?X-Amz-Signature=x');
      stubTransferWrites('abc');

      final first = await repo.download(101);
      // Only the SECOND call is under test here.
      clearInteractions(api);
      clearInteractions(dio);
      final second = await repo.download(101);

      expect(second, isA<Ok<WallpaperFile>>());
      expect(
        (second as Ok<WallpaperFile>).value.path,
        (first as Ok<WallpaperFile>).value.path,
      );
      // The second call neither asked for a link nor moved a byte: no wasted
      // 28 MB just because the sheet was reopened.
      verifyNever(
        () => dio.download(
          any(),
          any<dynamic>(),
          cancelToken: any(named: 'cancelToken'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      );
      verifyNever(
        () => api.wallpapersIdDownloadUrlGet(
          id: any(named: 'id'),
          transactionId: any(named: 'transactionId'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
          validateStatus: any(named: 'validateStatus'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      );
    });

    test('a torn .part file is never mistaken for a master', () async {
      stubLink('https://s3.example.com/masters/a.mp4?X-Amz-Signature=x');
      stubTransferWrites('abc');
      wallpapersDir().createSync(recursive: true);
      File('${wallpapersDir().path}/101.mp4.part').writeAsStringSync('xx');

      final result = await repo.download(101);

      expect(result, isA<Ok<WallpaperFile>>());
      expect((result as Ok<WallpaperFile>).value.sizeBytes, 3);
      verify(
        () => dio.download(
          any(),
          any<dynamic>(),
          cancelToken: any(named: 'cancelToken'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).called(1);
    });

    test('returns the saved file and reports progress', () async {
      stubLink('https://s3.example.com/masters/a.mp4?X-Amz-Signature=x');
      stubTransferWrites('hello');

      final seen = <int>[];
      final result = await repo.download(
        101,
        onProgress: (p) => seen.add(p.receivedBytes),
      );

      expect(result, isA<Ok<WallpaperFile>>());
      final file = (result as Ok<WallpaperFile>).value;
      expect(file.wallpaperId, 101);
      expect(file.sizeBytes, 5);
      expect(File(file.path).existsSync(), isTrue);
      expect(seen, isNotEmpty);
    });

    test('derives the extension from the URL, ignoring the query', () async {
      stubLink('https://s3.example.com/masters/a.mov?X-Amz-Signature=abc');
      stubTransferWrites('x');

      final result = await repo.download(7) as Ok<WallpaperFile>;

      expect(result.value.path, endsWith('7.mov'));
    });

    test('falls back to mp4 when the URL has no usable extension', () async {
      stubLink('https://s3.example.com/masters/abc123?X-Amz-Signature=abc');
      stubTransferWrites('x');

      final result = await repo.download(8) as Ok<WallpaperFile>;

      expect(result.value.path, endsWith('8.mp4'));
    });

    test('402 maps to EntitlementRequired, not a generic error', () async {
      whenLink().thenThrow(_http(402));

      final result = await repo.download(101);

      expect(
        (result as Err<WallpaperFile>).failure,
        isA<EntitlementRequiredFailure>(),
      );
      verifyNever(
        () => dio.download(
          any(),
          any<dynamic>(),
          cancelToken: any(named: 'cancelToken'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      );
    });

    test('404 maps to NotFound (gone, not "no permission")', () async {
      whenLink().thenThrow(_http(404));

      final result = await repo.download(101);

      expect((result as Err<WallpaperFile>).failure, isA<NotFoundFailure>());
    });

    test('connection error maps to NetworkFailure', () async {
      whenLink().thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repo.download(101);

      expect((result as Err<WallpaperFile>).failure, isA<NetworkFailure>());
    });

    test('cancelling leaves no partial file behind (FR-008, INV-4)', () async {
      stubLink('https://s3.example.com/masters/a.mp4');
      when(
        () => dio.download(
          any(),
          any<dynamic>(),
          cancelToken: any(named: 'cancelToken'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((invocation) async {
        // A real cancel happens mid-transfer: bytes on disk, then it throws.
        File(
          invocation.positionalArguments[1] as String,
        ).writeAsStringSync('p');
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.cancel,
        );
      });

      final result = await repo.download(101, cancelToken: CancelToken());

      expect(
        (result as Err<WallpaperFile>).failure,
        isA<DownloadFailedFailure>(),
      );
      expect(wallpapersDir().listSync(), isEmpty);
    });
  });

  group('cleanup', () {
    test(
      'pruneExcept keeps exactly the file in use (FR-015, SC-007)',
      () async {
        final dir = wallpapersDir()..createSync(recursive: true);
        for (final id in [1, 2, 3]) {
          File('${dir.path}/$id.mp4').writeAsStringSync('x');
        }

        await repo.pruneExcept(2);

        expect(
          dir.listSync().map((e) => e.uri.pathSegments.last),
          ['2.mp4'],
        );
      },
    );

    test('discardPartial removes only .part files for that id', () async {
      final dir = wallpapersDir()..createSync(recursive: true);
      File('${dir.path}/5.mp4.part').writeAsStringSync('x');
      File('${dir.path}/5.mp4').writeAsStringSync('x');
      File('${dir.path}/6.mp4.part').writeAsStringSync('x');

      await repo.discardPartial(5);

      final names = dir.listSync().map((e) => e.uri.pathSegments.last).toList()
        ..sort();
      expect(names, ['5.mp4', '6.mp4.part']);
    });

    test('delete removes every file for that id', () async {
      final dir = wallpapersDir()..createSync(recursive: true);
      File('${dir.path}/9.mov').writeAsStringSync('x');
      File('${dir.path}/10.mp4').writeAsStringSync('x');

      await repo.delete(9);

      expect(dir.listSync().map((e) => e.uri.pathSegments.last), ['10.mp4']);
    });
  });

  group('the transfer client must stay bare (research R2)', () {
    test('carries no interceptors and no app key', () {
      final fileDio = WallpaperDownloadRepositoryImpl.createFileDio();

      expect(fileDio.interceptors.whereType<InterceptorsWrapper>(), isEmpty);
      expect(
        fileDio.options.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('x-app-key')),
      );
      expect(fileDio.options.baseUrl, isEmpty);
    });

    test(
      'DI does not hand it the generated client Dio '
      '(that one carries X-App-Key; the presigned URL is another host)',
      () {
        final config = File(
          'lib/core/di/injection.config.dart',
        ).readAsStringSync();
        final wiring = RegExp(
          r'WallpaperDownloadRepositoryImpl\(([^;]*?)\)',
          dotAll: true,
        ).firstMatch(config);

        expect(wiring, isNotNull, reason: 'repository must be registered');
        expect(
          wiring!.group(1),
          isNot(contains('Dio')),
          reason: 'the file transfer must never use the app-key Dio',
        );
      },
    );
  });
}

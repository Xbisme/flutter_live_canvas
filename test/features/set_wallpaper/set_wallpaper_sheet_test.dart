import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements SetWallpaperUseCase {}

class _MockPlatform extends Mock implements WallpaperPlatformService {}

const _file = WallpaperFile(
  wallpaperId: 101,
  path: '/tmp/wallpapers/101.mp4',
  sizeBytes: 1024,
);

void main() {
  late _MockUseCase useCase;
  late _MockPlatform platform;

  setUpAll(() {
    registerFallbackValue(_file);
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    useCase = _MockUseCase();
    platform = _MockPlatform();
    when(() => useCase.discardPartial(any())).thenAnswer((_) async {});
    when(
      () => platform.isLiveWallpaperSupported(),
    ).thenAnswer((_) async => true);
  });

  void stubPrepare(Result<WallpaperFile> result) => when(
    () => useCase.prepare(
      any(),
      onProgress: any(named: 'onProgress'),
      cancelToken: any(named: 'cancelToken'),
    ),
  ).thenAnswer((_) async => result);

  Widget app(TargetPlatform target) => MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: BlocProvider(
        create: (_) => SetWallpaperCubit(useCase),
        child: SetWallpaperSheet(
          wallpaperId: 101,
          wallpaperTitle: 'Neon City Loop',
          platformOverride: target,
        ),
      ),
    ),
  );

  group('Android branch', () {
    testWidgets('shows the Android explainer and CTA, and no OS switcher', (
      tester,
    ) async {
      await tester.pumpWidget(app(TargetPlatform.android));

      expect(find.text('Đặt làm hình nền'), findsOneWidget);
      expect(find.text('Tải & đặt hình nền'), findsOneWidget);
      // The prototype's Android/iPhone segmented control is a web-demo
      // affordance; a real device is on one platform (FR-002).
      expect(find.text('iPhone'), findsNothing);
      expect(find.text('Android'), findsNothing);
      // No iOS copy leaks into the Android flow.
      expect(find.text('Lưu video vào Ảnh'), findsNothing);
    });

    testWidgets('after the download it offers "Đặt làm hình nền"', (
      tester,
    ) async {
      stubPrepare(const Ok(_file));
      await tester.pumpWidget(app(TargetPlatform.android));

      await tester.tap(find.text('Tải & đặt hình nền'));
      await tester.pumpAndSettle();

      expect(find.text('Đã tải xuống'), findsOneWidget);
      expect(find.textContaining('Neon City Loop'), findsOneWidget);
      expect(find.text('Đặt làm hình nền'), findsWidgets);
      // The Shortcuts guide belongs to iOS only.
      expect(find.text('Mở app Ảnh'), findsNothing);
    });

    testWidgets('a failure shows Vietnamese copy, never a technical code', (
      tester,
    ) async {
      stubPrepare(const Err(NetworkFailure()));
      await tester.pumpWidget(app(TargetPlatform.android));

      await tester.tap(find.text('Tải & đặt hình nền'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Mất kết nối mạng'), findsOneWidget);
      expect(find.textContaining('DioException'), findsNothing);
      expect(find.textContaining('SET_FAILED'), findsNothing);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets(
      'an Android device WITHOUT live-wallpaper support still renders the '
      'Android branch — capability and platform are separate signals, so '
      'FR-017 stays reachable instead of falling through to the iOS guide',
      (tester) async {
        when(
          () => platform.isLiveWallpaperSupported(),
        ).thenAnswer((_) async => false);
        stubPrepare(const Err(PlatformUnsupportedFailure()));

        await tester.pumpWidget(app(TargetPlatform.android));
        await tester.tap(find.text('Tải & đặt hình nền'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('không hỗ trợ hình nền động'),
          findsOneWidget,
        );
        expect(find.text('Mở app Ảnh'), findsNothing);
      },
    );

    testWidgets('a download in flight offers cancel', (tester) async {
      when(
        () => useCase.prepare(
          any(),
          onProgress: any(named: 'onProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return const Ok(_file);
      });

      await tester.pumpWidget(app(TargetPlatform.android));
      await tester.tap(find.text('Tải & đặt hình nền'));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Huỷ'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  group('iOS branch', () {
    testWidgets('states the limitation plainly and never implies otherwise', (
      tester,
    ) async {
      await tester.pumpWidget(app(TargetPlatform.iOS));

      expect(
        find.textContaining('iOS không cho app tự đặt hình nền'),
        findsOneWidget,
      );
      expect(find.text('Lưu video vào Ảnh'), findsOneWidget);
      expect(find.text('Tải & đặt hình nền'), findsNothing);
    });

    testWidgets(
      'the download actually chains into the Photos write — the guide is '
      'useless if there is nothing in the library to pick',
      (tester) async {
        stubPrepare(const Ok(_file));
        when(
          () => useCase.saveToPhotos(any()),
        ).thenAnswer((_) async => const Ok(true));

        await tester.pumpWidget(app(TargetPlatform.iOS));
        await tester.tap(find.text('Lưu video vào Ảnh'));
        await tester.pumpAndSettle();

        verify(() => useCase.saveToPhotos(_file)).called(1);
      },
    );

    testWidgets('after saving it shows the three steps', (
      tester,
    ) async {
      stubPrepare(const Ok(_file));
      when(
        () => useCase.saveToPhotos(any()),
      ).thenAnswer((_) async => const Ok(true));
      await tester.pumpWidget(app(TargetPlatform.iOS));

      await tester.tap(find.text('Lưu video vào Ảnh'));
      await tester.pumpAndSettle();

      expect(find.text('Đã tải xuống'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // The route iOS actually supports: a Live Photo, set from Photos.
      expect(find.textContaining('Live Photo'), findsWidgets);
      expect(find.text('Mở app Ảnh'), findsOneWidget);
      // The Android one-tap CTA must not appear on iOS.
      expect(find.text('Đặt làm hình nền'), findsNothing);
    });

    testWidgets(
      'the Photos write blocks a second tap — it takes seconds with nothing '
      'in the state to say so, and a second download would save the wallpaper '
      'to the library twice',
      (tester) async {
        stubPrepare(const Ok(_file));
        when(() => useCase.saveToPhotos(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return const Ok(true);
        });

        await tester.pumpWidget(app(TargetPlatform.iOS));
        await tester.tap(find.text('Lưu video vào Ảnh'));
        await tester.pump();

        // The CTA is gone while the write runs, replaced by progress.
        expect(find.text('Lưu video vào Ảnh'), findsNothing);
        expect(find.text('Đang lưu vào Ảnh…'), findsOneWidget);

        await tester.pumpAndSettle();

        verify(() => useCase.saveToPhotos(_file)).called(1);
        verify(
          () => useCase.prepare(
            any(),
            onProgress: any(named: 'onProgress'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );

    testWidgets('a denied Photos permission explains itself in Vietnamese', (
      tester,
    ) async {
      stubPrepare(const Err(FileWriteFailedFailure()));
      await tester.pumpWidget(app(TargetPlatform.iOS));

      await tester.tap(find.text('Lưu video vào Ảnh'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Không lưu được tệp'), findsOneWidget);
      expect(find.textContaining('PERMISSION_DENIED'), findsNothing);
    });
  });
}

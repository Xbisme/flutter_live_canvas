import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/router/app_routes.dart';
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements SetWallpaperUseCase {}

const _file = WallpaperFile(
  wallpaperId: 101,
  path: '/tmp/wallpapers/101.mp4',
  sizeBytes: 1024,
);

void main() {
  late _MockUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_file);
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    useCase = _MockUseCase();
    when(() => useCase.discardPartial(any())).thenAnswer((_) async {});
    when(
      () => useCase.prepare(
        any(),
        onProgress: any(named: 'onProgress'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Err(EntitlementRequiredFailure()));
  });

  /// Router that records the navigation order so the Principle X sequencing
  /// can be asserted, not just the destination.
  ({Widget widget, List<String> visited}) buildApp() {
    final visited = <String>[];

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => BlocProvider(
                    create: (_) => SetWallpaperCubit(useCase),
                    child: const SetWallpaperSheet(
                      wallpaperId: 101,
                      wallpaperTitle: 'Neon City Loop',
                      platformOverride: TargetPlatform.android,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.paywall,
          builder: (context, _) {
            visited.add(AppRoutes.paywall);
            return const Scaffold(body: Text('PAYWALL'));
          },
        ),
      ],
    );

    return (
      widget: MaterialApp.router(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
      visited: visited,
    );
  }

  testWidgets('a 402 downloads nothing and offers the Paywall (FR-026)', (
    tester,
  ) async {
    final app = buildApp();
    await tester.pumpWidget(app.widget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tải & đặt hình nền'));
    await tester.pumpAndSettle();

    // No progress bar ever appeared: the server refused before any transfer.
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(app.visited, [AppRoutes.paywall]);
    expect(find.text('PAYWALL'), findsOneWidget);
  });

  testWidgets(
    'the sheet is gone BEFORE the Paywall appears — Principle X names '
    '"Paywall, Set Wallpaper" and forbids two surfaces in one frame',
    (tester) async {
      final app = buildApp();
      await tester.pumpWidget(app.widget);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(SetWallpaperSheet), findsOneWidget);

      await tester.tap(find.text('Tải & đặt hình nền'));
      await tester.pumpAndSettle();

      expect(find.byType(SetWallpaperSheet), findsNothing);
      expect(find.text('PAYWALL'), findsOneWidget);
    },
  );

  testWidgets('a blocked premium download is never recorded in history', (
    tester,
  ) async {
    final app = buildApp();
    await tester.pumpWidget(app.widget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tải & đặt hình nền'));
    await tester.pumpAndSettle();

    // The use case owns the recording; it was called and returned the refusal,
    // so nothing downstream could have logged a download.
    verify(
      () => useCase.prepare(
        101,
        onProgress: any(named: 'onProgress'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
    verifyNever(() => useCase.apply(any()));
    verifyNever(() => useCase.saveToPhotos(any()));
  });
}

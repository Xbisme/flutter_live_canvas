import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visibility_detector/visibility_detector.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

void main() {
  late _MockWallpaperRepo wallpapers;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    wallpapers = _MockWallpaperRepo();
    getIt.registerFactory<WallpaperDetailCubit>(
      () => WallpaperDetailCubit(wallpapers),
    );
  });

  tearDown(getIt.reset);

  Widget app() => const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: WallpaperDetailPage(id: '5'),
  );

  testWidgets('renders premium badge, tags and a collection link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => wallpapers.getById(5)).thenAnswer(
      (_) async => Ok(
        Wallpaper(
          id: 5,
          title: 'Neon City',
          isPremium: true,
          tags: [Tag(id: 1, slug: 'neon', name: 'Neon')],
          collections: [CollectionRef(id: 7, title: 'Neon Nights')],
        ),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.text('Neon City'), findsOneWidget);
    expect(find.byType(PremiumBadge), findsOneWidget);
    expect(find.textContaining('Neon Nights'), findsOneWidget);
    // Premium → single "Unlock" action, no set/download.
    expect(find.text('Mở khoá'), findsOneWidget);
  });

  testWidgets('shows a not-found FailureView when removed', (tester) async {
    when(
      () => wallpapers.getById(5),
    ).thenAnswer((_) async => const Err(NotFoundFailure()));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(FailureView), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/home_repository.dart';
import 'package:livecanvas/core/catalog/tag_repository.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_tile.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:livecanvas/features/browse/presentation/pages/browse_page.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_favorites_repository.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

class _MockTagRepo extends Mock implements TagRepository {}

class _MockHomeRepo extends Mock implements HomeRepository {}

HomeSection _section(List<Wallpaper> items) => HomeSection(
  key: 'sec',
  title: 'Section',
  collectionId: 1,
  isPremium: false,
  items: items,
);

void main() {
  late _MockWallpaperRepo wallpapers;
  late _MockTagRepo tags;
  late _MockHomeRepo home;

  setUp(() {
    wallpapers = _MockWallpaperRepo();
    tags = _MockTagRepo();
    home = _MockHomeRepo();
    when(() => tags.list()).thenAnswer(
      (_) async => Ok([Tag(id: 0, slug: 'all', name: 'All')]),
    );
    getIt
      ..registerFactory<BrowseCubit>(
        () => BrowseCubit(wallpapers, tags, home),
      )
      ..registerSingleton<FavoritesRepository>(FakeFavoritesRepository());
  });

  tearDown(getIt.reset);

  void stubHome(Result<List<HomeSection>> result) {
    when(() => home.sections()).thenAnswer((_) async => result);
  }

  Widget app() => const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BrowsePage(),
  );

  testWidgets('shows skeleton while loading, then curated sections '
      '(shimmer stops on state, not a timer)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    stubHome(
      Ok([
        _section([Wallpaper(id: 1, title: 'a')]),
      ]),
    );

    await tester.pumpWidget(app());
    // Initial frame: loading → skeleton.
    expect(find.byType(WallpaperGridSkeleton), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);

    // Let load() complete — the skeleton is replaced by the sections.
    await tester.pump();
    await tester.pump();

    expect(find.byType(WallpaperGridSkeleton), findsNothing);
    expect(find.text('Section'), findsOneWidget);
    expect(find.byType(WallpaperTile), findsOneWidget);
  });

  testWidgets('shows a retryable FailureView on error', (tester) async {
    stubHome(const Err(NetworkFailure()));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(FailureView), findsOneWidget);

    // Retrying reloads the home sections.
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    verify(() => home.sections()).called(2);
  });

  testWidgets('shows EmptyState when nothing is curated', (tester) async {
    stubHome(const Ok(<HomeSection>[]));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
  });
}

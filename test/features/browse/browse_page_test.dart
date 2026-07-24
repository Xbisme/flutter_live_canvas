import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/tag_repository.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:livecanvas/features/browse/presentation/pages/browse_page.dart';
import 'package:livecanvas/features/browse/presentation/widgets/wallpaper_grid.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visibility_detector/visibility_detector.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

class _MockTagRepo extends Mock implements TagRepository {}

void main() {
  late _MockWallpaperRepo wallpapers;
  late _MockTagRepo tags;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    wallpapers = _MockWallpaperRepo();
    tags = _MockTagRepo();
    when(() => tags.list()).thenAnswer(
      (_) async => Ok([Tag(id: 0, slug: 'all', name: 'All')]),
    );
    getIt.registerFactory<BrowseCubit>(() => BrowseCubit(wallpapers, tags));
  });

  tearDown(getIt.reset);

  void stub(Result<WallpaperCursorPage> result) {
    when(
      () => wallpapers.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        tags: any(named: 'tags'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => result);
  }

  Widget app() => const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BrowsePage(),
  );

  testWidgets('shows skeleton while loading, then the grid when loaded '
      '(shimmer stops on state, not a timer)', (tester) async {
    stub(
      Ok(WallpaperCursorPage(items: [Wallpaper(id: 1, title: 'a')])),
    );

    await tester.pumpWidget(app());
    // Initial frame: loading → skeleton.
    expect(find.byType(WallpaperGridSkeleton), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);

    // Let load() complete — the skeleton is replaced immediately.
    await tester.pump();
    await tester.pump();

    expect(find.byType(WallpaperGridSkeleton), findsNothing);
    expect(find.byType(WallpaperGrid), findsOneWidget);
  });

  testWidgets('shows a retryable FailureView on error', (tester) async {
    stub(const Err(NetworkFailure()));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(FailureView), findsOneWidget);

    // Retrying calls the repository again.
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    verify(
      () => wallpapers.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        tags: any(named: 'tags'),
        search: any(named: 'search'),
      ),
    ).called(2);
  });

  testWidgets('shows EmptyState when the grid has no items', (tester) async {
    stub(Ok(WallpaperCursorPage(items: const [])));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
  });
}

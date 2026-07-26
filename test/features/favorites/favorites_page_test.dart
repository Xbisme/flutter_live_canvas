import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_tile.dart';
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:livecanvas/features/favorites/presentation/pages/favorites_page.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_favorites_repository.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

void main() {
  late _MockWallpaperRepo wallpapers;
  late FakeFavoritesRepository favorites;

  setUpAll(() => registerFallbackValue(<int>[]));

  void arrange(List<int> ids) {
    wallpapers = _MockWallpaperRepo();
    favorites = FakeFavoritesRepository(ids);
    getIt
      ..registerFactory<FavoritesCubit>(
        () => FavoritesCubit(wallpapers, favorites),
      )
      ..registerSingleton<FavoritesRepository>(favorites);
  }

  tearDown(getIt.reset);

  Widget app() => const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: FavoritesPage(),
  );

  testWidgets('renders the grid with fresh batch data', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    arrange(const [5]);
    when(
      () => wallpapers.batch(any()),
    ).thenAnswer((_) async => Ok([Wallpaper(id: 5, title: 'Neon')]));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(WallpaperTile), findsOneWidget);
    expect(find.text('Neon'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no favourites', (
    tester,
  ) async {
    arrange(const []);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Chưa có gì ở đây'), findsOneWidget);
  });

  testWidgets('shows a retryable FailureView on batch error', (tester) async {
    arrange(const [5]);
    when(
      () => wallpapers.batch(any()),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.byType(FailureView), findsOneWidget);
  });
}

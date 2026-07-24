import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/browse/presentation/widgets/wallpaper_grid.dart';
import 'package:livecanvas/features/search/presentation/cubit/search_cubit.dart';
import 'package:livecanvas/features/search/presentation/pages/search_page.dart';
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
    getIt.registerFactory<SearchCubit>(() => SearchCubit(wallpapers));
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
    home: SearchPage(),
  );

  testWidgets('typing >= 2 chars runs a search and shows the grid', (
    tester,
  ) async {
    stub(Ok(WallpaperCursorPage(items: [Wallpaper(id: 1, title: 'neon')])));

    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'neon');
    await tester.pump(const Duration(milliseconds: 400)); // debounce → loading
    await tester.pump(); // load completes

    expect(find.byType(WallpaperGrid), findsOneWidget);
  });

  testWidgets('no matches shows the empty state', (tester) async {
    stub(Ok(WallpaperCursorPage(items: const [])));

    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Không tìm thấy'), findsOneWidget);
  });
}

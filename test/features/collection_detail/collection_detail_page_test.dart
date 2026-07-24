import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/collection_repository.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_tile.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_cubit.dart';
import 'package:livecanvas/features/collection_detail/presentation/pages/collection_detail_page.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visibility_detector/visibility_detector.dart';

class _MockCollectionRepo extends Mock implements CollectionRepository {}

void main() {
  late _MockCollectionRepo repo;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    repo = _MockCollectionRepo();
    getIt.registerFactory<CollectionDetailCubit>(
      () => CollectionDetailCubit(repo),
    );
  });

  tearDown(getIt.reset);

  Widget app() => const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CollectionDetailPage(id: '1'),
  );

  testWidgets('renders hero, premium actions and the wallpaper grid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.getById(1)).thenAnswer(
      (_) async => Ok(
        CollectionDetail(
          id: 1,
          title: 'Neon Nights',
          description: 'City lights',
          isPremium: true,
          accentColor: '#FF6F9C',
          items: [Wallpaper(id: 5, title: 'w5')],
        ),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.text('Neon Nights'), findsOneWidget);
    expect(find.text('Tải tất cả'), findsOneWidget);
    expect(find.byType(WallpaperTile), findsOneWidget);
  });
}

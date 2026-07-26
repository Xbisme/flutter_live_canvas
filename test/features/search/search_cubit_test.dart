import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/search/presentation/cubit/search_cubit.dart';
import 'package:livecanvas/features/search/presentation/cubit/search_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

void main() {
  late _MockWallpaperRepo wallpapers;

  const past = Duration(milliseconds: 400);

  setUp(() => wallpapers = _MockWallpaperRepo());

  SearchCubit create() => SearchCubit(wallpapers);

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

  blocTest<SearchCubit, SearchState>(
    'a query under 2 chars never hits the network',
    build: create,
    act: (c) => c.queryChanged('a'),
    wait: past,
    expect: () => [isA<SearchInitial>()],
    verify: (_) => verifyNever(
      () => wallpapers.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        tags: any(named: 'tags'),
        search: any(named: 'search'),
      ),
    ),
  );

  blocTest<SearchCubit, SearchState>(
    'queries once after debounce and emits [Loading, Loaded]',
    setUp: () => stub(
      Ok(WallpaperCursorPage(items: [Wallpaper(id: 1, title: 'neon')])),
    ),
    build: create,
    act: (c) => c.queryChanged('neon'),
    wait: past,
    expect: () => [isA<SearchLoading>(), isA<SearchLoaded>()],
  );

  blocTest<SearchCubit, SearchState>(
    'no matches emits [Loading, Empty]',
    setUp: () => stub(Ok(WallpaperCursorPage(items: const []))),
    build: create,
    act: (c) => c.queryChanged('zzz'),
    wait: past,
    expect: () => [isA<SearchLoading>(), isA<SearchEmpty>()],
  );

  blocTest<SearchCubit, SearchState>(
    'rapid typing debounces to a single query for the latest keyword',
    setUp: () => stub(
      Ok(WallpaperCursorPage(items: [Wallpaper(id: 1, title: 'neon')])),
    ),
    build: create,
    act: (c) => c
      ..queryChanged('ne')
      ..queryChanged('neon'),
    wait: past,
    verify: (_) => verify(
      () => wallpapers.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        tags: any(named: 'tags'),
        search: 'neon',
      ),
    ).called(1),
  );
}

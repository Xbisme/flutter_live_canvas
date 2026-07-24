// Explicit null args below are meaningful mock matchers (first page vs a
// cursor page), not redundant defaults.
// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/tag_repository.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

class _MockTagRepo extends Mock implements TagRepository {}

Wallpaper _wp(int id) => Wallpaper(id: id, title: 'w$id');
Tag _tag(int id, String slug) => Tag(id: id, slug: slug, name: slug);

WallpaperCursorPage _page(
  List<Wallpaper> items, {
  String? next,
  bool more = false,
}) => WallpaperCursorPage(items: items, nextCursor: next, hasMore: more);

void main() {
  late _MockWallpaperRepo wallpapers;
  late _MockTagRepo tags;

  final allTags = [_tag(0, 'all'), _tag(12, 'neon')];

  setUp(() {
    wallpapers = _MockWallpaperRepo();
    tags = _MockTagRepo();
    when(() => tags.list()).thenAnswer((_) async => Ok(allTags));
  });

  BrowseCubit build() => BrowseCubit(wallpapers, tags);

  void stubList(Result<WallpaperCursorPage> result, {String? tagsArg}) {
    when(
      () => wallpapers.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        tags: tagsArg,
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => result);
  }

  group('load', () {
    blocTest<BrowseCubit, BrowseState>(
      'emits [Loading, Loaded] with tags on success',
      setUp: () => stubList(Ok(_page([_wp(1), _wp(2)]))),
      build: build,
      act: (c) => c.load(),
      expect: () => [
        isA<BrowseLoading>(),
        isA<BrowseLoaded>()
            .having((s) => s.items.length, 'items', 2)
            .having((s) => s.tags.length, 'tags', 2)
            .having((s) => s.selectedTagId, 'selectedTagId', 0),
      ],
    );

    blocTest<BrowseCubit, BrowseState>(
      'emits [Loading, Error] when wallpapers fail',
      setUp: () => stubList(const Err(NetworkFailure())),
      build: build,
      act: (c) => c.load(),
      expect: () => [isA<BrowseLoading>(), isA<BrowseError>()],
    );
  });

  group('loadMore', () {
    blocTest<BrowseCubit, BrowseState>(
      'appends the next page and stops when hasMore is false',
      setUp: () {
        // first page has more; second page ends.
        when(
          () => wallpapers.list(
            cursor: null,
            limit: any(named: 'limit'),
            tags: null,
            search: any(named: 'search'),
          ),
        ).thenAnswer((_) async => Ok(_page([_wp(1)], next: 'c1', more: true)));
        when(
          () => wallpapers.list(
            cursor: 'c1',
            limit: any(named: 'limit'),
            tags: null,
            search: any(named: 'search'),
          ),
        ).thenAnswer((_) async => Ok(_page([_wp(2)])));
      },
      build: build,
      act: (c) async {
        await c.load();
        await c.loadMore();
      },
      verify: (c) {
        final state = c.state as BrowseLoaded;
        expect(state.items.map((w) => w.id), [1, 2]);
        expect(state.hasMore, isFalse);
      },
    );
  });

  group('selectTag', () {
    blocTest<BrowseCubit, BrowseState>(
      'reloads page one filtered by the selected tag',
      setUp: () {
        stubList(Ok(_page([_wp(1)])), tagsArg: null); // "All"
        stubList(Ok(_page([_wp(9)])), tagsArg: 'neon');
      },
      build: build,
      act: (c) async {
        await c.load();
        await c.selectTag(12);
      },
      verify: (c) {
        final state = c.state as BrowseLoaded;
        expect(state.selectedTagId, 12);
        expect(state.items.single.id, 9);
      },
    );
  });
}

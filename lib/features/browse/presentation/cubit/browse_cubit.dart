import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/home_repository.dart';
import 'package:livecanvas/core/catalog/tag_repository.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Drives Browse (v0.7.0): the "Tất cả" chip shows curated home sections
/// (`GET /home`); picking a real tag shows the flat, cursor-paginated grid
/// (`GET /wallpapers?tags=`). A monotonically increasing [_seq] discards
/// results from superseded requests so rapid tag switches never show stale
/// data (research R6).
@injectable
class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit(this._wallpapers, this._tags, this._home)
    : super(const BrowseInitial());

  final WallpaperRepository _wallpapers;
  final TagRepository _tags;
  final HomeRepository _home;

  int _seq = 0;

  /// Initial load — tags + curated home sections (the default "All" view).
  Future<void> load() async {
    final seq = ++_seq;
    emit(const BrowseLoading());
    final tagsFut = _tags.list();
    final homeFut = _home.sections();
    final tagsRes = await tagsFut;
    final homeRes = await homeFut;
    if (seq != _seq) return;
    homeRes.fold(
      (sections) => emit(
        BrowseLoaded(
          sections: sections,
          tags: tagsRes.fold((t) => t, (_) => const []),
          selectedTagId: 0,
        ),
      ),
      (failure) => emit(BrowseError(failure)),
    );
  }

  /// Switch the active tag. id 0 = "All" → curated sections; a real tag → the
  /// flat grid. Chips stay visible while the content area shows a skeleton.
  Future<void> selectTag(int id) async {
    final current = state;
    if (current is! BrowseLoaded || id == current.selectedTagId) return;
    final seq = ++_seq;
    emit(
      current.copyWith(
        selectedTagId: id,
        isReloading: true,
        loadMoreFailed: false,
      ),
    );

    if (id == 0) {
      final res = await _home.sections();
      if (seq != _seq) return;
      res.fold(
        (sections) => emit(
          BrowseLoaded(
            sections: sections,
            tags: current.tags,
            selectedTagId: 0,
          ),
        ),
        (failure) => emit(BrowseError(failure)),
      );
      return;
    }

    final res = await _wallpapers.list(tags: _slugFor(id, current.tags));
    if (seq != _seq) return;
    res.fold(
      (page) => emit(
        BrowseLoaded(
          items: page.items ?? const [],
          tags: current.tags,
          selectedTagId: id,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore ?? false,
        ),
      ),
      (failure) => emit(BrowseError(failure)),
    );
  }

  /// Pull-to-refresh — reload the current view (sections or tag grid).
  Future<void> refresh() async {
    final current = state;
    if (current is! BrowseLoaded) {
      await load();
      return;
    }
    final seq = ++_seq;

    if (current.isSectionsView) {
      final res = await _home.sections();
      if (seq != _seq) return;
      res.fold(
        (sections) => emit(current.copyWith(sections: sections)),
        (failure) => emit(BrowseError(failure)),
      );
      return;
    }

    final res = await _wallpapers.list(
      tags: _slugFor(current.selectedTagId, current.tags),
    );
    if (seq != _seq) return;
    res.fold(
      (page) => emit(
        BrowseLoaded(
          items: page.items ?? const [],
          tags: current.tags,
          selectedTagId: current.selectedTagId,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore ?? false,
        ),
      ),
      (failure) => emit(BrowseError(failure)),
    );
  }

  /// Append the next cursor page (tag grid only — sections are not paginated).
  Future<void> loadMore() async {
    final current = state;
    if (current is! BrowseLoaded || current.isSectionsView) return;
    if (!current.hasMore || current.isLoadingMore || current.isReloading) {
      return;
    }
    final seq = _seq;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final res = await _wallpapers.list(
      cursor: current.nextCursor,
      tags: _slugFor(current.selectedTagId, current.tags),
    );
    if (seq != _seq) return; // a tag switch / refresh superseded this page.
    res.fold(
      (page) => emit(
        BrowseLoaded(
          items: [...current.items, ...?page.items],
          tags: current.tags,
          selectedTagId: current.selectedTagId,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore ?? false,
        ),
      ),
      (_) => emit(current.copyWith(isLoadingMore: false, loadMoreFailed: true)),
    );
  }

  String? _slugFor(int id, List<Tag> tags) {
    if (id == 0) return null;
    for (final tag in tags) {
      if (tag.id == id) return tag.slug;
    }
    return null;
  }
}

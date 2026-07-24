import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/tag_repository.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Drives the Browse grid: first-page load (+ tags), cursor pagination,
/// single-select tag filtering, and pull-to-refresh. A monotonically
/// increasing [_seq] discards results from superseded requests so rapid tag
/// switches never show stale data (research R6).
@injectable
class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit(this._wallpapers, this._tags) : super(const BrowseInitial());

  final WallpaperRepository _wallpapers;
  final TagRepository _tags;

  int _seq = 0;

  /// Initial load — tags and page one concurrently.
  Future<void> load() async {
    final seq = ++_seq;
    emit(const BrowseLoading());
    final tagsFut = _tags.list();
    final wallFut = _wallpapers.list();
    final tagsRes = await tagsFut;
    final wallRes = await wallFut;
    if (seq != _seq) return;
    wallRes.fold(
      (page) => emit(
        BrowseLoaded(
          items: page.items ?? const [],
          tags: tagsRes.fold((t) => t, (_) => const []),
          selectedTagId: 0,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore ?? false,
        ),
      ),
      (failure) => emit(BrowseError(failure)),
    );
  }

  /// Switch the active tag (id 0 = "All" → no `tags` param). Keeps the chips
  /// visible while the grid area shows a skeleton (isReloading).
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

  /// Pull-to-refresh — reload page one for the current tag (no skeleton; the
  /// RefreshIndicator shows the spinner).
  Future<void> refresh() async {
    final current = state;
    if (current is! BrowseLoaded) {
      await load();
      return;
    }
    final seq = ++_seq;
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

  /// Append the next cursor page when the grid nears its end.
  Future<void> loadMore() async {
    final current = state;
    if (current is! BrowseLoaded) return;
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

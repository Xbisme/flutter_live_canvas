import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/features/search/presentation/cubit/search_state.dart';

/// Drives Search (US4): live queries with a debounce and a minimum length,
/// plus cursor pagination. A [_seq] token discards superseded queries so only
/// the latest keyword's results are shown (research R6).
@injectable
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._wallpapers) : super(const SearchInitial());

  final WallpaperRepository _wallpapers;

  static const _minChars = 2;
  static const _debounce = Duration(milliseconds: 350);

  Timer? _debounceTimer;
  int _seq = 0;

  /// Called on every keystroke. Queries under [_minChars] reset to the initial
  /// prompt without hitting the network.
  void queryChanged(String text) {
    _debounceTimer?.cancel();
    final query = text.trim();
    if (query.length < _minChars) {
      _seq++; // invalidate any in-flight request
      emit(const SearchInitial());
      return;
    }
    _debounceTimer = Timer(_debounce, () => _run(query));
  }

  Future<void> _run(String query) async {
    final seq = ++_seq;
    emit(const SearchLoading());
    final result = await _wallpapers.list(search: query);
    if (seq != _seq) return;
    result.fold(
      (page) {
        final items = page.items ?? const [];
        emit(
          items.isEmpty
              ? SearchEmpty(query)
              : SearchLoaded(
                  query: query,
                  items: items,
                  nextCursor: page.nextCursor,
                  hasMore: page.hasMore ?? false,
                ),
        );
      },
      (failure) => emit(SearchError(failure)),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! SearchLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    final seq = _seq;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final result = await _wallpapers.list(
      cursor: current.nextCursor,
      search: current.query,
    );
    if (seq != _seq) return;
    result.fold(
      (page) => emit(
        SearchLoaded(
          query: current.query,
          items: [...current.items, ...?page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore ?? false,
        ),
      ),
      (_) => emit(current.copyWith(isLoadingMore: false, loadMoreFailed: true)),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

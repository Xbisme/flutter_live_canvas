import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Drives the Favorites screen: on open it re-fetches fresh data for the stored
/// IDs via `POST /wallpapers/batch` (Principle IX — never cache full data),
/// chunking to the server's 100-ID limit, then reconciles away IDs the server
/// no longer returns (FR-010). It also listens to [FavoritesRepository] so
/// un-favouriting a tile in place drops it from the grid without a refetch.
@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._wallpapers, this._favorites)
    : super(const FavoritesInitial()) {
    _favorites.listenable.addListener(_onIdsChanged);
  }

  final WallpaperRepository _wallpapers;
  final FavoritesRepository _favorites;

  static const _chunkSize = 100;

  /// Discards results from a superseded load (rapid re-open / retry).
  int _seq = 0;

  Future<void> load() async {
    final seq = ++_seq;
    emit(const FavoritesLoading());

    // Newest-added first (store keeps insertion order).
    final ids = _favorites.orderedIds.reversed.toList();
    if (ids.isEmpty) {
      emit(const FavoritesLoaded([]));
      return;
    }

    final fetched = <Wallpaper>[];
    for (final chunk in _chunks(ids, _chunkSize)) {
      final res = await _wallpapers.batch(chunk);
      if (seq != _seq) return;
      final failure = res.fold((_) => null, (f) => f);
      if (failure != null) {
        emit(FavoritesError(failure)); // keep IDs — no reconcile (FR-011)
        return;
      }
      fetched.addAll(res.fold((list) => list, (_) => const <Wallpaper>[]));
    }

    // Reconcile only after every chunk succeeded (FR-010).
    final returned = fetched.map((w) => w.id).whereType<int>().toSet();
    final missing = ids.toSet().difference(returned);
    if (missing.isNotEmpty) await _favorites.prune(missing);
    if (seq != _seq) return;

    // Preserve the requested newest-first order.
    final byId = {for (final w in fetched) w.id: w};
    final ordered = [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
    emit(FavoritesLoaded(ordered));
  }

  /// Keeps the grid in sync while it is alive (e.g. favouriting from another
  /// tab, or un-favouriting a tile here):
  /// - a newly-added favourite → reload to fetch its fresh data;
  /// - only removals → drop those items in place (no refetch).
  void _onIdsChanged() {
    final current = state;
    if (current is! FavoritesLoaded) return;
    final ids = _favorites.currentIds;
    final displayed = current.items.map((w) => w.id).whereType<int>().toSet();
    if (ids.length == displayed.length && ids.containsAll(displayed)) return;

    final hasNew = ids.difference(displayed).isNotEmpty;
    if (hasNew) {
      unawaited(load()); // fetch data for the new favourite(s)
      return;
    }
    // Pure removal.
    final kept = current.items
        .where((w) => w.id != null && ids.contains(w.id))
        .toList();
    emit(FavoritesLoaded(kept));
  }

  static Iterable<List<int>> _chunks(List<int> ids, int size) sync* {
    for (var i = 0; i < ids.length; i += size) {
      yield ids.sublist(i, i + size > ids.length ? ids.length : i + size);
    }
  }

  @override
  Future<void> close() {
    _favorites.listenable.removeListener(_onIdsChanged);
    return super.close();
  }
}

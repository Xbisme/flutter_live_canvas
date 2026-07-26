import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/favorites/favorites_store.dart';

/// Single source of truth for favorite state (Principle IX). Holds an in-memory
/// ordered ID set hydrated from [FavoritesStore] and exposes it as a
/// [ValueListenable] so every screen with a heart (Browse, Collection Detail,
/// Wallpaper Detail, Favorites) stays in sync without cubit-to-cubit coupling
/// (Principle III — share via a repository).
///
/// A [ValueNotifier] (not a stream) is deliberate: `ValueListenableBuilder`
/// reads the current value synchronously on build and is notified on every
/// change, so there is no async gap where a rapid second toggle can be missed
/// (the bug a broadcast-stream + async* generator hit on device).
///
/// `toggle` is optimistic: it mutates the set and notifies immediately (<100ms,
/// SC-002), then persists to disk in the background (last-write-wins).
abstract interface class FavoritesRepository {
  /// The current favorite IDs (unordered view).
  Set<int> get currentIds;

  /// Favorite IDs in insertion order (oldest first). Screens that show
  /// newest-first reverse this.
  List<int> get orderedIds;

  /// The favourite-ID set as a listenable; rebuild UI from this.
  ValueListenable<Set<int>> get listenable;

  bool isFavorite(int id);

  /// Adds/removes [id]; updates memory + notifies at once, persists in the
  /// background.
  Future<void> toggle(int id);

  /// Permanently drops [ids] (reconcile — FR-010). No-op for absent IDs.
  Future<void> prune(Set<int> ids);

  /// Releases the notifier (called by DI on singleton disposal).
  void dispose();
}

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._store) {
    _hydration = _hydrate();
  }

  final FavoritesStore _store;

  /// Ordered list is the canonical in-memory form (insertion order matters for
  /// display); the notifier publishes the derived set.
  final List<int> _ordered = [];

  final ValueNotifier<Set<int>> _notifier = ValueNotifier(const {});

  late final Future<void> _hydration;

  Future<void> _hydrate() async {
    final stored = await _store.read();
    _ordered
      ..clear()
      ..addAll(stored);
    _publish();
  }

  void _publish() => _notifier.value = Set<int>.unmodifiable(_ordered);

  @override
  Set<int> get currentIds => _notifier.value;

  @override
  List<int> get orderedIds => List<int>.unmodifiable(_ordered);

  @override
  ValueListenable<Set<int>> get listenable => _notifier;

  @override
  bool isFavorite(int id) => _notifier.value.contains(id);

  @override
  Future<void> toggle(int id) async {
    await _hydration;
    if (_ordered.remove(id)) {
      // was a favourite → now removed
    } else {
      _ordered.add(id);
    }
    _publish();
    unawaited(_store.write(List<int>.of(_ordered)));
  }

  @override
  Future<void> prune(Set<int> ids) async {
    await _hydration;
    if (ids.isEmpty) return;
    final before = _ordered.length;
    _ordered.removeWhere(ids.contains);
    if (_ordered.length == before) return;
    _publish();
    unawaited(_store.write(List<int>.of(_ordered)));
  }

  @override
  @disposeMethod
  void dispose() => _notifier.dispose();
}

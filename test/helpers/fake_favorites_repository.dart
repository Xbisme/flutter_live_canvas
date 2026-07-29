import 'package:flutter/foundation.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';

/// Lightweight in-memory [FavoritesRepository] for widget/bloc tests — no
/// `shared_preferences`, no disk. Mirrors the real toggle/prune/notify contract.
class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository([Iterable<int> initial = const []])
    : _ordered = [...initial],
      _notifier = ValueNotifier(Set<int>.unmodifiable(initial));

  final List<int> _ordered;
  final ValueNotifier<Set<int>> _notifier;

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
    if (!_ordered.remove(id)) _ordered.add(id);
    _publish();
  }

  @override
  Future<void> prune(Set<int> ids) async {
    final before = _ordered.length;
    _ordered.removeWhere(ids.contains);
    if (_ordered.length != before) _publish();
  }

  @override
  void dispose() => _notifier.dispose();
}

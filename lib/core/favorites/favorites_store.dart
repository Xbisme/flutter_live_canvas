import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for favorite wallpaper IDs (Principle IX — IDs only, never
/// full wallpaper data). Backed by [SharedPreferencesAsync] under a single
/// versioned key; order = insertion order (newest appended last).
///
/// Thin I/O layer with no in-memory cache — the cache and reactive stream live
/// in `FavoritesRepository`.
@lazySingleton
class FavoritesStore {
  FavoritesStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  /// Versioned so a future format change can migrate to `.v2`.
  static const _key = 'favorites.ids.v1';

  /// Reads the stored IDs in insertion order. Malformed entries are skipped and
  /// any read error degrades to an empty list — the store must never crash the
  /// app or wipe the key.
  Future<List<int>> read() async {
    try {
      final raw = await _prefs.getStringList(_key) ?? const [];
      final ids = <int>[];
      for (final s in raw) {
        final id = int.tryParse(s);
        if (id != null) ids.add(id);
      }
      return ids;
    } on Object {
      return const [];
    }
  }

  /// Overwrites the stored IDs (last-write-wins), preserving the given order.
  /// Best-effort: a write failure is swallowed rather than surfaced to the UI.
  Future<void> write(List<int> ids) async {
    try {
      await _prefs.setStringList(_key, [for (final id in ids) '$id']);
    } on Object {
      // Ignore — favourites are a convenience, not critical data.
    }
  }
}

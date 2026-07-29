import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/favorites/download_history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for download-history entries (Principle IX). Backed by
/// [SharedPreferencesAsync] under a single versioned key; each element is a
/// JSON `{"id","at"}` string, ordered newest-first.
///
/// Thin, resilient I/O: malformed elements and read/write errors degrade to an
/// empty/no-op result rather than crashing.
@lazySingleton
class DownloadHistoryStore {
  DownloadHistoryStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'download_history.entries.v1';

  /// Reads entries in stored (newest-first) order, skipping malformed ones.
  Future<List<DownloadHistoryEntry>> read() async {
    try {
      final raw = await _prefs.getStringList(_key) ?? const [];
      final entries = <DownloadHistoryEntry>[];
      for (final s in raw) {
        try {
          final json = jsonDecode(s);
          if (json is Map<String, dynamic>) {
            final entry = DownloadHistoryEntry.tryFromJson(json);
            if (entry != null) entries.add(entry);
          }
        } on FormatException {
          // Skip this element, keep the rest.
        }
      }
      return entries;
    } on Object {
      return const [];
    }
  }

  /// Overwrites the stored entries in the given (newest-first) order.
  Future<void> write(List<DownloadHistoryEntry> entries) async {
    try {
      await _prefs.setStringList(_key, [
        for (final e in entries) jsonEncode(e.toJson()),
      ]);
    } on Object {
      // Best-effort — history is a convenience, not critical data.
    }
  }
}

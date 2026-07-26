import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/download_history_entry.dart';
import 'package:livecanvas/core/favorites/download_history_store.dart';

/// Local download-history log (Principle IX). MO-004 provides the store + read
/// API; MO-005 calls [record] when a native download/set completes. Entries are
/// unique per wallpaper, newest-first.
abstract interface class DownloadHistoryRepository {
  /// Records (or refreshes) a completed download: dedupes by ID and moves it to
  /// the front with the current time (FR-014).
  Future<Result<void>> record(int wallpaperId);

  /// The history, newest-download first.
  Future<Result<List<DownloadHistoryEntry>>> read();

  /// Reconcile: drop entries whose wallpaper no longer exists (FR-015).
  Future<void> prune(Set<int> ids);
}

@LazySingleton(as: DownloadHistoryRepository)
class DownloadHistoryRepositoryImpl implements DownloadHistoryRepository {
  DownloadHistoryRepositoryImpl(this._store);

  final DownloadHistoryStore _store;

  @override
  Future<Result<void>> record(int wallpaperId) async {
    try {
      final entries = await _store.read();
      entries
        ..removeWhere((e) => e.wallpaperId == wallpaperId)
        ..insert(
          0,
          DownloadHistoryEntry(
            wallpaperId: wallpaperId,
            downloadedAt: DateTime.now().toUtc(),
          ),
        );
      await _store.write(entries);
      return const Ok(null);
    } on Object catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  @override
  Future<Result<List<DownloadHistoryEntry>>> read() async {
    try {
      return Ok(await _store.read());
    } on Object catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  @override
  Future<void> prune(Set<int> ids) async {
    if (ids.isEmpty) return;
    final entries = await _store.read();
    final before = entries.length;
    entries.removeWhere((e) => ids.contains(e.wallpaperId));
    if (entries.length != before) await _store.write(entries);
  }
}

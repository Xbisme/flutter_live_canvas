import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/favorites/download_history_repository.dart';
import 'package:livecanvas/features/download_history/presentation/cubit/download_history_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Drives the Download History screen: reads the local log (newest-first), then
/// re-fetches fresh wallpaper data by ID via batch (Principle IX), reconciling
/// away entries whose wallpaper no longer exists (FR-015).
@injectable
class DownloadHistoryCubit extends Cubit<DownloadHistoryState> {
  DownloadHistoryCubit(this._wallpapers, this._history)
    : super(const DownloadHistoryInitial());

  final WallpaperRepository _wallpapers;
  final DownloadHistoryRepository _history;

  static const _chunkSize = 100;

  int _seq = 0;

  Future<void> load() async {
    final seq = ++_seq;
    emit(const DownloadHistoryLoading());

    final entriesRes = await _history.read();
    if (seq != _seq) return;
    final entries = entriesRes.fold((list) => list, (_) => null);
    if (entries == null) {
      emit(const DownloadHistoryError(_unknown));
      return;
    }
    if (entries.isEmpty) {
      emit(const DownloadHistoryLoaded([]));
      return;
    }

    final ids = entries.map((e) => e.wallpaperId).toList();
    final fetched = <Wallpaper>[];
    for (final chunk in _chunks(ids, _chunkSize)) {
      final res = await _wallpapers.batch(chunk);
      if (seq != _seq) return;
      final failure = res.fold((_) => null, (f) => f);
      if (failure != null) {
        emit(DownloadHistoryError(failure));
        return;
      }
      fetched.addAll(res.fold((list) => list, (_) => const <Wallpaper>[]));
    }

    final returned = fetched.map((w) => w.id).whereType<int>().toSet();
    final missing = ids.toSet().difference(returned);
    if (missing.isNotEmpty) await _history.prune(missing);
    if (seq != _seq) return;

    // Preserve the log's newest-first order.
    final byId = {for (final w in fetched) w.id: w};
    final ordered = [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
    emit(DownloadHistoryLoaded(ordered));
  }

  static Iterable<List<int>> _chunks(List<int> ids, int size) sync* {
    for (var i = 0; i < ids.length; i += size) {
      yield ids.sublist(i, i + size > ids.length ? ids.length : i + size);
    }
  }
}

const _unknown = UnknownFailure(message: 'download history read failed');

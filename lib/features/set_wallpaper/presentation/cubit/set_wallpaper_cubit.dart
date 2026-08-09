import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/wallpaper/download_progress.dart';
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_state.dart';

/// Drives the "Set as wallpaper" sheet.
@injectable
class SetWallpaperCubit extends Cubit<SetWallpaperState> {
  SetWallpaperCubit(this._useCase) : super(const SetWallpaperInitial());

  final SetWallpaperUseCase _useCase;

  CancelToken? _token;
  int? _downloadingId;

  /// Whether a transfer is in flight (FR-009: at most one at a time). Private:
  /// the UI reads this from the state, and `bloc_lint` only allows void-ish
  /// public members on a Cubit.
  bool get _isDownloading => _token != null;

  Future<void> startDownload(int wallpaperId) async {
    if (_isDownloading) return;

    final token = CancelToken();
    _token = token;
    _downloadingId = wallpaperId;
    emit(const SetWallpaperLoadingDownload(DownloadProgress.initial()));

    final result = await _useCase.prepare(
      wallpaperId,
      onProgress: (progress) {
        if (isClosed || _token != token) return;
        emit(SetWallpaperLoadingDownload(progress));
      },
      cancelToken: token,
    );

    _token = null;
    if (isClosed) return;

    // A cancel already moved us back to Initial; don't overwrite it with the
    // cancellation's error result.
    if (token.isCancelled) return;

    _downloadingId = null;
    emit(
      result.fold(
        SetWallpaperLoadedReady.new,
        SetWallpaperError.new,
      ),
    );
  }

  /// Cancels an in-flight transfer and clears the partial bytes (FR-008).
  Future<void> cancel() async {
    final token = _token;
    final id = _downloadingId;
    if (token == null) return;

    _token = null;
    _downloadingId = null;
    token.cancel('user cancelled');
    if (id != null) await _useCase.discardPartial(id);
    if (!isClosed) emit(const SetWallpaperInitial());
  }

  /// Android: opens the system preview.
  ///
  /// Backing out of that preview leaves the state on [SetWallpaperLoadedReady]
  /// so retrying costs no second download (FR-016).
  Future<void> applyWallpaper() async {
    final current = state;
    if (current is! SetWallpaperLoadedReady) return;

    final result = await _useCase.apply(current.file);
    if (isClosed) return;

    switch (result) {
      case Ok(value: final applied):
        if (applied) emit(SetWallpaperLoadedApplied(current.file));
      case Err(:final failure):
        emit(SetWallpaperError(failure));
    }
  }

  /// iOS: writes the video into the Photos library.
  Future<void> saveToPhotos() async {
    final current = state;
    if (current is! SetWallpaperLoadedReady) return;

    final result = await _useCase.saveToPhotos(current.file);
    if (isClosed) return;

    switch (result) {
      case Ok(value: final saved):
        if (saved) emit(SetWallpaperLoadedApplied(current.file));
      case Err(:final failure):
        emit(SetWallpaperError(failure));
    }
  }

  /// Back to the start, so the next attempt fetches a FRESH link (FR-005).
  void retry() => emit(const SetWallpaperInitial());

  @override
  Future<void> close() async {
    // Dismissing the sheet never reaches cancel(), so the cleanup has to live
    // here too — otherwise a swipe-to-dismiss mid-download leaks a `.part`
    // file every time (FR-008, INV-4).
    final token = _token;
    final id = _downloadingId;
    _token = null;
    _downloadingId = null;
    if (token != null) {
      token.cancel('sheet dismissed');
      if (id != null) await _useCase.discardPartial(id);
    }
    return super.close();
  }
}

/// Convenience for the sheet: the file currently held by the state, if any.
extension SetWallpaperStateFile on SetWallpaperState {
  WallpaperFile? get file => switch (this) {
    SetWallpaperLoadedReady(:final file) => file,
    SetWallpaperLoadedApplied(:final file) => file,
    _ => null,
  };
}

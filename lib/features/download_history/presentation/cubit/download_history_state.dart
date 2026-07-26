import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Download History screen (Principle III). Sealed 4-state;
/// empty = `DownloadHistoryLoaded` with no items.
sealed class DownloadHistoryState extends Equatable {
  const DownloadHistoryState();

  @override
  List<Object?> get props => const [];
}

final class DownloadHistoryInitial extends DownloadHistoryState {
  const DownloadHistoryInitial();
}

final class DownloadHistoryLoading extends DownloadHistoryState {
  const DownloadHistoryLoading();
}

/// Downloaded wallpapers, newest-download first. Empty list → empty state.
final class DownloadHistoryLoaded extends DownloadHistoryState {
  const DownloadHistoryLoaded(this.items);

  final List<Wallpaper> items;

  @override
  List<Object?> get props => [items];
}

final class DownloadHistoryError extends DownloadHistoryState {
  const DownloadHistoryError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

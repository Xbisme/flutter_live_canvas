import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Favorites screen (Principle III). Sealed 4-state shape; the
/// empty case is `FavoritesLoaded` with no items (no separate `empty` state).
sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => const [];
}

/// Nothing requested yet.
final class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// Fetching fresh wallpaper data for the stored IDs — grid skeleton.
final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// The reconciled favourites, newest-added first. Empty list → empty state.
final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.items);

  final List<Wallpaper> items;

  @override
  List<Object?> get props => [items];
}

/// The batch fetch failed — full-screen error + retry. Stored IDs are kept
/// (no reconcile on failure — FR-011).
final class FavoritesError extends FavoritesState {
  const FavoritesError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

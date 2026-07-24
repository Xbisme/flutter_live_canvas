import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Browse grid (Principle III). Sealed 4-state shape; pagination
/// and tag-reload live as flags inside [BrowseLoaded].
sealed class BrowseState extends Equatable {
  const BrowseState();

  @override
  List<Object?> get props => const [];
}

/// Nothing requested yet.
final class BrowseInitial extends BrowseState {
  const BrowseInitial();
}

/// First page loading — full-screen skeleton (no chips yet).
final class BrowseLoading extends BrowseState {
  const BrowseLoading();
}

/// The grid, with its tag chips and pagination cursor.
final class BrowseLoaded extends BrowseState {
  const BrowseLoaded({
    required this.items,
    required this.tags,
    required this.selectedTagId,
    required this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.isReloading = false,
  });

  final List<Wallpaper> items;
  final List<Tag> tags;
  final int selectedTagId;
  final String? nextCursor;
  final bool hasMore;

  /// Appending the next page at the grid footer.
  final bool isLoadingMore;

  /// The last `loadMore` failed — footer shows a retry.
  final bool loadMoreFailed;

  /// Re-fetching page one after a tag change — grid area shows skeleton while
  /// the chips stay visible.
  final bool isReloading;

  BrowseLoaded copyWith({
    List<Wallpaper>? items,
    List<Tag>? tags,
    int? selectedTagId,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    bool? isReloading,
  }) {
    return BrowseLoaded(
      items: items ?? this.items,
      tags: tags ?? this.tags,
      selectedTagId: selectedTagId ?? this.selectedTagId,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      isReloading: isReloading ?? this.isReloading,
    );
  }

  @override
  List<Object?> get props => [
    items,
    tags,
    selectedTagId,
    nextCursor,
    hasMore,
    isLoadingMore,
    loadMoreFailed,
    isReloading,
  ];
}

/// First-page load failed — full-screen error + retry.
final class BrowseError extends BrowseState {
  const BrowseError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

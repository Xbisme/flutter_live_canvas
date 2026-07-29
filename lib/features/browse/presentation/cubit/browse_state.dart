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

/// The Browse content. When [selectedTagId] == 0 ("Tất cả") it shows curated
/// [sections] (`GET /home`); when a real tag is picked it shows the flat,
/// cursor-paginated [items] grid (`GET /wallpapers?tags=`).
final class BrowseLoaded extends BrowseState {
  const BrowseLoaded({
    required this.tags,
    required this.selectedTagId,
    this.sections = const [],
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.isReloading = false,
  });

  /// Curated home sections — shown when [selectedTagId] == 0.
  final List<HomeSection> sections;
  final List<Wallpaper> items;
  final List<Tag> tags;
  final int selectedTagId;
  final String? nextCursor;
  final bool hasMore;

  /// True while showing the curated "Tất cả" sections view (vs a tag grid).
  bool get isSectionsView => selectedTagId == 0;

  /// Appending the next page at the grid footer.
  final bool isLoadingMore;

  /// The last `loadMore` failed — footer shows a retry.
  final bool loadMoreFailed;

  /// Re-fetching page one after a tag change — grid area shows skeleton while
  /// the chips stay visible.
  final bool isReloading;

  BrowseLoaded copyWith({
    List<HomeSection>? sections,
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
      sections: sections ?? this.sections,
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
    sections,
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

import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Search screen (US4).
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => const [];
}

/// Nothing searched yet (query < 2 chars) — show the suggestion prompt.
final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.query,
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final String query;
  final List<Wallpaper> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  SearchLoaded copyWith({
    List<Wallpaper>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return SearchLoaded(
      query: query,
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    query,
    items,
    nextCursor,
    hasMore,
    isLoadingMore,
    loadMoreFailed,
  ];
}

/// The query returned no matches.
final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchError extends SearchState {
  const SearchError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

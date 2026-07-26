import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Collections tab (US3 list).
sealed class CollectionsState extends Equatable {
  const CollectionsState();

  @override
  List<Object?> get props => const [];
}

final class CollectionsInitial extends CollectionsState {
  const CollectionsInitial();
}

final class CollectionsLoading extends CollectionsState {
  const CollectionsLoading();
}

final class CollectionsLoaded extends CollectionsState {
  const CollectionsLoaded(this.items);

  final List<Collection> items;

  @override
  List<Object?> get props => [items];
}

final class CollectionsEmpty extends CollectionsState {
  const CollectionsEmpty();
}

final class CollectionsError extends CollectionsState {
  const CollectionsError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

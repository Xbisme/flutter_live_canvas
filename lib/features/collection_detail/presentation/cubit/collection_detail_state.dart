import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Collection Detail screen (US3 detail).
sealed class CollectionDetailState extends Equatable {
  const CollectionDetailState();

  @override
  List<Object?> get props => const [];
}

final class CollectionDetailInitial extends CollectionDetailState {
  const CollectionDetailInitial();
}

final class CollectionDetailLoading extends CollectionDetailState {
  const CollectionDetailLoading();
}

final class CollectionDetailLoaded extends CollectionDetailState {
  const CollectionDetailLoaded(this.collection);

  final CollectionDetail collection;

  @override
  List<Object?> get props => [collection];
}

final class CollectionDetailErrorState extends CollectionDetailState {
  const CollectionDetailErrorState(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

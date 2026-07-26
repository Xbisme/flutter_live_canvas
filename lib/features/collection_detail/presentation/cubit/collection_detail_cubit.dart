import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/collection_repository.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_state.dart';

/// Loads one collection with its embedded, ordered `items`
/// (`GET /collections/{id}`, not paginated).
@injectable
class CollectionDetailCubit extends Cubit<CollectionDetailState> {
  CollectionDetailCubit(this._collections)
    : super(const CollectionDetailInitial());

  final CollectionRepository _collections;

  Future<void> load(int id) async {
    emit(const CollectionDetailLoading());
    final result = await _collections.getById(id);
    result.fold(
      (collection) => emit(CollectionDetailLoaded(collection)),
      (failure) => emit(CollectionDetailErrorState(failure)),
    );
  }
}

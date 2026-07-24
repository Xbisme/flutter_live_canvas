import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/collection_repository.dart';
import 'package:livecanvas/features/collections/presentation/cubit/collections_state.dart';

/// Loads the curated collection list (`GET /collections`, not paginated).
@injectable
class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit(this._collections) : super(const CollectionsInitial());

  final CollectionRepository _collections;

  Future<void> load() async {
    emit(const CollectionsLoading());
    final result = await _collections.list();
    result.fold(
      (items) => emit(
        items.isEmpty ? const CollectionsEmpty() : CollectionsLoaded(items),
      ),
      (failure) => emit(CollectionsError(failure)),
    );
  }

  Future<void> refresh() => load();
}

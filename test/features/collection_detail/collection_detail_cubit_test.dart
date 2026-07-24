import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/collection_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_cubit.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockCollectionRepo extends Mock implements CollectionRepository {}

void main() {
  late _MockCollectionRepo repo;

  setUp(() => repo = _MockCollectionRepo());

  CollectionDetailCubit create() => CollectionDetailCubit(repo);

  blocTest<CollectionDetailCubit, CollectionDetailState>(
    'load emits [Loading, Loaded] on success',
    setUp: () => when(() => repo.getById(1)).thenAnswer(
      (_) async => Ok(CollectionDetail(id: 1, title: 'Neon', items: const [])),
    ),
    build: create,
    act: (c) => c.load(1),
    expect: () => [
      isA<CollectionDetailLoading>(),
      isA<CollectionDetailLoaded>(),
    ],
  );

  blocTest<CollectionDetailCubit, CollectionDetailState>(
    'load emits [Loading, Error] when not found',
    setUp: () => when(
      () => repo.getById(9),
    ).thenAnswer((_) async => const Err(NotFoundFailure())),
    build: create,
    act: (c) => c.load(9),
    expect: () => [
      isA<CollectionDetailLoading>(),
      isA<CollectionDetailErrorState>(),
    ],
  );
}

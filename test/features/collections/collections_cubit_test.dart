import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/collection_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/collections/presentation/cubit/collections_cubit.dart';
import 'package:livecanvas/features/collections/presentation/cubit/collections_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockCollectionRepo extends Mock implements CollectionRepository {}

void main() {
  late _MockCollectionRepo repo;

  setUp(() => repo = _MockCollectionRepo());

  CollectionsCubit create() => CollectionsCubit(repo);

  blocTest<CollectionsCubit, CollectionsState>(
    'emits [Loading, Loaded] with items',
    setUp: () => when(repo.list).thenAnswer(
      (_) async => Ok([Collection(id: 1, title: 'Neon')]),
    ),
    build: create,
    act: (c) => c.load(),
    expect: () => [isA<CollectionsLoading>(), isA<CollectionsLoaded>()],
  );

  blocTest<CollectionsCubit, CollectionsState>(
    'emits [Loading, Empty] when there are none',
    setUp: () => when(repo.list).thenAnswer((_) async => const Ok([])),
    build: create,
    act: (c) => c.load(),
    expect: () => [isA<CollectionsLoading>(), isA<CollectionsEmpty>()],
  );

  blocTest<CollectionsCubit, CollectionsState>(
    'emits [Loading, Error] on failure',
    setUp: () =>
        when(repo.list).thenAnswer((_) async => const Err(NetworkFailure())),
    build: create,
    act: (c) => c.load(),
    expect: () => [isA<CollectionsLoading>(), isA<CollectionsError>()],
  );
}

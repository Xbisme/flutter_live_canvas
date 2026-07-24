import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/error/dio_error_mapper.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Reads curated collections (`GET /collections`, `GET /collections/{id}`).
/// The detail embeds its ordered `items` (no pagination).
abstract interface class CollectionRepository {
  Future<Result<List<Collection>>> list();

  Future<Result<CollectionDetail>> getById(int id);
}

@LazySingleton(as: CollectionRepository)
class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._api);

  final PublicApi _api;

  @override
  Future<Result<List<Collection>>> list() async {
    try {
      final resp = await _api.collectionsGet();
      final data = resp.data;
      if (data == null) return const Err(UnknownFailure(message: 'empty body'));
      return Ok(data);
    } on Object catch (e) {
      return Err(mapDioError(e));
    }
  }

  @override
  Future<Result<CollectionDetail>> getById(int id) async {
    try {
      final resp = await _api.collectionsIdGet(id: id);
      final data = resp.data;
      if (data == null) return const Err(UnknownFailure(message: 'empty body'));
      return Ok(data);
    } on Object catch (e) {
      return Err(mapDioError(e));
    }
  }
}

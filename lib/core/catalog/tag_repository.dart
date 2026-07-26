import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/error/dio_error_mapper.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Reads the curated tag list (`GET /tags`). The first element is always the
/// backend-generated virtual "All" tag (`id: 0`, `slug: "all"`).
// ignore: one_member_abstracts — DI seam (interface + @LazySingleton impl).
abstract interface class TagRepository {
  Future<Result<List<Tag>>> list();
}

@LazySingleton(as: TagRepository)
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._api);

  final PublicApi _api;

  @override
  Future<Result<List<Tag>>> list() async {
    try {
      final resp = await _api.tagsGet();
      final data = resp.data;
      if (data == null) return const Err(UnknownFailure(message: 'empty body'));
      return Ok(data);
    } on Object catch (e) {
      return Err(mapDioError(e));
    }
  }
}

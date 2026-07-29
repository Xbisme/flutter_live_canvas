import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/error/dio_error_mapper.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Reads the curated Browse home (`GET /home`, v0.7.0) — a bounded set of
/// sections (each a projection of a `show_on_home` Collection). No pagination,
/// no params; lives in `core/` so features don't depend on each other
/// (Principle XI).
// ignore: one_member_abstracts — DI seam (interface + @LazySingleton impl).
abstract interface class HomeRepository {
  /// The home sections in curate order (≤10 sections × ≤10 wallpapers). An
  /// empty list means nothing is enabled (200, not an error).
  Future<Result<List<HomeSection>>> sections();
}

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._api);

  final PublicApi _api;

  @override
  Future<Result<List<HomeSection>>> sections() async {
    try {
      final resp = await _api.homeGet();
      final data = resp.data;
      if (data == null) return const Err(UnknownFailure(message: 'empty body'));
      return Ok(data.sections.toList());
    } on Object catch (e) {
      return Err(mapDioError(e));
    }
  }
}

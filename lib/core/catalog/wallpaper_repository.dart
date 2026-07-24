import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/error/dio_error_mapper.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Reads the wallpaper catalog from the backend (`GET /wallpapers`,
/// `GET /wallpapers/{id}`). Shared by Browse, Search, and Wallpaper Detail —
/// lives in `core/` so features don't depend on each other (Principle XI).
abstract interface class WallpaperRepository {
  /// One cursor page of wallpapers. Pass [tags] = null for "All" (the reserved
  /// virtual tag is never sent); [search] only when the query is >= 2 chars.
  Future<Result<WallpaperCursorPage>> list({
    String? cursor,
    int limit,
    String? tags,
    String? search,
  });

  /// A single wallpaper with its `collections` populated (for the detail link).
  Future<Result<Wallpaper>> getById(int id);
}

@LazySingleton(as: WallpaperRepository)
class WallpaperRepositoryImpl implements WallpaperRepository {
  WallpaperRepositoryImpl(this._api);

  final PublicApi _api;

  @override
  Future<Result<WallpaperCursorPage>> list({
    String? cursor,
    int limit = 20,
    String? tags,
    String? search,
  }) async {
    try {
      final resp = await _api.wallpapersGet(
        cursor: cursor,
        limit: limit,
        tags: tags,
        search: search,
      );
      final data = resp.data;
      if (data == null) return const Err(UnknownFailure(message: 'empty body'));
      return Ok(data);
    } on Object catch (e) {
      return Err(mapDioError(e));
    }
  }

  @override
  Future<Result<Wallpaper>> getById(int id) async {
    try {
      final resp = await _api.wallpapersIdGet(id: id);
      final data = resp.data;
      if (data == null) return const Err(UnknownFailure(message: 'empty body'));
      return Ok(data);
    } on Object catch (e) {
      return Err(mapDioError(e));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Loads a single wallpaper via `GET /wallpapers/{id}` — the detail endpoint
/// guarantees `collections` is populated for the "From collection" link (US2).
@injectable
class WallpaperDetailCubit extends Cubit<WallpaperDetailState> {
  WallpaperDetailCubit(this._wallpapers)
    : super(const WallpaperDetailInitial());

  final WallpaperRepository _wallpapers;

  static const _relatedCount = 6;

  Future<void> load(int id) async {
    emit(const WallpaperDetailLoading());
    final result = await _wallpapers.getById(id);
    switch (result) {
      case Err(:final failure):
        emit(WallpaperDetailError(failure));
      case Ok(:final value):
        // Show the detail immediately, then fill related in the background.
        emit(WallpaperDetailLoaded(value));
        await _loadRelated(id, value);
    }
  }

  /// Fetches wallpapers sharing this one's first tag (there is no dedicated
  /// "related" endpoint) and grafts them onto the loaded state. Failures are
  /// ignored — related is a nice-to-have, not core to the screen.
  Future<void> _loadRelated(int id, Wallpaper wallpaper) async {
    final tagSlug = (wallpaper.tags ?? const []).isNotEmpty
        ? wallpaper.tags!.first.slug
        : null;
    if (tagSlug == null) return;

    final res = await _wallpapers.list(tags: tagSlug, limit: 12);
    final related = res.fold(
      (page) => (page.items ?? const [])
          .where((w) => w.id != id)
          .take(_relatedCount)
          .toList(),
      (_) => const <Wallpaper>[],
    );
    if (related.isEmpty) return;

    final current = state;
    if (current is WallpaperDetailLoaded && current.wallpaper.id == id) {
      emit(WallpaperDetailLoaded(wallpaper, related: related));
    }
  }
}

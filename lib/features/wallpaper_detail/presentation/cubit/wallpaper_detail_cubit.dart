import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart';

/// Loads a single wallpaper via `GET /wallpapers/{id}` — the detail endpoint
/// guarantees `collections` is populated for the "From collection" link (US2).
@injectable
class WallpaperDetailCubit extends Cubit<WallpaperDetailState> {
  WallpaperDetailCubit(this._wallpapers)
    : super(const WallpaperDetailInitial());

  final WallpaperRepository _wallpapers;

  Future<void> load(int id) async {
    emit(const WallpaperDetailLoading());
    final result = await _wallpapers.getById(id);
    result.fold(
      (wallpaper) => emit(WallpaperDetailLoaded(wallpaper)),
      (failure) => emit(WallpaperDetailError(failure)),
    );
  }
}

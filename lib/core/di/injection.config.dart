// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:livecanvas/core/catalog/catalog_module.dart' as _i479;
import 'package:livecanvas/core/catalog/collection_repository.dart' as _i218;
import 'package:livecanvas/core/catalog/home_repository.dart' as _i546;
import 'package:livecanvas/core/catalog/tag_repository.dart' as _i836;
import 'package:livecanvas/core/catalog/wallpaper_repository.dart' as _i141;
import 'package:livecanvas/core/config/app_config.dart' as _i950;
import 'package:livecanvas/core/di/network_module.dart' as _i318;
import 'package:livecanvas/core/favorites/download_history_repository.dart'
    as _i1047;
import 'package:livecanvas/core/favorites/download_history_store.dart' as _i101;
import 'package:livecanvas/core/favorites/favorites_repository.dart' as _i113;
import 'package:livecanvas/core/favorites/favorites_store.dart' as _i857;
import 'package:livecanvas/core/favorites/local_data_module.dart' as _i331;
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart'
    as _i1065;
import 'package:livecanvas/core/wallpaper/wallpaper_download_repository.dart'
    as _i685;
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart'
    as _i102;
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart'
    as _i124;
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_cubit.dart'
    as _i611;
import 'package:livecanvas/features/collections/presentation/cubit/collections_cubit.dart'
    as _i1059;
import 'package:livecanvas/features/download_history/presentation/cubit/download_history_cubit.dart'
    as _i343;
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_cubit.dart'
    as _i677;
import 'package:livecanvas/features/search/presentation/cubit/search_cubit.dart'
    as _i763;
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart'
    as _i184;
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart'
    as _i503;
import 'package:livecanvas_api/livecanvas_api.dart' as _i1046;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final localDataModule = _$LocalDataModule();
    final networkModule = _$NetworkModule();
    final catalogModule = _$CatalogModule();
    gh.lazySingleton<_i460.SharedPreferencesAsync>(
      () => localDataModule.sharedPreferences(),
    );
    gh.lazySingleton<_i102.WallpaperPlatformService>(
      () => _i102.WallpaperPlatformServiceImpl(),
    );
    gh.lazySingleton<_i101.DownloadHistoryStore>(
      () => _i101.DownloadHistoryStore(gh<_i460.SharedPreferencesAsync>()),
    );
    gh.lazySingleton<_i857.FavoritesStore>(
      () => _i857.FavoritesStore(gh<_i460.SharedPreferencesAsync>()),
    );
    gh.lazySingleton<_i1047.DownloadHistoryRepository>(
      () => _i1047.DownloadHistoryRepositoryImpl(
        gh<_i101.DownloadHistoryStore>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio(gh<_i950.AppConfig>()));
    gh.lazySingleton<_i113.FavoritesRepository>(
      () => _i113.FavoritesRepositoryImpl(gh<_i857.FavoritesStore>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1046.PublicApi>(
      () => catalogModule.publicApi(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i546.HomeRepository>(
      () => _i546.HomeRepositoryImpl(gh<_i1046.PublicApi>()),
    );
    gh.lazySingleton<_i218.CollectionRepository>(
      () => _i218.CollectionRepositoryImpl(gh<_i1046.PublicApi>()),
    );
    gh.lazySingleton<_i141.WallpaperRepository>(
      () => _i141.WallpaperRepositoryImpl(gh<_i1046.PublicApi>()),
    );
    gh.lazySingleton<_i836.TagRepository>(
      () => _i836.TagRepositoryImpl(gh<_i1046.PublicApi>()),
    );
    gh.lazySingleton<_i685.WallpaperDownloadRepository>(
      () => _i685.WallpaperDownloadRepositoryImpl(gh<_i1046.PublicApi>()),
    );
    gh.factory<_i677.FavoritesCubit>(
      () => _i677.FavoritesCubit(
        gh<_i141.WallpaperRepository>(),
        gh<_i113.FavoritesRepository>(),
      ),
    );
    gh.factory<_i124.BrowseCubit>(
      () => _i124.BrowseCubit(
        gh<_i141.WallpaperRepository>(),
        gh<_i836.TagRepository>(),
        gh<_i546.HomeRepository>(),
      ),
    );
    gh.factory<_i343.DownloadHistoryCubit>(
      () => _i343.DownloadHistoryCubit(
        gh<_i141.WallpaperRepository>(),
        gh<_i1047.DownloadHistoryRepository>(),
      ),
    );
    gh.factory<_i503.WallpaperDetailCubit>(
      () => _i503.WallpaperDetailCubit(gh<_i141.WallpaperRepository>()),
    );
    gh.factory<_i763.SearchCubit>(
      () => _i763.SearchCubit(gh<_i141.WallpaperRepository>()),
    );
    gh.lazySingleton<_i1065.SetWallpaperUseCase>(
      () => _i1065.SetWallpaperUseCaseImpl(
        gh<_i685.WallpaperDownloadRepository>(),
        gh<_i102.WallpaperPlatformService>(),
        gh<_i1047.DownloadHistoryRepository>(),
      ),
    );
    gh.factory<_i184.SetWallpaperCubit>(
      () => _i184.SetWallpaperCubit(gh<_i1065.SetWallpaperUseCase>()),
    );
    gh.factory<_i611.CollectionDetailCubit>(
      () => _i611.CollectionDetailCubit(gh<_i218.CollectionRepository>()),
    );
    gh.factory<_i1059.CollectionsCubit>(
      () => _i1059.CollectionsCubit(gh<_i218.CollectionRepository>()),
    );
    return this;
  }
}

class _$LocalDataModule extends _i331.LocalDataModule {}

class _$NetworkModule extends _i318.NetworkModule {}

class _$CatalogModule extends _i479.CatalogModule {}

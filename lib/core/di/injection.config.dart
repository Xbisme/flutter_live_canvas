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
import 'package:livecanvas/core/catalog/tag_repository.dart' as _i836;
import 'package:livecanvas/core/catalog/wallpaper_repository.dart' as _i141;
import 'package:livecanvas/core/config/app_config.dart' as _i950;
import 'package:livecanvas/core/di/network_module.dart' as _i318;
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart'
    as _i124;
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_cubit.dart'
    as _i611;
import 'package:livecanvas/features/collections/presentation/cubit/collections_cubit.dart'
    as _i1059;
import 'package:livecanvas/features/search/presentation/cubit/search_cubit.dart'
    as _i763;
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart'
    as _i503;
import 'package:livecanvas_api/livecanvas_api.dart' as _i1046;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final catalogModule = _$CatalogModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio(gh<_i950.AppConfig>()));
    gh.lazySingleton<_i1046.PublicApi>(
      () => catalogModule.publicApi(gh<_i361.Dio>()),
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
    gh.factory<_i503.WallpaperDetailCubit>(
      () => _i503.WallpaperDetailCubit(gh<_i141.WallpaperRepository>()),
    );
    gh.factory<_i763.SearchCubit>(
      () => _i763.SearchCubit(gh<_i141.WallpaperRepository>()),
    );
    gh.factory<_i611.CollectionDetailCubit>(
      () => _i611.CollectionDetailCubit(gh<_i218.CollectionRepository>()),
    );
    gh.factory<_i1059.CollectionsCubit>(
      () => _i1059.CollectionsCubit(gh<_i218.CollectionRepository>()),
    );
    gh.factory<_i124.BrowseCubit>(
      () => _i124.BrowseCubit(
        gh<_i141.WallpaperRepository>(),
        gh<_i836.TagRepository>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i318.NetworkModule {}

class _$CatalogModule extends _i479.CatalogModule {}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Provides the generated [PublicApi] over the shared, flavor-configured [Dio]
/// (base URL + `X-App-Key` interceptor from `NetworkModule`, MO-001).
///
/// `interceptors: const []` stops [LivecanvasApi] from adding its own default
/// auth interceptors on top of ours — we only want the existing AppKey one.
@module
abstract class CatalogModule {
  @lazySingleton
  PublicApi publicApi(Dio dio) =>
      LivecanvasApi(dio: dio, interceptors: const []).getPublicApi();
}

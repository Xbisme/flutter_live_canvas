import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/di/injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Registers the flavor [config] plus everything annotated for injectable.
///
/// Generated glue lives in `injection.config.dart`
/// (`dart run lean_builder build`).
@InjectableInit()
void configureDependencies(AppConfig config) {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..init();
}

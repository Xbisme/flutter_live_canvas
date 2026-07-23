import 'package:livecanvas/app/app.dart';
import 'package:livecanvas/bootstrap.dart';
import 'package:livecanvas/core/config/app_config.dart';

Future<void> main() async {
  await bootstrap(() => const App(), config: AppConfig.production());
}

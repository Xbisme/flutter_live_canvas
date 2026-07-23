import 'package:livecanvas/app/app.dart';
import 'package:livecanvas/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}

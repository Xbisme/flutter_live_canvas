import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/app/app.dart';
import 'package:livecanvas/app/view/home_page.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/di/injection.dart';

void main() {
  group('App', () {
    setUp(() => configureDependencies(AppConfig.development()));

    tearDown(getIt.reset);

    testWidgets('renders HomePage showing the flavor environment', (
      tester,
    ) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.textContaining('development'), findsOneWidget);
    });
  });
}

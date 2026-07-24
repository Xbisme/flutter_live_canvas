import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/app/app.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/router/app_shell.dart';
import 'package:livecanvas/features/browse/presentation/pages/browse_placeholder_page.dart';

void main() {
  group('App', () {
    setUp(() => configureDependencies(AppConfig.development()));

    tearDown(getIt.reset);

    testWidgets('boots into the 5-tab shell on the Browse tab', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(BrowsePlaceholderPage), findsOneWidget);
    });
  });
}

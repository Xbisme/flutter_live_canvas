import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_theme.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/controls/filter_chip.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_card.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(
    body: Center(child: SizedBox(width: 180, child: child)),
  ),
);

void main() {
  group('Shared widgets', () {
    testWidgets('WallpaperCard shows title, author and PRO when premium', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const WallpaperCard(
            preview: SizedBox.expand(),
            auraColor: Color(0xFF7C5CFF),
            title: 'Neon Rain',
            author: 'studiolux',
            premium: true,
          ),
        ),
      );

      expect(find.text('Neon Rain'), findsOneWidget);
      expect(find.text('@studiolux'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('non-premium WallpaperCard has no PRO badge', (tester) async {
      await tester.pumpWidget(
        _host(
          const WallpaperCard(
            preview: SizedBox.expand(),
            auraColor: Color(0xFF46D5E6),
            title: 'Cyber Alley',
            author: 'blade',
          ),
        ),
      );

      expect(find.byType(PremiumBadge), findsNothing);
    });

    testWidgets('AppButton fires onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(AppButton(label: 'Tải', onPressed: () => tapped = true)),
      );
      await tester.tap(find.text('Tải'));
      expect(tapped, isTrue);
    });

    testWidgets('AppFilterChip reports taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          AppFilterChip(label: 'Neon', selected: false, onTap: () => taps++),
        ),
      );
      await tester.tap(find.text('Neon'));
      expect(taps, 1);
    });

    testWidgets('EmptyState renders icon, title, message and action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          EmptyState(
            icon: AppIcons.heart,
            title: 'Trống',
            message: 'Chưa có gì',
            action: AppButton(label: 'Khám phá', onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Trống'), findsOneWidget);
      expect(find.text('Chưa có gì'), findsOneWidget);
      expect(find.text('Khám phá'), findsOneWidget);
    });
  });
}

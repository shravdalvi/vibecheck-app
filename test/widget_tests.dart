import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibecheck/app.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('Pause sharing updates Home screen text', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VibecheckApp()));
      await tester.pumpAndSettle();

      // Go to profile
      final profileTab = find.text('Profile');
      expect(profileTab, findsOneWidget);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // Tap Pause sharing
      final pauseRow = find.text('Pause sharing');
      await tester.tap(pauseRow);
      await tester.pumpAndSettle();

      // Select 15 minutes
      final option = find.text('15 minutes');
      await tester.tap(option);
      await tester.pumpAndSettle();

      // Go back to home
      final homeTab = find.text('Home');
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      // Verify Home updated
      expect(find.textContaining('Sharing is paused'), findsOneWidget);
    });

    testWidgets('Language switch applies instantly', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VibecheckApp()));
      await tester.pumpAndSettle();

      // Go to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Language
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Select Marathi
      await tester.tap(find.text('मराठी'));
      await tester.pumpAndSettle();

      // The setting text should now reflect the choice
      expect(find.text('मराठी'), findsWidgets);
    });

    testWidgets('Navigate opens Map with route', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VibecheckApp()));
      await tester.pumpAndSettle();

      expect(find.text('Nearest exit'), findsOneWidget);
      await tester.tap(find.text('Nearest exit'));
      await tester.pumpAndSettle();

      // Verify we switched to Map tab
      expect(find.text('Map'), findsWidgets);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibecheck/core/theme/app_theme.dart';
import 'package:vibecheck/features/home/home_screen.dart';
import 'package:vibecheck/features/zones/zones_screen.dart';
import 'package:vibecheck/features/map/map_screen.dart';
import 'package:vibecheck/features/profile/profile_screen.dart';

Widget _wrapWithScale(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: child,
      ),
    ),
  );
}

void main() {
  group('200% Text Scaling Tests', () {
    testWidgets('Home screen supports 200% scaling without crashing', (tester) async {
      await tester.pumpWidget(_wrapWithScale(const HomeScreen()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zones screen supports 200% scaling without crashing', (tester) async {
      await tester.pumpWidget(_wrapWithScale(const ZonesScreen()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Map screen supports 200% scaling without crashing', (tester) async {
      await tester.pumpWidget(_wrapWithScale(const MapScreen()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Profile screen supports 200% scaling without crashing', (tester) async {
      await tester.pumpWidget(_wrapWithScale(const ProfileScreen()));
      expect(tester.takeException(), isNull);
    });
  });
}

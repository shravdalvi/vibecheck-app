import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/core/theme/app_theme.dart';
import 'package:vibecheck/core/theme/colors.dart';
import 'package:vibecheck/features/home/home_screen.dart';
import 'package:vibecheck/features/emergency/sos_screen.dart';
import 'package:vibecheck/features/venue_map/venue_map_screen.dart';
import 'package:vibecheck/widgets/zone_ring.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: child,
      debugShowCheckedModeBanner: false,
    );

void main() {
  group('Golden tests — Home (all crowd levels)', () {
    for (final level in CrowdLevel.values) {
      testWidgets('Home screen — ${level.name}', (tester) async {
        await tester.pumpWidget(_wrap(const HomeScreen()));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/home_${level.name}.png'),
        );
      });
    }
  });

  group('Golden tests — SOS flow states', () {
    testWidgets('SOS screen — initial select state', (tester) async {
      await tester.pumpWidget(_wrap(const SosScreen()));
      await tester.pump(); // Don't settle — avoids animation issues
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/sos_select.png'),
      );
    });
  });

  group('Golden tests — Venue Map', () {
    testWidgets('Venue map screen', (tester) async {
      await tester.pumpWidget(_wrap(const VenueMapScreen()));
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/venue_map.png'),
      );
    });
  });

  group('Widget tests — ZoneRing crowd levels', () {
    testWidgets('ZoneRing shows correct zone name and label', (tester) async {
      await tester.pumpWidget(_wrap(
        const Scaffold(
          body: Center(
            child: ZoneRing(zoneName: 'Zone B', level: CrowdLevel.high),
          ),
        ),
      ));
      expect(find.text('Zone B'), findsOneWidget);
      expect(find.text('Packed'), findsOneWidget);
    });

    testWidgets('ZoneRing critical state shows correct label', (tester) async {
      await tester.pumpWidget(_wrap(
        const Scaffold(
          body: Center(
            child: ZoneRing(zoneName: 'Zone C', level: CrowdLevel.critical),
          ),
        ),
      ));
      expect(find.text('Overcrowded'), findsOneWidget);
    });
  });

  group('Widget tests — SOS screen', () {
    testWidgets('SOS screen shows type chips', (tester) async {
      await tester.pumpWidget(_wrap(const SosScreen()));
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Crowd crush'), findsOneWidget);
    });
  });

  group('Widget tests — Home screen', () {
    testWidgets('Home screen shows event name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Demo Concert 2025'), findsOneWidget);
    });

    testWidgets('Home screen shows zone ring', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.byType(ZoneRing), findsOneWidget);
    });

    testWidgets('Home screen shows SOS button', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      // SOS text is in the hold button
      expect(find.text('SOS'), findsOneWidget);
    });
  });
}

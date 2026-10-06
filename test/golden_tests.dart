import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibecheck/core/theme/app_theme.dart';
import 'package:vibecheck/features/home/home_screen.dart';
import 'package:vibecheck/features/zones/zones_screen.dart';
import 'package:vibecheck/features/map/map_screen.dart';
import 'package:vibecheck/features/profile/profile_screen.dart';
import 'package:vibecheck/core/providers/mock_providers.dart';
import 'package:vibecheck/core/providers/profile_providers.dart';
import 'package:vibecheck/core/ui/crowd_level_chip.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.dark,
      highContrastTheme: AppTheme.highContrastDark,
      home: child,
      debugShowCheckedModeBanner: false,
    ),
  );
}

void main() {
  group('Golden tests — Home', () {
    for (final level in CrowdLevel.values) {
      testWidgets('Home screen — ${level.name}', (tester) async {
        await tester.pumpWidget(_wrap(
          const HomeScreen(),
          overrides: [
            currentZoneProvider.overrideWithValue(
              CurrentZoneState(name: 'Zone A', level: level, fillPercentage: 0.5, lastUpdated: '12 s ago'),
            ),
            recommendationProvider.overrideWith((ref) => null),
            announcementProvider.overrideWith((ref) => null),
          ],
        ));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/home_${level.name}.png'),
        );
      });
    }
  });

  group('Golden tests — Zones', () {
    testWidgets('Zones screen list', (tester) async {
      await tester.pumpWidget(_wrap(const ZonesScreen()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/zones_list.png'),
      );
    });
  });

  group('Golden tests — Map', () {
    testWidgets('Map screen', (tester) async {
      await tester.pumpWidget(_wrap(const MapScreen()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/map.png'),
      );
    });
  });

  group('Golden tests — Profile', () {
    testWidgets('Profile screen — Sharing', (tester) async {
      await tester.pumpWidget(_wrap(
        const ProfileScreen(),
        overrides: [
          sharingStatusProvider.overrideWith((ref) => SharingStatus.sharing),
        ],
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/profile_sharing.png'),
      );
    });
    
    testWidgets('Profile screen — Paused', (tester) async {
      await tester.pumpWidget(_wrap(
        const ProfileScreen(),
        overrides: [
          sharingStatusProvider.overrideWith((ref) => SharingStatus.paused),
        ],
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/profile_paused.png'),
      );
    });
  });
}

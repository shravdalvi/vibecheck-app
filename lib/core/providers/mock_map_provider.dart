import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_providers.dart';
import '../ui/crowd_level_chip.dart';

class Point {
  final double x;
  final double y;
  const Point(this.x, this.y);
}

class ZonePolygon {
  final String id;
  final String name;
  final List<Point> points;
  final CrowdLevel level;

  const ZonePolygon({
    required this.id,
    required this.name,
    required this.points,
    required this.level,
  });
}

class PointOfInterest {
  final String id;
  final String type; // exit, medical, toilet, food
  final Point location;
  final String name;
  final String? walkTime;

  const PointOfInterest({
    required this.id,
    required this.type,
    required this.location,
    required this.name,
    this.walkTime,
  });
}

class MapConfig {
  final Size size;
  final List<ZonePolygon> zones;
  final List<PointOfInterest> pois;

  const MapConfig({
    required this.size,
    required this.zones,
    required this.pois,
  });
}

final mapConfigProvider = FutureProvider<MapConfig>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  return const MapConfig(
    size: Size(1000, 1000),
    zones: [
      ZonePolygon(
        id: 'z1',
        name: 'Zone A',
        level: CrowdLevel.low,
        points: [Point(100, 100), Point(400, 100), Point(400, 300), Point(100, 300)],
      ),
      ZonePolygon(
        id: 'z2',
        name: 'Zone B',
        level: CrowdLevel.high,
        points: [Point(450, 100), Point(900, 100), Point(900, 400), Point(450, 400)],
      ),
      ZonePolygon(
        id: 'z3',
        name: 'Zone C',
        level: CrowdLevel.moderate,
        points: [Point(100, 350), Point(400, 350), Point(400, 800), Point(100, 800)],
      ),
      ZonePolygon(
        id: 'z4',
        name: 'Zone D',
        level: CrowdLevel.critical,
        points: [Point(450, 450), Point(900, 450), Point(900, 900), Point(450, 900)],
      ),
    ],
    pois: [
      PointOfInterest(id: 'p1', type: 'exit', location: Point(50, 200), name: 'North Exit', walkTime: '2 min walk'),
      PointOfInterest(id: 'p2', type: 'medical', location: Point(950, 250), name: 'First Aid', walkTime: '4 min walk'),
      PointOfInterest(id: 'p3', type: 'toilet', location: Point(250, 850), name: 'Restrooms', walkTime: '1 min walk'),
      PointOfInterest(id: 'p4', type: 'food', location: Point(700, 950), name: 'Food Court', walkTime: '3 min walk'),
    ],
  );
});

final userLocationProvider = Provider<Point?>((ref) => const Point(250, 200));

class RouteState {
  final Point destination;
  final String label;
  final List<Point> path;

  const RouteState({
    required this.destination,
    required this.label,
    required this.path,
  });
}

class ActiveRouteNotifier extends Notifier<RouteState?> {
  @override
  RouteState? build() => const RouteState(
    destination: Point(900, 250),
    label: 'To First Aid · 4 min walk · via Zone B',
    path: [Point(250, 200), Point(425, 200), Point(600, 250), Point(900, 250)],
  );
  set state(RouteState? value) => super.state = value;
}
final activeRouteProvider = NotifierProvider<ActiveRouteNotifier, RouteState?>(() => ActiveRouteNotifier());

class MapFiltersNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  set state(Set<String> value) => super.state = value;
}
final mapFiltersProvider = NotifierProvider<MapFiltersNotifier, Set<String>>(() => MapFiltersNotifier());

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/crowd_level_chip.dart';

class CurrentZoneState {
  final String? name;
  final CrowdLevel level;
  final double fillPercentage;
  final String lastUpdated;
  final bool isEstimated;
  
  const CurrentZoneState({
    this.name,
    required this.level,
    required this.fillPercentage,
    required this.lastUpdated,
    this.isEstimated = false,
  });
}

class CurrentZoneNotifier extends Notifier<CurrentZoneState> {
  @override
  CurrentZoneState build() => const CurrentZoneState(
    name: 'Zone B',
    level: CrowdLevel.high,
    fillPercentage: 0.85,
    lastUpdated: 'Just now',
  );
  set state(CurrentZoneState value) => super.state = value;
}

final currentZoneProvider = NotifierProvider<CurrentZoneNotifier, CurrentZoneState>(() => CurrentZoneNotifier());

class AnnouncementState {
  final String message;
  final String timeAgo;
  final bool isUrgent;
  
  const AnnouncementState({
    required this.message,
    required this.timeAgo,
    this.isUrgent = false,
  });
}

class AnnouncementNotifier extends Notifier<AnnouncementState?> {
  @override
  AnnouncementState? build() => const AnnouncementState(
    message: 'Main stage is starting soon. Expect crowds.',
    timeAgo: '2 min ago',
  );
  set state(AnnouncementState? value) => super.state = value;
}

final announcementProvider = NotifierProvider<AnnouncementNotifier, AnnouncementState?>(() => AnnouncementNotifier());

class RecommendationState {
  final String message;
  final String targetZone;
  final CrowdLevel targetLevel;
  final String walkTime;
  final String expiryLabel;
  
  const RecommendationState({
    required this.message,
    required this.targetZone,
    required this.targetLevel,
    required this.walkTime,
    required this.expiryLabel,
  });
}

class RecommendationNotifier extends Notifier<RecommendationState?> {
  @override
  RecommendationState? build() => const RecommendationState(
    message: 'Zone B is packed. Zone C has more space.',
    targetZone: 'Zone C',
    targetLevel: CrowdLevel.low,
    walkTime: '2 min walk',
    expiryLabel: 'Suggestion ends in 4:32',
  );
  set state(RecommendationState? value) => super.state = value;
}

final recommendationProvider = NotifierProvider<RecommendationNotifier, RecommendationState?>(() => RecommendationNotifier());

enum AppConnectionStatus { active, offline, paused, locationOff }

final connectionStatusProvider = Provider<AppConnectionStatus>((ref) {
  return AppConnectionStatus.active;
});

final simulationModeProvider = Provider<bool>((ref) => false);

class ZoneData {
  final String id;
  final String name;
  final CrowdLevel level;
  final double fillPercentage;
  final String? walkTime;
  final bool isClosed;
  final String description;

  const ZoneData({
    required this.id,
    required this.name,
    required this.level,
    required this.fillPercentage,
    this.walkTime,
    this.isClosed = false,
    required this.description,
  });
}

final zonesProvider = Provider<List<ZoneData>>((ref) {
  return const [
    ZoneData(id: 'z1', name: 'Zone A', level: CrowdLevel.low, fillPercentage: 0.2, walkTime: '1 min walk', description: 'Quiet near the rear exits.'),
    ZoneData(id: 'z2', name: 'Zone B', level: CrowdLevel.high, fillPercentage: 0.85, walkTime: '2 min walk', description: 'Busy near the main stage entrance.'),
    ZoneData(id: 'z3', name: 'Zone C', level: CrowdLevel.moderate, fillPercentage: 0.5, walkTime: '3 min walk', description: 'Getting busy around the food stalls.'),
    ZoneData(id: 'z4', name: 'Zone D', level: CrowdLevel.critical, fillPercentage: 1.0, walkTime: '4 min walk', description: 'Overcrowded at the merch stand.'),
    ZoneData(id: 'z5', name: 'Zone E', level: CrowdLevel.low, fillPercentage: 0.0, walkTime: null, isClosed: true, description: 'Closed for maintenance.'),
  ];
});

final zonesLastUpdatedProvider = Provider<String>((ref) => '8 s ago');

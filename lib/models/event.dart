/// Event model
///
/// Represents a venue event with zones, configuration, and status.

class Event {
  final String eventId;
  final String eventCode;
  final String name;
  final String status; // PLANNED, ACTIVE, PAUSED, ENDED
  final DateTime startedAt;
  final DateTime endsAt;
  final String venueName;
  final double latitude;
  final double longitude;
  final List<Zone> zones;
  final EventConfig config;

  const Event({
    required this.eventId,
    required this.eventCode,
    required this.name,
    required this.status,
    required this.startedAt,
    required this.endsAt,
    required this.venueName,
    required this.latitude,
    required this.longitude,
    required this.zones,
    required this.config,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isPaused => status == 'PAUSED';
  bool get isEnded => status == 'ENDED';

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] as String,
      eventCode: json['event_code'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      venueName: json['venue_name'] as String,
      latitude: (json['coordinates']['latitude'] as num).toDouble(),
      longitude: (json['coordinates']['longitude'] as num).toDouble(),
      zones: (json['zones'] as List)
          .map((z) => Zone.fromJson(z as Map<String, dynamic>))
          .toList(),
      config: EventConfig.fromJson(json['config'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'event_code': eventCode,
    'name': name,
    'status': status,
    'started_at': startedAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'venue_name': venueName,
    'coordinates': {'latitude': latitude, 'longitude': longitude},
    'zones': zones.map((z) => z.toJson()).toList(),
    'config': config.toJson(),
  };

  Event copyWith({String? status, List<Zone>? zones}) {
    return Event(
      eventId: eventId,
      eventCode: eventCode,
      name: name,
      status: status ?? this.status,
      startedAt: startedAt,
      endsAt: endsAt,
      venueName: venueName,
      latitude: latitude,
      longitude: longitude,
      zones: zones ?? this.zones,
      config: config,
    );
  }
}

/// Zone within a venue
class Zone {
  final String zoneId;
  final String name;
  final List<List<double>> polygon; // [[lat, lon], ...]
  final int capacity;
  final int? currentOccupancy;
  final String? density; // LOW, MODERATE, HIGH, CRITICAL
  final Map<String, num> thresholds;
  final Map<String, dynamic>? recommendedRange;

  const Zone({
    required this.zoneId,
    required this.name,
    required this.polygon,
    required this.capacity,
    this.currentOccupancy,
    this.density,
    required this.thresholds,
    this.recommendedRange,
  });

  double? get occupancyPercent =>
      currentOccupancy != null ? (currentOccupancy! / capacity) * 100 : null;

  factory Zone.fromJson(Map<String, dynamic> json) {
    final polygonRaw = json['polygon'] as List;
    final polygon = polygonRaw
        .map((point) => (point as List).cast<double>())
        .toList();

    return Zone(
      zoneId: json['zone_id'] as String,
      name: json['name'] as String,
      polygon: polygon,
      capacity: json['capacity'] as int,
      currentOccupancy: json['current_occupancy'] as int?,
      density: json['density'] as String?,
      thresholds: Map<String, num>.from(
        json['thresholds'] as Map<String, dynamic>,
      ),
      recommendedRange: json['recommended_range'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'zone_id': zoneId,
    'name': name,
    'polygon': polygon,
    'capacity': capacity,
    'current_occupancy': currentOccupancy,
    'density': density,
    'thresholds': thresholds,
    'recommended_range': recommendedRange,
  };
}

/// Event-wide configuration
class EventConfig {
  final String minAppVersion;
  final SamplingPolicy samplingPolicy;
  final Map<String, int> movementThresholds;
  final Map<String, dynamic>? mapConfig;
  final int telemetryRetentionDays;

  const EventConfig({
    required this.minAppVersion,
    required this.samplingPolicy,
    required this.movementThresholds,
    this.mapConfig,
    required this.telemetryRetentionDays,
  });

  factory EventConfig.fromJson(Map<String, dynamic> json) {
    return EventConfig(
      minAppVersion: json['min_app_version'] as String,
      samplingPolicy: SamplingPolicy.fromJson(
        json['sampling_policy'] as Map<String, dynamic>,
      ),
      movementThresholds: Map<String, int>.from(
        json['movement_thresholds'] as Map<String, dynamic>,
      ),
      mapConfig: json['map_config'] as Map<String, dynamic>?,
      telemetryRetentionDays: json['telemetry_retention_days'] as int? ?? 90,
    );
  }

  Map<String, dynamic> toJson() => {
    'min_app_version': minAppVersion,
    'sampling_policy': samplingPolicy.toJson(),
    'movement_thresholds': movementThresholds,
    'map_config': mapConfig,
    'telemetry_retention_days': telemetryRetentionDays,
  };
}

/// Telemetry sampling intervals
class SamplingPolicy {
  final double stationaryIntervalS;
  final double walkingIntervalS;
  final double highMovementIntervalS;
  final double backgroundIntervalS;

  const SamplingPolicy({
    required this.stationaryIntervalS,
    required this.walkingIntervalS,
    required this.highMovementIntervalS,
    required this.backgroundIntervalS,
  });

  factory SamplingPolicy.fromJson(Map<String, dynamic> json) {
    return SamplingPolicy(
      stationaryIntervalS: (json['stationary_interval_s'] as num).toDouble(),
      walkingIntervalS: (json['walking_interval_s'] as num).toDouble(),
      highMovementIntervalS: (json['high_movement_interval_s'] as num)
          .toDouble(),
      backgroundIntervalS: (json['background_interval_s'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'stationary_interval_s': stationaryIntervalS,
    'walking_interval_s': walkingIntervalS,
    'high_movement_interval_s': highMovementIntervalS,
    'background_interval_s': backgroundIntervalS,
  };
}

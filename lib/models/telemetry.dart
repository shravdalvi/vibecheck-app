import 'package:uuid/uuid.dart';

/// A single telemetry record (location, movement, device status)
///
/// See docs/api_contract.openapi.yaml for full specification.

class TelemetryRecord {
  final String recordId; // UUID v4; idempotency key
  final int seq; // Monotonic per session
  final String eventId;
  final String participantId;
  final String sourceType; // PHONE, SIMULATED
  final bool isSimulated;
  final DateTime deviceTime;
  final int? clockOffsetMs; // Estimated offset vs server

  // GPS
  final double latitude;
  final double longitude;
  final double accuracyM;
  final double speedMps;
  final double headingDeg;
  final bool mockLocationFlag;

  // Movement
  final int movementScore; // 0-100
  final String
  movementState; // STATIONARY, WALKING, FAST_MOVING, HIGH_MOVEMENT, UNKNOWN
  final double accelVariance;
  final double motionIntensityRaw;

  // Zone & Sampling
  final String? zoneHint; // Advisory only
  final String samplingMode; // STATIONARY, WALKING, BACKGROUND, HIGH_MOVEMENT

  // Device State
  final int batteryLevel; // 0-100
  final bool gpsEnabled;
  final String locationPermission; // NONE, WHEN_IN_USE, ALWAYS, DENIED
  final String networkStatus; // OFFLINE, CELLULAR, WIFI, UNKNOWN
  final String appStatus; // ACTIVE, BACKGROUND, PAUSED
  final DateTime? lastSuccessfulUpload;

  const TelemetryRecord({
    required this.recordId,
    required this.seq,
    required this.eventId,
    required this.participantId,
    required this.sourceType,
    required this.isSimulated,
    required this.deviceTime,
    this.clockOffsetMs,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.speedMps,
    required this.headingDeg,
    required this.mockLocationFlag,
    required this.movementScore,
    required this.movementState,
    required this.accelVariance,
    required this.motionIntensityRaw,
    required this.zoneHint,
    required this.samplingMode,
    required this.batteryLevel,
    required this.gpsEnabled,
    required this.locationPermission,
    required this.networkStatus,
    required this.appStatus,
    required this.lastSuccessfulUpload,
  });

  /// Create a new TelemetryRecord with a generated UUID
  factory TelemetryRecord.create({
    required int seq,
    required String eventId,
    required String participantId,
    required String sourceType,
    required bool isSimulated,
    required double latitude,
    required double longitude,
    required double accuracyM,
    double speedMps = 0.0,
    double headingDeg = 0.0,
    bool mockLocationFlag = false,
    required int movementScore,
    required String movementState,
    double accelVariance = 0.0,
    double motionIntensityRaw = 0.0,
    String? zoneHint,
    required String samplingMode,
    required int batteryLevel,
    required bool gpsEnabled,
    required String locationPermission,
    required String networkStatus,
    required String appStatus,
    DateTime? lastSuccessfulUpload,
    int? clockOffsetMs,
  }) {
    return TelemetryRecord(
      recordId: const Uuid().v4(),
      seq: seq,
      eventId: eventId,
      participantId: participantId,
      sourceType: sourceType,
      isSimulated: isSimulated,
      deviceTime: DateTime.now().toUtc(),
      clockOffsetMs: clockOffsetMs,
      latitude: latitude,
      longitude: longitude,
      accuracyM: accuracyM,
      speedMps: speedMps,
      headingDeg: headingDeg,
      mockLocationFlag: mockLocationFlag,
      movementScore: movementScore,
      movementState: movementState,
      accelVariance: accelVariance,
      motionIntensityRaw: motionIntensityRaw,
      zoneHint: zoneHint,
      samplingMode: samplingMode,
      batteryLevel: batteryLevel,
      gpsEnabled: gpsEnabled,
      locationPermission: locationPermission,
      networkStatus: networkStatus,
      appStatus: appStatus,
      lastSuccessfulUpload: lastSuccessfulUpload,
    );
  }

  factory TelemetryRecord.fromJson(Map<String, dynamic> json) {
    return TelemetryRecord(
      recordId: json['record_id'] as String,
      seq: json['seq'] as int,
      eventId: json['event_id'] as String,
      participantId: json['participant_id'] as String,
      sourceType: json['source_type'] as String,
      isSimulated: json['is_simulated'] as bool,
      deviceTime: DateTime.parse(json['device_time'] as String),
      clockOffsetMs: json['clock_offset_ms'] as int?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyM: (json['accuracy_m'] as num).toDouble(),
      speedMps: (json['speed_mps'] as num?)?.toDouble() ?? 0.0,
      headingDeg: (json['heading_deg'] as num?)?.toDouble() ?? 0.0,
      mockLocationFlag: json['mock_location_flag'] as bool? ?? false,
      movementScore: json['movement_score'] as int,
      movementState: json['movement_state'] as String,
      accelVariance: (json['accel_variance'] as num?)?.toDouble() ?? 0.0,
      motionIntensityRaw:
          (json['motion_intensity_raw'] as num?)?.toDouble() ?? 0.0,
      zoneHint: json['zone_hint'] as String?,
      samplingMode: json['sampling_mode'] as String,
      batteryLevel: json['battery_level'] as int,
      gpsEnabled: json['gps_enabled'] as bool,
      locationPermission: json['location_permission'] as String,
      networkStatus: json['network_status'] as String,
      appStatus: json['app_status'] as String,
      lastSuccessfulUpload: json['last_successful_upload'] != null
          ? DateTime.parse(json['last_successful_upload'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'schema_version': 1,
    'record_id': recordId,
    'seq': seq,
    'event_id': eventId,
    'participant_id': participantId,
    'source_type': sourceType,
    'is_simulated': isSimulated,
    'device_time': deviceTime.toIso8601String(),
    'clock_offset_ms': clockOffsetMs,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy_m': accuracyM,
    'speed_mps': speedMps,
    'heading_deg': headingDeg,
    'mock_location_flag': mockLocationFlag,
    'movement_score': movementScore,
    'movement_state': movementState,
    'accel_variance': accelVariance,
    'motion_intensity_raw': motionIntensityRaw,
    'zone_hint': zoneHint,
    'sampling_mode': samplingMode,
    'battery_level': batteryLevel,
    'gps_enabled': gpsEnabled,
    'location_permission': locationPermission,
    'network_status': networkStatus,
    'app_status': appStatus,
    'last_successful_upload': lastSuccessfulUpload?.toIso8601String(),
  };

  bool get isPhoneSource => sourceType == 'PHONE';
  bool get isSimulatedSource => sourceType == 'SIMULATED';
  bool get hasGoodAccuracy => accuracyM <= 30.0;
}

/// Batch of telemetry records for uploading
class TelemetryBatch {
  final List<TelemetryRecord> records;

  TelemetryBatch({required this.records});

  Map<String, dynamic> toJson() => {
    'records': records.map((r) => r.toJson()).toList(),
  };
}

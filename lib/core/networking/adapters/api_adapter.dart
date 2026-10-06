/// API Adapter Interface
///
/// All backend communication is isolated behind this interface.
/// To swap backends, only implement this interface and inject the new adapter.
/// This ensures that app logic never depends on specific backend implementation.

import '../../../models/event.dart';
import '../../../models/participant.dart';
import '../../../models/telemetry.dart';
import '../../../models/sos.dart';
import '../../../models/recommendation.dart';
import '../../../core/errors/app_exceptions.dart';

abstract class ApiAdapter {
  // ============================================================================
  // AUTHENTICATION & SESSION
  // ============================================================================

  /// Join an event; returns participant ID and tokens
  ///
  /// Throws [NetworkException], [HttpException], [ValidationException]
  Future<Participant> joinEvent({
    required String eventCode,
    required String appVersion,
  });

  /// Refresh access token
  ///
  /// Throws [AuthException] if refresh token is invalid
  Future<Participant> refreshToken({
    required String participantId,
    required String refreshToken,
  });

  // ============================================================================
  // EVENTS & CONFIGURATION
  // ============================================================================

  /// Get event details and zone configuration
  ///
  /// Throws [NetworkException], [AuthException]
  Future<Event> getEvent({
    required String eventId,
    required String accessToken,
  });

  // ============================================================================
  // TELEMETRY
  // ============================================================================

  /// Submit a batch of telemetry records
  ///
  /// Returns [TelemetryBatchResponse] with accepted/rejected counts
  ///
  /// Throws [NetworkException], [ValidationException]
  Future<TelemetryBatchResponse> submitTelemetry({
    required TelemetryBatch batch,
    required String accessToken,
  });

  /// Poll for pending updates (REST fallback for WebSocket)
  ///
  /// Returns flags indicating if client should sync config/zones/recommendations
  ///
  /// Throws [NetworkException], [AuthException]
  Future<PollResponse> pollForUpdates({
    required String accessToken,
  });

  // ============================================================================
  // RECOMMENDATIONS
  // ============================================================================

  /// Get active recommendations for this participant
  ///
  /// Throws [NetworkException], [AuthException]
  Future<List<Recommendation>> getRecommendations({
    required String accessToken,
  });

  /// Acknowledge receipt of a recommendation
  ///
  /// Throws [NetworkException], [AuthException]
  Future<void> ackRecommendation({
    required String recommendationId,
    required String accessToken,
  });

  // ============================================================================
  // SOS / EMERGENCY
  // ============================================================================

  /// Submit an emergency SOS alert
  ///
  /// Returns SOS ID for tracking
  ///
  /// Throws [NetworkException], [SOSException]
  Future<String> submitSOS({
    required SOSSubmission sos,
    required String accessToken,
  });

  /// Get SOS status
  ///
  /// Throws [NetworkException], [AuthException]
  Future<SOSStatus> getSOSStatus({
    required String sosId,
    required String accessToken,
  });

  // ============================================================================
  // WEBSOCKET (Real-time)
  // ============================================================================

  /// Create a WebSocket connection for real-time updates
  ///
  /// The stream emits [WebSocketMessage] objects.
  /// Returns a broadcast stream that can have multiple listeners.
  ///
  /// To close: call [closeWebSocket] or the stream's controller.
  ///
  /// Throws [NetworkException]
  Stream<WebSocketMessage> openWebSocket({
    required String eventId,
    required String accessToken,
  });

  /// Explicitly close the WebSocket connection
  Future<void> closeWebSocket({required String eventId});

  /// Send an acknowledgement over the WebSocket
  ///
  /// Throws [NetworkException] if not connected
  Future<void> sendWebSocketAck({
    required String messageId,
    required String eventId,
  });
}

// ============================================================================
// DATA MODELS FOR API RESPONSES
// ============================================================================

class TelemetryBatchResponse {
  final int acceptedCount;
  final List<RejectedRecord> rejected;

  const TelemetryBatchResponse({
    required this.acceptedCount,
    required this.rejected,
  });

  factory TelemetryBatchResponse.fromJson(Map<String, dynamic> json) {
    final rejectedList = json['rejected'] as List?;
    return TelemetryBatchResponse(
      acceptedCount: json['accepted_count'] as int,
      rejected: rejectedList
              ?.map((r) => RejectedRecord.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RejectedRecord {
  final String recordId;
  final String reason;

  const RejectedRecord({required this.recordId, required this.reason});

  factory RejectedRecord.fromJson(Map<String, dynamic> json) {
    return RejectedRecord(
      recordId: json['record_id'] as String,
      reason: json['reason'] as String,
    );
  }
}

class PollResponse {
  final bool hasNewConfig;
  final bool hasNewAssignments;
  final bool hasNewRecommendations;

  const PollResponse({
    required this.hasNewConfig,
    required this.hasNewAssignments,
    required this.hasNewRecommendations,
  });

  factory PollResponse.fromJson(Map<String, dynamic> json) {
    return PollResponse(
      hasNewConfig: json['has_new_config'] as bool? ?? false,
      hasNewAssignments: json['has_new_assignments'] as bool? ?? false,
      hasNewRecommendations: json['has_new_recommendations'] as bool? ?? false,
    );
  }
}

// ============================================================================
// WEBSOCKET MESSAGE (discriminated union)
// ============================================================================

sealed class WebSocketMessage {
  final String type;
  final DateTime receivedAt;

  WebSocketMessage({required this.type}) : receivedAt = DateTime.now().toUtc();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'HEARTBEAT':
        return HeartbeatMessage.fromJson(json);
      case 'ZONE_ASSIGNMENT':
        return ZoneAssignmentMessage.fromJson(json);
      case 'ZONE_ALERT':
        return ZoneAlertMessage.fromJson(json);
      case 'RECOMMENDATION':
        return RecommendationMessage.fromJson(json);
      case 'SOS_STATUS':
        return SOSStatusMessage.fromJson(json);
      case 'CONFIG_UPDATE':
        return ConfigUpdateMessage.fromJson(json);
      case 'EMERGENCY_NOTICE':
        return EmergencyNoticeMessage.fromJson(json);
      case 'ANNOUNCEMENT':
        return AnnouncementMessage.fromJson(json);
      default:
        return UnknownMessage(type: type, data: json);
    }
  }
}

class HeartbeatMessage extends WebSocketMessage {
  final DateTime timestamp;

  HeartbeatMessage({required this.timestamp}) : super(type: 'HEARTBEAT');

  factory HeartbeatMessage.fromJson(Map<String, dynamic> json) {
    return HeartbeatMessage(
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ZoneAssignmentMessage extends WebSocketMessage {
  final String eventId;
  final String participantId;
  final String zoneId;
  final String zoneName;
  final DateTime assignedAt;

  ZoneAssignmentMessage({
    required this.eventId,
    required this.participantId,
    required this.zoneId,
    required this.zoneName,
    required this.assignedAt,
  }) : super(type: 'ZONE_ASSIGNMENT');

  factory ZoneAssignmentMessage.fromJson(Map<String, dynamic> json) {
    return ZoneAssignmentMessage(
      eventId: json['event_id'] as String,
      participantId: json['participant_id'] as String,
      zoneId: json['zone_id'] as String,
      zoneName: json['zone_name'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
    );
  }
}

class ZoneAlertMessage extends WebSocketMessage {
  final String eventId;
  final String zoneId;
  final String zoneName;
  final String density;
  final int occupancy;
  final int capacity;
  final String message;
  final String priority;
  final DateTime createdAt;
  final DateTime expiresAt;

  ZoneAlertMessage({
    required this.eventId,
    required this.zoneId,
    required this.zoneName,
    required this.density,
    required this.occupancy,
    required this.capacity,
    required this.message,
    required this.priority,
    required this.createdAt,
    required this.expiresAt,
  }) : super(type: 'ZONE_ALERT');

  factory ZoneAlertMessage.fromJson(Map<String, dynamic> json) {
    return ZoneAlertMessage(
      eventId: json['event_id'] as String,
      zoneId: json['zone_id'] as String,
      zoneName: json['zone_name'] as String,
      density: json['density'] as String,
      occupancy: json['occupancy'] as int,
      capacity: json['capacity'] as int,
      message: json['message'] as String,
      priority: json['priority'] as String? ?? 'NORMAL',
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

class RecommendationMessage extends WebSocketMessage {
  final Recommendation recommendation;

  RecommendationMessage({required this.recommendation})
      : super(type: 'RECOMMENDATION');

  factory RecommendationMessage.fromJson(Map<String, dynamic> json) {
    return RecommendationMessage(
      recommendation: Recommendation.fromJson(json),
    );
  }
}

class SOSStatusMessage extends WebSocketMessage {
  final SOSStatus sosStatus;

  SOSStatusMessage({required this.sosStatus}) : super(type: 'SOS_STATUS');

  factory SOSStatusMessage.fromJson(Map<String, dynamic> json) {
    return SOSStatusMessage(
      sosStatus: SOSStatus.fromJson(json),
    );
  }
}

class ConfigUpdateMessage extends WebSocketMessage {
  final int configVersion;
  final String eventId;
  final Map<String, dynamic> config;

  ConfigUpdateMessage({
    required this.configVersion,
    required this.eventId,
    required this.config,
  }) : super(type: 'CONFIG_UPDATE');

  factory ConfigUpdateMessage.fromJson(Map<String, dynamic> json) {
    return ConfigUpdateMessage(
      configVersion: json['config_version'] as int,
      eventId: json['event_id'] as String,
      config: {...json}..remove('type'),
    );
  }
}

class EmergencyNoticeMessage extends WebSocketMessage {
  final String eventId;
  final String severity;
  final String message;
  final String? action;
  final List<Map<String, dynamic>>? assemblyPoints;

  EmergencyNoticeMessage({
    required this.eventId,
    required this.severity,
    required this.message,
    this.action,
    this.assemblyPoints,
  }) : super(type: 'EMERGENCY_NOTICE');

  factory EmergencyNoticeMessage.fromJson(Map<String, dynamic> json) {
    return EmergencyNoticeMessage(
      eventId: json['event_id'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      action: json['action'] as String?,
      assemblyPoints:
          (json['assembly_points'] as List?)?.cast<Map<String, dynamic>>(),
    );
  }
}

class AnnouncementMessage extends WebSocketMessage {
  final String announcementId;
  final String eventId;
  final String message;
  final String priority;

  AnnouncementMessage({
    required this.announcementId,
    required this.eventId,
    required this.message,
    required this.priority,
  }) : super(type: 'ANNOUNCEMENT');

  factory AnnouncementMessage.fromJson(Map<String, dynamic> json) {
    return AnnouncementMessage(
      announcementId: json['announcement_id'] as String,
      eventId: json['event_id'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String? ?? 'LOW',
    );
  }
}

class UnknownMessage extends WebSocketMessage {
  final Map<String, dynamic> data;

  UnknownMessage({required String type, required this.data})
      : super(type: type);
}

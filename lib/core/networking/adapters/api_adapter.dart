/// API Adapter Interface
///
/// All backend communication is isolated behind this interface.
/// To swap backends, only implement this interface and inject the new adapter.
/// This ensures that app logic never depends on specific backend implementation.

import '../../../models/event.dart';
import '../../../models/participant.dart';
import '../../../models/telemetry.dart';
import '../../../models/recommendation.dart';
import '../../../core/errors/app_exceptions.dart';

abstract class ApiAdapter {
  // ============================================================================
  // AUTHENTICATION & SESSION
  // ============================================================================

  /// Join an event; returns participant ID and tokens
  ///
  /// Throws [NetworkException], [HttpException], [ValidationException]
  Future<JoinResponse> joinEvent({
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
  Future<EventConfigResponse> getConfig({
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
  // PRESENCE
  // ============================================================================

  /// Update presence state (ACTIVE, PAUSED, LEFT)
  ///
  /// Throws [NetworkException]
  Future<void> updatePresence({
    required String eventId,
    required String state,
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
  final String zone;
  final String zoneLevel;
  final Recommendation? recommendation;
  final int configVersion;
  final String eventStatus;
  final DateTime serverTime;

  const TelemetryBatchResponse({
    required this.zone,
    required this.zoneLevel,
    this.recommendation,
    required this.configVersion,
    required this.eventStatus,
    required this.serverTime,
  });

  factory TelemetryBatchResponse.fromJson(Map<String, dynamic> json) {
    return TelemetryBatchResponse(
      zone: json['zone'] as String,
      zoneLevel: json['zone_level'] as String,
      recommendation: json['recommendation'] != null 
          ? Recommendation.fromJson(json['recommendation'] as Map<String, dynamic>)
          : null,
      configVersion: json['config_version'] as int,
      eventStatus: json['event_status'] as String,
      serverTime: DateTime.parse(json['server_time'] as String),
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
      case 'CONFIG_UPDATE':
        return ConfigUpdateMessage.fromJson(json);
      case 'ANNOUNCEMENT':
        return AnnouncementMessage.fromJson(json);
      case 'RECOMMENDATION':
        return RecommendationMessage.fromJson(json);
      case 'EVENT_STARTED':
        return EventStartedMessage.fromJson(json);
      case 'EVENT_ENDED':
        return EventEndedMessage.fromJson(json);
      default:
        return UnknownMessage(type: type, data: json);
    }
  }
}

class HeartbeatMessage extends WebSocketMessage {
  HeartbeatMessage() : super(type: 'HEARTBEAT');
  factory HeartbeatMessage.fromJson(Map<String, dynamic> json) => HeartbeatMessage();
}

class ConfigUpdateMessage extends WebSocketMessage {
  final int configVersion;
  ConfigUpdateMessage({required this.configVersion}) : super(type: 'CONFIG_UPDATE');
  factory ConfigUpdateMessage.fromJson(Map<String, dynamic> json) {
    return ConfigUpdateMessage(configVersion: json['config_version'] as int);
  }
}

class AnnouncementMessage extends WebSocketMessage {
  final String id;
  final String text;
  final bool urgent;
  final DateTime sentAt;
  AnnouncementMessage({required this.id, required this.text, required this.urgent, required this.sentAt}) : super(type: 'ANNOUNCEMENT');
  factory AnnouncementMessage.fromJson(Map<String, dynamic> json) {
    return AnnouncementMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      urgent: json['urgent'] as bool? ?? false,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }
}

class RecommendationMessage extends WebSocketMessage {
  final Recommendation recommendation;
  RecommendationMessage({required this.recommendation}) : super(type: 'RECOMMENDATION');
  factory RecommendationMessage.fromJson(Map<String, dynamic> json) {
    return RecommendationMessage(recommendation: Recommendation.fromJson(json));
  }
}

class EventStartedMessage extends WebSocketMessage {
  EventStartedMessage() : super(type: 'EVENT_STARTED');
  factory EventStartedMessage.fromJson(Map<String, dynamic> json) => EventStartedMessage();
}

class EventEndedMessage extends WebSocketMessage {
  EventEndedMessage() : super(type: 'EVENT_ENDED');
  factory EventEndedMessage.fromJson(Map<String, dynamic> json) => EventEndedMessage();
}

class UnknownMessage extends WebSocketMessage {
  final Map<String, dynamic> data;
  UnknownMessage({required String type, required this.data}) : super(type: type);
}

class EventConfigResponse {
  final int configVersion;
  final Map<String, dynamic> map;
  final List<Zone> zones;
  final List<Map<String, dynamic>> pois;
  final Map<String, dynamic> thresholds;
  final SamplingPolicy sampling;
  final Map<String, dynamic> copy;

  const EventConfigResponse({
    required this.configVersion,
    required this.map,
    required this.zones,
    required this.pois,
    required this.thresholds,
    required this.sampling,
    required this.copy,
  });

  factory EventConfigResponse.fromJson(Map<String, dynamic> json) {
    return EventConfigResponse(
      configVersion: json['config_version'] as int,
      map: json['map'] as Map<String, dynamic>? ?? {},
      zones: (json['zones'] as List?)?.map((z) => Zone.fromJson(z as Map<String, dynamic>)).toList() ?? [],
      pois: (json['pois'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      thresholds: json['thresholds'] as Map<String, dynamic>? ?? {},
      sampling: SamplingPolicy.fromJson(json['sampling'] as Map<String, dynamic>),
      copy: json['copy'] as Map<String, dynamic>? ?? {},
    );
  }
}

class EventInfo {
  final String id;
  final String name;
  final String type;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final String venueName;

  EventInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.venueName,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      venueName: json['venue_name'] as String,
    );
  }
}

class JoinResponse {
  final String sessionToken;
  final String refreshToken;
  final String participantId;
  final EventInfo event;
  final EventConfigResponse config;

  JoinResponse({
    required this.sessionToken,
    required this.refreshToken,
    required this.participantId,
    required this.event,
    required this.config,
  });

  factory JoinResponse.fromJson(Map<String, dynamic> json) {
    return JoinResponse(
      sessionToken: json['session_token'] as String,
      refreshToken: json['refresh_token'] as String,
      participantId: json['participant_id'] as String,
      event: EventInfo.fromJson(json['event'] as Map<String, dynamic>),
      config: EventConfigResponse.fromJson(json['config'] as Map<String, dynamic>),
    );
  }
}

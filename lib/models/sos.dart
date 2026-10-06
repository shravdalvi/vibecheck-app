/// SOS / Emergency Alert model

class SOSSubmission {
  final String recordId; // UUID v4; idempotency key
  final String eventId;
  final String participantId;
  final double latitude;
  final double longitude;
  final double accuracyM;
  final DateTime timestamp;
  final String sosType; // MEDICAL, SECURITY, CROWD_CRUSH, LOST_CHILD, OTHER
  final String? notes;

  const SOSSubmission({
    required this.recordId,
    required this.eventId,
    required this.participantId,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.timestamp,
    required this.sosType,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'record_id': recordId,
    'event_id': eventId,
    'participant_id': participantId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy_m': accuracyM,
    'timestamp': timestamp.toIso8601String(),
    'sos_type': sosType,
    'notes': notes,
  };
}

/// SOS Status response
class SOSStatus {
  final String sosId;
  final String status; // SENDING, SENT, RECEIVED, ACKNOWLEDGED
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final String? message;

  const SOSStatus({
    required this.sosId,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
    this.message,
  });

  bool get isSending => status == 'SENDING';
  bool get isSent => status == 'SENT';
  bool get isReceived => status == 'RECEIVED';
  bool get isAcknowledged => status == 'ACKNOWLEDGED';

  factory SOSStatus.fromJson(Map<String, dynamic> json) {
    return SOSStatus(
      sosId: json['sos_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'sos_id': sosId,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'acknowledged_at': acknowledgedAt?.toIso8601String(),
    'message': message,
  };
}

/// Participant (anonymous, event-scoped)

class Participant {
  final String participantId; // Server-issued, opaque, event-scoped
  final String eventId;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiresAt;
  final DateTime joinedAt;
  final String? currentZone;
  final bool isSimulated;

  const Participant({
    required this.participantId,
    required this.eventId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.joinedAt,
    this.currentZone,
    this.isSimulated = false,
  });

  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiresAt);
  bool get isTokenExpiringSoon =>
      DateTime.now().add(const Duration(minutes: 5)).isAfter(tokenExpiresAt);

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantId: json['participant_id'] as String,
      eventId: json['event_id'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenExpiresAt: DateTime.now().add(
        Duration(seconds: json['expires_in'] as int),
      ),
      joinedAt: DateTime.now().toUtc(),
      currentZone: json['current_zone'] as String?,
      isSimulated: json['is_simulated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'participant_id': participantId,
    'event_id': eventId,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_expires_at': tokenExpiresAt.toIso8601String(),
    'joined_at': joinedAt.toIso8601String(),
    'current_zone': currentZone,
    'is_simulated': isSimulated,
  };

  Participant copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    String? currentZone,
  }) {
    return Participant(
      participantId: participantId,
      eventId: eventId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      joinedAt: joinedAt,
      currentZone: currentZone ?? this.currentZone,
      isSimulated: isSimulated,
    );
  }
}

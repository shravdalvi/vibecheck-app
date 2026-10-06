/// Recommendation model (server-issued advisory)

class Recommendation {
  final String recommendationId;
  final int version;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String targetZoneId;
  final String? targetZoneName;
  final String? currentZoneId;
  final String? route;
  final int? estWalkTimeSeconds;
  final String reason;
  final String priority; // LOW, NORMAL, HIGH, CRITICAL

  const Recommendation({
    required this.recommendationId,
    required this.version,
    required this.createdAt,
    required this.expiresAt,
    required this.targetZoneId,
    this.targetZoneName,
    this.currentZoneId,
    this.route,
    this.estWalkTimeSeconds,
    required this.reason,
    required this.priority,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
  bool get isValid => !isExpired;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      recommendationId: json['recommendation_id'] as String,
      version: json['version'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      targetZoneId: json['target_zone_id'] as String,
      targetZoneName: json['target_zone_name'] as String?,
      currentZoneId: json['current_zone_id'] as String?,
      route: json['route'] as String?,
      estWalkTimeSeconds: json['est_walk_time_seconds'] as int?,
      reason: json['reason'] as String,
      priority: json['priority'] as String? ?? 'NORMAL',
    );
  }

  Map<String, dynamic> toJson() => {
    'recommendation_id': recommendationId,
    'version': version,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'target_zone_id': targetZoneId,
    'target_zone_name': targetZoneName,
    'current_zone_id': currentZoneId,
    'route': route,
    'est_walk_time_seconds': estWalkTimeSeconds,
    'reason': reason,
    'priority': priority,
  };

  Recommendation copyWith({String? reason, DateTime? expiresAt}) {
    return Recommendation(
      recommendationId: recommendationId,
      version: version,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      targetZoneId: targetZoneId,
      targetZoneName: targetZoneName,
      currentZoneId: currentZoneId,
      route: route,
      estWalkTimeSeconds: estWalkTimeSeconds,
      reason: reason ?? this.reason,
      priority: priority,
    );
  }
}

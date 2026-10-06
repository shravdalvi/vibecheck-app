import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'adapters/api_adapter.dart';
import '../providers/config_provider.dart';
import '../providers/mock_providers.dart';
import '../ui/crowd_level_chip.dart';

class WebSocketService {
  final String wsBaseUrl;
  final String eventId;
  final String accessToken;
  final Ref ref;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  bool _isDisposed = false;
  int _reconnectDelayMs = 1000;
  static const int maxReconnectDelayMs = 30000;

  WebSocketService({
    required this.wsBaseUrl,
    required this.eventId,
    required this.accessToken,
    required this.ref,
  }) {
    _connect();
  }

  void _connect() {
    if (_isDisposed) return;
    
    final uri = Uri.parse('$wsBaseUrl/events/$eventId/stream?token=$accessToken');
    try {
      _channel = WebSocketChannel.connect(uri);
      
      // On reconnect, poll config and status once
      if (_reconnectDelayMs > 1000) {
        // Just triggered a reconnect, so force a config fetch to make sure we didn't miss anything
        ref.read(configProvider.notifier).fetchConfig();
      }

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      
      _reconnectDelayMs = 1000; // Reset backoff on successful connect
      _startHeartbeat();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    if (message is String) {
      try {
        final Map<String, dynamic> json = jsonDecode(message);
        final wsMessage = WebSocketMessage.fromJson(json);
        _handleWebSocketMessage(wsMessage);
      } catch (e) {
        // Parse error
      }
    }
  }

  void _handleWebSocketMessage(WebSocketMessage message) {
    if (message is HeartbeatMessage) {
      // Respond to heartbeat if necessary (usually ping/pong is handled at protocol level, 
      // but if application-level is needed, we'd send something back).
    } else if (message is ConfigUpdateMessage) {
      ref.read(configProvider.notifier).checkVersion(message.configVersion);
    } else if (message is AnnouncementMessage) {
      ref.read(announcementProvider.notifier).state = AnnouncementState(
        message: message.text,
        timeAgo: 'Just now', // Use server_time for freshness in real implementation
        isUrgent: message.urgent,
      );
    } else if (message is RecommendationMessage) {
      ref.read(recommendationProvider.notifier).state = RecommendationState(
        message: message.recommendation.message,
        targetZone: message.recommendation.targetZone,
        targetLevel: CrowdLevel.low,
        walkTime: '${message.recommendation.walkMinutes} min walk',
        expiryLabel: 'Expires soon',
      );
    } else if (message is EventStartedMessage) {
      // Handle event start
    } else if (message is EventEndedMessage) {
      // Cleanup
      _cleanupEvent();
    }
  }

  void _cleanupEvent() {
    // Existing cleanup: stop tracking, clear token, ID, cache, queue
    // For now we just close the socket.
    dispose();
  }

  void _onError(Object error) {
    _scheduleReconnect();
  }

  void _onDone() {
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    _cleanUpConnection();

    _reconnectTimer?.cancel();
    
    // Exponential backoff with jitter
    final random = Random();
    final jitter = random.nextDouble() * 0.2 + 0.9;
    _reconnectDelayMs = min((_reconnectDelayMs * 2 * jitter).toInt(), maxReconnectDelayMs);

    _reconnectTimer = Timer(Duration(milliseconds: _reconnectDelayMs), () {
      _connect();
    });
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      // Send application-level ping if backend requires it
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({'type': 'HEARTBEAT'}));
      }
    });
  }

  void _cleanUpConnection() {
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _cleanUpConnection();
  }
}


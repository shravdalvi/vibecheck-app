import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../networking/api_client.dart';

enum SharingStatus { sharing, paused, off }

class SharingStatusNotifier extends Notifier<SharingStatus> {
  late ApiClient _apiClient;
  late String _eventId;
  late String _accessToken;

  @override
  SharingStatus build() {
    _apiClient = ApiClient(baseUrl: 'http://localhost:5000/api');
    _eventId = 'test-event';
    _accessToken = 'dummy-token';
    _flushQueue();
    return SharingStatus.sharing;
  }

  void setup(ApiClient client, String eventId, String token) {
    _apiClient = client;
    _eventId = eventId;
    _accessToken = token;
    _flushQueue();
  }

  Future<void> updateStatus(SharingStatus newStatus) async {
    if (state == newStatus) return;
    state = newStatus;

    String apiState = 'ACTIVE';
    if (newStatus == SharingStatus.paused) apiState = 'PAUSED';
    if (newStatus == SharingStatus.off) apiState = 'LEFT';

    try {
      await _apiClient.updatePresence(
        eventId: _eventId,
        state: apiState,
        accessToken: _accessToken,
      );
    } catch (e) {
      await _queuePresenceUpdate(apiState);
    }
  }

  Future<void> _queuePresenceUpdate(String state) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/presence_queue.txt');
      await file.writeAsString(state); // We only care about the latest state
    } catch (_) {}
  }

  Future<void> _flushQueue() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/presence_queue.txt');
      if (await file.exists()) {
        final stateToSync = await file.readAsString();
        if (stateToSync.isNotEmpty) {
          await _apiClient.updatePresence(
            eventId: _eventId,
            state: stateToSync,
            accessToken: _accessToken,
          );
          await file.delete();
        }
      }
    } catch (_) {}
  }
}

final sharingStatusProvider = NotifierProvider<SharingStatusNotifier, SharingStatus>(() => SharingStatusNotifier());

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'English';
  set state(String value) => super.state = value;
}
final languageProvider = NotifierProvider<LanguageNotifier, String>(() => LanguageNotifier());

final appVersionProvider = Provider<String>((ref) => '1.0.0 (42)');

final developerModeProvider = Provider<bool>((ref) => true); // Mock true for dev/demo

class ConnectionMetrics {
  final String gps;
  final String network;
  final String lastUpload;
  final String waitingToSend;
  final String batteryMode;

  const ConnectionMetrics({
    required this.gps,
    required this.network,
    required this.lastUpload,
    required this.waitingToSend,
    required this.batteryMode,
  });
}

final connectionMetricsProvider = Provider<ConnectionMetrics>((ref) => const ConnectionMetrics(
  gps: 'Good',
  network: 'Online',
  lastUpload: '12 s ago',
  waitingToSend: '0',
  batteryMode: 'Normal',
));

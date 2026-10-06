import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SharingStatus { sharing, paused, off }

class SharingStatusNotifier extends Notifier<SharingStatus> {
  @override
  SharingStatus build() => SharingStatus.sharing;
  set state(SharingStatus value) => super.state = value;
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

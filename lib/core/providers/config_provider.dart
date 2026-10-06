import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../networking/api_client.dart';
import '../networking/adapters/api_adapter.dart';

// State holding the latest config
class AppConfigState {
  final int version;
  final EventConfigResponse? config;
  final bool isLoading;

  AppConfigState({
    this.version = 0,
    this.config,
    this.isLoading = false,
  });

  AppConfigState copyWith({
    int? version,
    EventConfigResponse? config,
    bool? isLoading,
  }) {
    return AppConfigState(
      version: version ?? this.version,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ConfigNotifier extends Notifier<AppConfigState> with WidgetsBindingObserver {
  late ApiClient _apiClient;
  late String _eventId;
  late String _accessToken;

  @override
  AppConfigState build() {
    WidgetsBinding.instance.addObserver(this);
    // These would normally be injected or read from other providers
    _apiClient = ApiClient(baseUrl: 'http://localhost:5000/api');
    _eventId = 'test-event';
    _accessToken = 'dummy-token';
    return AppConfigState();
  }

  void setup(ApiClient client, String eventId, String token) {
    _apiClient = client;
    _eventId = eventId;
    _accessToken = token;
  }

  Future<void> checkVersion(int newVersion) async {
    if (newVersion > state.version && !state.isLoading) {
      await fetchConfig();
    }
  }

  Future<void> fetchConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await _apiClient.getConfig(
        eventId: _eventId,
        accessToken: _accessToken,
      );
      state = state.copyWith(
        version: config.configVersion,
        config: config,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Log or handle error
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      // In a real app we'd get the actual latest version from a lightweight ping or rely on WS
      // For now, we can just fetch to ensure it's fresh
      fetchConfig();
    }
  }
}

final configProvider = NotifierProvider<ConfigNotifier, AppConfigState>(() => ConfigNotifier());


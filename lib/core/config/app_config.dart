
enum Flavor { dev, staging, prod, demo }

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  Flavor get flavor {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return Flavor.values.firstWhere(
      (e) => e.toString().split('.').last == flavorStr,
      orElse: () => Flavor.dev,
    );
  }

  String get apiBaseUrl => const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  String get wsBaseUrl => const String.fromEnvironment('WS_BASE_URL', defaultValue: 'ws://localhost:8000');
  
  bool get isSimulationMode => const bool.fromEnvironment('SIMULATION_MODE', defaultValue: false) && flavor != Flavor.prod;
  
  int get queueMaxSize => const int.fromEnvironment('QUEUE_MAX_SIZE_RECORDS', defaultValue: 10000);
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/telemetry.dart';
import 'api_client.dart';
import '../providers/mock_providers.dart';
import '../providers/config_provider.dart';
import '../ui/crowd_level_chip.dart';

class TelemetryUploader {
  final ApiClient apiClient;
  final Ref ref;
  final String accessToken;
  
  List<TelemetryRecord> _queue = [];
  bool _isFlushing = false;
  Timer? _flushTimer;
  File? _storageFile;
  
  static const int maxBatchSize = 50;
  static const int baseDelayMs = 1000;
  static const int maxDelayMs = 30000;
  int _currentBackoff = baseDelayMs;

  TelemetryUploader(this.apiClient, this.ref, this.accessToken) {
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _storageFile = File('${dir.path}/telemetry_queue.json');
      if (await _storageFile!.exists()) {
        final contents = await _storageFile!.readAsString();
        if (contents.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(contents);
          _queue = jsonList.map((j) => TelemetryRecord.fromJson(j)).toList();
        }
      }
    } catch (e) {
      // Ignore storage init errors
    }
    // Start periodic flush
    _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) => flush());
  }

  Future<void> _persistQueue() async {
    if (_storageFile == null) return;
    try {
      final jsonList = _queue.map((r) => r.toJson()).toList();
      await _storageFile!.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Ignore persist errors
    }
  }

  void enqueue(TelemetryRecord record) {
    _queue.add(record);
    _persistQueue();
    if (_queue.length >= maxBatchSize) {
      flush();
    }
  }

  Future<void> flush() async {
    if (_isFlushing || _queue.isEmpty) return;
    _isFlushing = true;

    try {
      while (_queue.isNotEmpty) {
        final batchSize = min(_queue.length, maxBatchSize);
        final batchRecords = _queue.sublist(0, batchSize);
        
        final batch = TelemetryBatch(records: batchRecords);
        final response = await apiClient.submitTelemetry(batch: batch, accessToken: accessToken);
        
        // Success! Remove from queue and reset backoff
        _queue.removeRange(0, batchSize);
        _currentBackoff = baseDelayMs;
        await _persistQueue();
        
        // Update Riverpod Providers with the response!
        _handleResponse(response);
      }
    } catch (e) {
      // Exponential backoff with jitter
      final random = Random();
      final jitter = random.nextDouble() * 0.2 + 0.9; // 0.9 to 1.1
      _currentBackoff = min((_currentBackoff * 2 * jitter).toInt(), maxDelayMs);
      
      // Schedule retry
      Future.delayed(Duration(milliseconds: _currentBackoff), flush);
    } finally {
      _isFlushing = false;
    }
  }

  void _handleResponse(TelemetryBatchResponse response) {
    // 1. Update current zone
    CrowdLevel level = CrowdLevel.low;
    switch (response.zoneLevel.toUpperCase()) {
      case 'MODERATE': level = CrowdLevel.moderate; break;
      case 'HIGH': level = CrowdLevel.high; break;
      case 'CRITICAL': level = CrowdLevel.critical; break;
    }
    
    ref.read(currentZoneProvider.notifier).state = CurrentZoneState(
      name: response.zone,
      level: level,
      fillPercentage: level == CrowdLevel.high ? 0.8 : 0.4, // Mock calculation
      lastUpdated: 'Just now',
    );

    // 2. Update recommendation if present
    if (response.recommendation != null) {
      ref.read(recommendationProvider.notifier).state = RecommendationState(
        message: response.recommendation!.message,
        targetZone: response.recommendation!.targetZone,
        targetLevel: CrowdLevel.low, // Assume low for recommendations
        walkTime: '${response.recommendation!.walkMinutes} min walk',
        expiryLabel: 'Expires soon',
      );
    }

    // 3. Check config version atomically
    ref.read(configProvider.notifier).checkVersion(response.configVersion);
  }

  void dispose() {
    _flushTimer?.cancel();
  }
}


import 'package:dio/dio.dart';
import 'adapters/api_adapter.dart';
import '../../models/event.dart';
import '../../models/participant.dart';
import '../../models/telemetry.dart';
import '../../models/recommendation.dart';

class ApiClient implements ApiAdapter {
  final Dio _dio;

  ApiClient({required String baseUrl, Dio? dio}) 
    : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)));

  @override
  Future<TelemetryBatchResponse> submitTelemetry({
    required TelemetryBatch batch,
    required String accessToken,
  }) async {
    if (batch.records.isEmpty) {
      throw Exception('Empty batch');
    }
    
    // We get the eventId from the first record
    final eventId = batch.records.first.eventId;
    
    final response = await _dio.post(
      '/events/$eventId/telemetry',
      data: batch.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    
    // Actually, contract says Request: { "records": [ ... ] }
    // Let me fix that. The body above should be batch.toJson(), which is { 'records': [...] }
    
    return TelemetryBatchResponse.fromJson(response.data);
  }

  @override
  Future<JoinResponse> joinEvent({required String eventCode, required String appVersion}) async {
    final response = await _dio.post(
      '/events/join',
      data: {'code': eventCode},
    );
    return JoinResponse.fromJson(response.data);
  }
  
  @override
  Future<Participant> refreshToken({required String participantId, required String refreshToken}) async => throw UnimplementedError();
  
  @override
  Future<EventConfigResponse> getConfig({required String eventId, required String accessToken}) async {
    final response = await _dio.get(
      '/events/$eventId/config',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return EventConfigResponse.fromJson(response.data);
  }
  
  @override
  Future<void> updatePresence({required String eventId, required String state, required String accessToken}) async {
    await _dio.post(
      '/events/$eventId/presence',
      data: {'state': state},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  @override
  Future<PollResponse> pollForUpdates({required String accessToken}) async => throw UnimplementedError();
  
  @override
  Future<List<Recommendation>> getRecommendations({required String accessToken}) async => throw UnimplementedError();
  
  @override
  Future<void> ackRecommendation({required String recommendationId, required String accessToken}) async => throw UnimplementedError();
  
  @override
  Stream<WebSocketMessage> openWebSocket({required String eventId, required String accessToken}) => throw UnimplementedError();
  
  @override
  Future<void> closeWebSocket({required String eventId}) async => throw UnimplementedError();
  
  @override
  Future<void> sendWebSocketAck({required String messageId, required String eventId}) async => throw UnimplementedError();
}

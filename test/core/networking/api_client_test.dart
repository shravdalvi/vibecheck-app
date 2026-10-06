import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:vibecheck/core/networking/api_client.dart';
import 'package:vibecheck/models/telemetry.dart';

class FakeDio extends Fake implements Dio {
  final Map<String, dynamic> fakeResponse;
  
  FakeDio(this.fakeResponse);

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (path == '/events/join') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: fakeResponse['join'] as T,
      );
    } else if (path.endsWith('/telemetry')) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: fakeResponse['telemetry'] as T,
      );
    } else if (path.endsWith('/presence')) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: fakeResponse['presence'] as T,
      );
    }
    throw UnimplementedError('Path not faked: $path');
  }
}

void main() {
  late ApiClient apiClient;
  late FakeDio fakeDio;

  setUp(() {
    fakeDio = FakeDio({
      'join': {
        'session_token': 'test_session',
        'refresh_token': 'test_refresh',
        'participant_id': 'test_participant',
        'event': {
          'id': 'evt_1',
          'name': 'Test Event',
          'type': 'concert',
          'status': 'active',
          'starts_at': '2026-01-01T18:00:00Z',
          'ends_at': '2026-01-01T23:00:00Z',
          'venue_name': 'Test Venue'
        },
        'config': {
          'config_version': 1,
          'map': {},
          'zones': [],
          'pois': [],
          'thresholds': {},
          'sampling': {},
          'copy': {}
        }
      },
      'telemetry': {
        'zone': 'Zone A',
        'zone_level': 'LOW',
        'config_version': 2,
        'event_status': 'active',
        'server_time': '2026-01-01T19:00:00Z'
      },
      'presence': {
        'status': 'ok'
      }
    });
    apiClient = ApiClient(baseUrl: 'http://test', dio: fakeDio);
  });

  group('ApiClient Tests', () {
    test('joinEvent returns correct response', () async {
      final response = await apiClient.joinEvent(eventCode: 'VC-123456', appVersion: '1.0.0');

      expect(response.sessionToken, 'test_session');
      expect(response.participantId, 'test_participant');
      expect(response.event.name, 'Test Event');
      expect(response.config.configVersion, 1);
    });

    test('submitTelemetry returns correct response', () async {
      final batch = TelemetryBatch(records: []);
      final response = await apiClient.submitTelemetry(
        eventId: 'evt_1',
        accessToken: 'token',
        batch: batch,
      );

      expect(response.zone, 'Zone A');
      expect(response.zoneLevel, 'LOW');
      expect(response.configVersion, 2);
    });

    test('updatePresence completes without error', () async {
      await expectLater(
        apiClient.updatePresence(
          eventId: 'evt_1',
          accessToken: 'token',
          state: 'PAUSED',
        ),
        completes,
      );
    });
  });
}

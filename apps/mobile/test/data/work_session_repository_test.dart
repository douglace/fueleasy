import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/error/failure.dart';
import 'package:fusy_mobile/data/work_session_repository.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late WorkSessionRepository repo;

  const base = 'http://test.local/api/v1/mobile/';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: base));
    adapter = DioAdapter(dio: dio);
    repo = WorkSessionRepository(dio);
  });

  Map<String, dynamic> paymentJson({String status = 'paid', String? ackedAt}) =>
      {
        'id': 1,
        'reference': 'FUSY-ABC12XYZ',
        'short_code': 'K9M2P5',
        'status': status,
        'via': 'dynamic',
        'fuel_type': 'gasoil',
        'amount': 15000,
        'failure_reason': null,
        'station_organization_id': 10,
        'pump_id': 2,
        'expires_at': '2026-07-01T12:10:00Z',
        'confirmed_at': '2026-07-01T12:05:30Z',
        'created_at': '2026-07-01T12:05:00Z',
        'alert_acknowledged_at': ackedAt,
      };

  test('pumps unwraps the data envelope into PumpRef entities', () async {
    adapter.onGet(
      'station/pumps',
      (server) => server.reply(200, {
        'data': [
          {
            'id': 2,
            'label': 'Pompe 1',
            'available_fuels': ['gasoil', 'super'],
          },
        ],
      }),
    );
    final pumps = await repo.pumps();
    expect(pumps, hasLength(1));
    expect(pumps.first.label, 'Pompe 1');
    expect(pumps.first.availableFuels, [FuelType.gasoil, FuelType.superFuel]);
  });

  test('open returns a fresh session QR', () async {
    adapter.onPost(
      'work-sessions',
      (server) => server.reply(201, {
        'work_session_id': 42,
        'pump_id': 2,
        'status': 'open',
        'qr': 'signed-qr-token',
        'expires_in': 60,
      }),
      data: Matchers.any,
    );
    final session = await repo.open(2);
    expect(session.workSessionId, 42);
    expect(session.qr, 'signed-qr-token');
    expect(session.expiresIn, 60);
  });

  test('currentQr maps a 404 (no open session) to NotFoundFailure', () async {
    adapter.onGet(
      'work-sessions/current/qr',
      (server) => server.reply(404, {'message': 'Aucune session ouverte.'}),
    );
    expect(() => repo.currentQr(), throwsA(isA<NotFoundFailure>()));
  });

  test('todaysPayments unwraps the data envelope', () async {
    adapter.onGet(
      'station/payments/today',
      (server) => server.reply(200, {
        'data': [paymentJson(ackedAt: '2026-07-01T12:06:00Z')],
      }),
    );
    final list = await repo.todaysPayments();
    expect(list, hasLength(1));
    expect(list.first.isAcknowledged, isTrue);
  });

  test('searchByCode returns null when not found', () async {
    adapter.onGet(
      'station/payments/search',
      (server) => server.reply(200, {'found': false}),
      queryParameters: {'code': '0000'},
    );
    final p = await repo.searchByCode('0000');
    expect(p, isNull);
  });

  test('searchByCode returns the payment with ack state unset', () async {
    adapter.onGet(
      'station/payments/search',
      (server) => server.reply(200, {'found': true, 'payment': paymentJson()}),
      queryParameters: {'code': 'K9M2P5'},
    );
    final p = await repo.searchByCode('K9M2P5');
    expect(p, isNotNull);
    expect(p!.isAcknowledged, isFalse);
  });

  test('acknowledge returns true on success', () async {
    adapter.onPost(
      'station/payments/1/ack',
      (server) => server.reply(200, {'acknowledged': true}),
    );
    final acked = await repo.acknowledge(1);
    expect(acked, isTrue);
  });
}

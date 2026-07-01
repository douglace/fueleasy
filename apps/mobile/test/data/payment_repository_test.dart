import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/error/failure.dart';
import 'package:fusy_mobile/data/payment_repository.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late PaymentRepository repo;

  const base = 'http://test.local/api/v1/mobile/';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: base));
    adapter = DioAdapter(dio: dio);
    repo = PaymentRepository(dio);
  });

  Map<String, dynamic> paymentJson(String status) => {
    'id': 789,
    'reference': 'FUSY-ABC12XYZ',
    'short_code': 'K9M2P5',
    'status': status,
    'via': 'dynamic',
    'fuel_type': 'gasoil',
    'amount': 50000,
    'failure_reason': null,
    'station_organization_id': 10,
    'pump_id': 2,
    'expires_at': '2026-07-01T12:10:00Z',
    'confirmed_at': status == 'paid' ? '2026-07-01T12:05:30Z' : null,
    'created_at': '2026-07-01T12:05:00Z',
  };

  // create/get/confirm sont enveloppés par Laravel dans {"data": {...}}
  // (PaymentResource rendue via ->response()) — vérifié en direct contre le
  // backend, contrairement aux endpoints qui embarquent la resource dans un
  // tableau construit à la main (search, by-key, today).
  test(
    'create unwraps the {data:...} envelope into a pending payment',
    () async {
      adapter.onPost(
        'payments',
        (server) => server.reply(201, {'data': paymentJson('pending')}),
        data: Matchers.any,
      );
      final p = await repo.create(
        qr: 'QR',
        fuelType: FuelType.gasoil,
        amount: 50000,
      );
      expect(p.id, 789);
      expect(p.status, PaymentStatus.pending);
      expect(p.shortCode, 'K9M2P5');
    },
  );

  test('get unwraps the {data:...} envelope', () async {
    adapter.onGet(
      'payments/789',
      (server) => server.reply(200, {'data': paymentJson('paid')}),
    );
    final p = await repo.get(789);
    expect(p.status, PaymentStatus.paid);
  });

  test('confirm unwraps the {data:...} envelope into a paid payment', () async {
    adapter.onPost(
      'payments/789/confirm',
      (server) => server.reply(200, {'data': paymentJson('paid')}),
      data: Matchers.any,
    );
    final p = await repo.confirm(
      paymentId: 789,
      pin: '1234',
      idempotencyKey: 'k',
    );
    expect(p.status, PaymentStatus.paid);
  });

  test('confirm maps a 422 invalid_pin to DomainFailure', () async {
    adapter.onPost(
      'payments/789/confirm',
      (server) => server.reply(422, {
        'message': 'PIN incorrect.',
        'reason': 'invalid_pin',
      }),
      data: Matchers.any,
    );

    expect(
      () => repo.confirm(paymentId: 789, pin: '0000', idempotencyKey: 'k'),
      throwsA(
        isA<DomainFailure>().having(
          (f) => f.paymentReason,
          'paymentReason',
          PaymentFailureReason.invalidPin,
        ),
      ),
    );
  });

  test('history parses the data envelope', () async {
    adapter.onGet(
      'payments',
      (server) => server.reply(200, {
        'data': [paymentJson('paid'), paymentJson('expired')],
      }),
    );
    final list = await repo.history();
    expect(list, hasLength(2));
    expect(list.first.status, PaymentStatus.paid);
  });

  test('findByIdempotencyKey returns null when not found', () async {
    adapter.onGet(
      'payments/by-key',
      (server) => server.reply(200, {'found': false}),
      queryParameters: {'idempotency_key': 'missing'},
    );
    final p = await repo.findByIdempotencyKey('missing');
    expect(p, isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/domain/enums.dart';

void main() {
  test('AuthSession.fromJson parses token and user', () {
    final s = AuthSession.fromJson({
      'token': 'abc',
      'user': {
        'id': 123,
        'name': 'Boris Mballa',
        'role': 'driver',
        'organization_id': 456,
      },
    });
    expect(s.token, 'abc');
    expect(s.user.id, 123);
    expect(s.user.role, Role.driver);
    expect(s.user.organizationId, 456);
  });

  test('MeProfile parses driver with budget', () {
    final me = MeProfile.fromJson({
      'id': 1,
      'name': 'Boris',
      'role': 'driver',
      'organization_id': 9,
      'budget': {
        'mode': 'monthly',
        'next_reset_at': '2026-08-01T00:00:00Z',
        'masked': true,
      },
      'enterprise_status': 'operational',
    });
    expect(me.role, Role.driver);
    expect(me.budget, isNotNull);
    expect(me.budget!.mode, BudgetMode.monthly);
    expect(me.budget!.masked, isTrue);
    expect(me.budget!.nextResetAt, isNotNull);
    expect(me.enterpriseStatus, 'operational');
  });

  test('MeProfile parses pompiste without budget', () {
    final me = MeProfile.fromJson({
      'id': 2,
      'name': 'Armand',
      'role': 'pompiste',
      'organization_id': 10,
    });
    expect(me.role, Role.pompiste);
    expect(me.budget, isNull);
    expect(me.enterpriseStatus, isNull);
  });

  test('ScanContext parses station, pump and fuels', () {
    final ctx = ScanContext.fromJson({
      'via': 'dynamic',
      'station': {'id': 10, 'name': 'Tradex Bonamoussadi'},
      'pump': {
        'id': 2,
        'label': 'Pompe 1',
        'available_fuels': ['gasoil', 'super'],
      },
      'pompiste_id': 5,
    });
    expect(ctx.via, QrType.dynamicQr);
    expect(ctx.station.name, 'Tradex Bonamoussadi');
    expect(ctx.pump.availableFuels, [FuelType.gasoil, FuelType.superFuel]);
    expect(ctx.pompisteId, 5);
  });

  test('Payment parses a paid payment with dates', () {
    final p = Payment.fromJson({
      'id': 789,
      'reference': 'FUSY-ABC12XYZ',
      'short_code': 'K9M2P5',
      'status': 'paid',
      'via': 'dynamic',
      'fuel_type': 'gasoil',
      'amount': 50000,
      'failure_reason': null,
      'station_organization_id': 10,
      'pump_id': 2,
      'expires_at': '2026-07-01T12:10:00Z',
      'confirmed_at': '2026-07-01T12:05:30Z',
      'created_at': '2026-07-01T12:05:00Z',
    });
    expect(p.status, PaymentStatus.paid);
    expect(p.amount, 50000);
    expect(p.failureReason, isNull);
    expect(p.confirmedAt, isNotNull);
  });

  test('Payment parses a failed payment with reason', () {
    final p = Payment.fromJson({
      'id': 1,
      'reference': 'FUSY-X',
      'short_code': 'AAAAAA',
      'status': 'pending',
      'via': 'fixed',
      'fuel_type': 'super',
      'amount': 15000,
      'failure_reason': 'invalid_pin',
      'station_organization_id': null,
      'pump_id': null,
      'expires_at': null,
      'confirmed_at': null,
      'created_at': null,
    });
    expect(p.failureReason, PaymentFailureReason.invalidPin);
    expect(p.confirmedAt, isNull);
  });
}

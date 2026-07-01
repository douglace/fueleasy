import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/enums.dart';

void main() {
  test('Role parses known and unknown values', () {
    expect(Role.fromValue('driver'), Role.driver);
    expect(Role.fromValue('pompiste'), Role.pompiste);
    expect(Role.fromValue('fusy_admin'), Role.fusyAdmin);
    expect(Role.fromValue('???'), Role.unknown);
    expect(Role.fromValue(null), Role.unknown);
    expect(Role.driver.isDriver, isTrue);
    expect(Role.pompiste.isPompiste, isTrue);
  });

  test('PaymentStatus covers the real backend states', () {
    for (final v in ['pending', 'paid', 'expired', 'failed', 'refunded']) {
      expect(PaymentStatus.fromValue(v).value, v);
    }
    expect(PaymentStatus.fromValue('validated'), PaymentStatus.unknown);
  });

  test('FuelType maps super without using a reserved word', () {
    expect(FuelType.fromValue('super'), FuelType.superFuel);
    expect(FuelType.superFuel.label, 'Super');
    expect(FuelType.fromValue('gasoil'), FuelType.gasoil);
  });

  test('PaymentFailureReason parses the full set + unknown', () {
    expect(
      PaymentFailureReason.fromValue('station_not_authorized'),
      PaymentFailureReason.stationNotAuthorized,
    );
    expect(
      PaymentFailureReason.fromValue('invalid_pin'),
      PaymentFailureReason.invalidPin,
    );
    expect(PaymentFailureReason.fromValue(null), PaymentFailureReason.unknown);
    expect(
      PaymentFailureReason.fromValue('new_reason'),
      PaymentFailureReason.unknown,
    );
  });

  test('QrType handles dynamic/fixed', () {
    expect(QrType.fromValue('dynamic'), QrType.dynamicQr);
    expect(QrType.fromValue('fixed'), QrType.fixed);
  });
}

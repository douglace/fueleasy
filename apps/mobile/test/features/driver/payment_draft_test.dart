import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:fusy_mobile/features/driver/models/payment_draft.dart';

void main() {
  final station = const StationRef(id: 10, name: 'Tradex Bonamoussadi');
  final pump = const PumpRef(
    id: 2,
    label: 'Pompe 1',
    availableFuels: [FuelType.gasoil, FuelType.superFuel],
  );

  test('a fresh draft is incomplete', () {
    final draft = PaymentDraft(qr: 'QR', station: station, pump: pump);
    expect(draft.isComplete, isFalse);
  });

  test('a draft is complete once fuel type and a positive amount are set', () {
    final draft = PaymentDraft(
      qr: 'QR',
      station: station,
      pump: pump,
    ).copyWith(fuelType: FuelType.superFuel, amount: 15000);
    expect(draft.isComplete, isTrue);
  });

  test('a zero amount does not make the draft complete', () {
    final draft = PaymentDraft(
      qr: 'QR',
      station: station,
      pump: pump,
    ).copyWith(fuelType: FuelType.gasoil, amount: 0);
    expect(draft.isComplete, isFalse);
  });

  test('copyWith preserves fields that are not overridden', () {
    final draft = PaymentDraft(
      qr: 'QR',
      station: station,
      pump: pump,
      fuelType: FuelType.gasoil,
      amount: 10000,
      note: 'LT-482-AA',
    );
    final updated = draft.copyWith(amount: 20000);
    expect(updated.fuelType, FuelType.gasoil);
    expect(updated.amount, 20000);
    expect(updated.note, 'LT-482-AA');
  });
}

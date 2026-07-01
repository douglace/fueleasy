import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/widgets/status_badge.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/attendant/widgets/ack_status_badge.dart';

void main() {
  Payment payment({String? ackedAt}) => Payment.fromJson({
    'id': 1,
    'reference': 'FUSY-X',
    'short_code': 'K9M2P5',
    'status': 'paid',
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
  });

  test('a fresh payment is presented as "À accuser"', () {
    final p = ackPresentation(payment());
    expect(p.label, 'À accuser');
    expect(p.tone, StatusTone.warning);
  });

  test('an acknowledged payment is presented as "Accusé"', () {
    final p = ackPresentation(payment(ackedAt: '2026-07-01T12:06:00Z'));
    expect(p.label, 'Accusé');
    expect(p.tone, StatusTone.success);
  });

  test(
    'Payment.copyWith sets alertAcknowledgedAt without touching other fields',
    () {
      final original = payment();
      expect(original.isAcknowledged, isFalse);

      final now = DateTime(2026, 7, 1, 12, 30);
      final acked = original.copyWith(alertAcknowledgedAt: now);

      expect(acked.isAcknowledged, isTrue);
      expect(acked.alertAcknowledgedAt, now);
      expect(acked.id, original.id);
      expect(acked.shortCode, original.shortCode);
      expect(acked.amount, original.amount);
    },
  );
}

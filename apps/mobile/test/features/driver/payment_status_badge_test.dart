import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/widgets/status_badge.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:fusy_mobile/features/driver/widgets/payment_status_badge.dart';

void main() {
  test('every real payment status maps to a non-empty label', () {
    final expected = {
      PaymentStatus.pending: ('À confirmer', StatusTone.info),
      PaymentStatus.paid: ('Payée', StatusTone.success),
      PaymentStatus.expired: ('Expirée', StatusTone.neutral),
      PaymentStatus.failed: ('Échouée', StatusTone.error),
      PaymentStatus.refunded: ('Remboursée', StatusTone.info),
    };

    for (final entry in expected.entries) {
      final presentation = paymentStatusPresentation(entry.key);
      expect(presentation.label, entry.value.$1);
      expect(presentation.tone, entry.value.$2);
    }
  });

  test('unknown status never crashes and stays neutral', () {
    final presentation = paymentStatusPresentation(PaymentStatus.unknown);
    expect(presentation.label, isNotEmpty);
    expect(presentation.tone, StatusTone.neutral);
  });
}

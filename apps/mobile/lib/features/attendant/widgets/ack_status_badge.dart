import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities.dart';

/// Libellé + ton selon que le pompiste a déjà accusé réception du paiement.
({String label, StatusTone tone}) ackPresentation(Payment payment) {
  return payment.isAcknowledged
      ? (label: 'Accusé', tone: StatusTone.success)
      : (label: 'À accuser', tone: StatusTone.warning);
}

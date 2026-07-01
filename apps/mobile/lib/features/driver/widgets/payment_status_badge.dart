import '../../../core/widgets/status_badge.dart';
import '../../../domain/enums.dart';

/// Libellé + ton pour chaque état réel de paiement
/// (`app/Domain/Payments/PaymentStatus.php`).
({String label, StatusTone tone}) paymentStatusPresentation(
  PaymentStatus status,
) => switch (status) {
  PaymentStatus.pending => (label: 'À confirmer', tone: StatusTone.info),
  PaymentStatus.paid => (label: 'Payée', tone: StatusTone.success),
  PaymentStatus.expired => (label: 'Expirée', tone: StatusTone.neutral),
  PaymentStatus.failed => (label: 'Échouée', tone: StatusTone.error),
  PaymentStatus.refunded => (label: 'Remboursée', tone: StatusTone.info),
  PaymentStatus.unknown => (label: '—', tone: StatusTone.neutral),
};

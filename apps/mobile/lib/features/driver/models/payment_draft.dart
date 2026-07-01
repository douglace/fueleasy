import '../../../domain/entities.dart';
import '../../../domain/enums.dart';

/// Brouillon local (non persisté côté serveur) construit après un scan réussi,
/// tant que le chauffeur saisit montant/carburant et n'a pas encore confirmé
/// le récapitulatif. Devient un vrai [Payment] `pending` via `POST /payments`.
class PaymentDraft {
  const PaymentDraft({
    required this.qr,
    required this.station,
    required this.pump,
    this.fuelType,
    this.amount,
    this.note,
  });

  final String qr;
  final StationRef station;
  final PumpRef pump;
  final FuelType? fuelType;
  final int? amount;
  final String? note;

  bool get isComplete => fuelType != null && amount != null && amount! > 0;

  PaymentDraft copyWith({FuelType? fuelType, int? amount, String? note}) {
    return PaymentDraft(
      qr: qr,
      station: station,
      pump: pump,
      fuelType: fuelType ?? this.fuelType,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}

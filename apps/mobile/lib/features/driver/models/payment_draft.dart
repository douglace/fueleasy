import '../../../domain/entities.dart';
import '../../../domain/enums.dart';

/// Brouillon local (non persisté côté serveur) construit après un scan réussi
/// — ou une saisie manuelle du code pompe —, tant que le chauffeur saisit
/// montant/carburant et n'a pas encore confirmé le récapitulatif. Devient un
/// vrai [Payment] `pending` via `POST /payments`.
///
/// Exactement un des deux identifiants ([qr] ou [code]) est renseigné : il est
/// rejoué tel quel au `POST /payments`, qui re-résout le contexte côté serveur.
class PaymentDraft {
  const PaymentDraft({
    this.qr,
    this.code,
    required this.station,
    required this.pump,
    this.fuelType,
    this.amount,
    this.note,
  }) : assert(
         (qr == null) != (code == null),
         'PaymentDraft attend soit un QR, soit un code pompe.',
       );

  final String? qr;
  final String? code;
  final StationRef station;
  final PumpRef pump;
  final FuelType? fuelType;
  final int? amount;
  final String? note;

  bool get isComplete => fuelType != null && amount != null && amount! > 0;

  PaymentDraft copyWith({FuelType? fuelType, int? amount, String? note}) {
    return PaymentDraft(
      qr: qr,
      code: code,
      station: station,
      pump: pump,
      fuelType: fuelType ?? this.fuelType,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}

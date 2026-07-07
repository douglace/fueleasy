/// Le franc CFA (XAF) n'a pas de sous-unite : les montants sont des entiers.
/// Format d'affichage : `15 000 FCFA` ou le separateur de milliers et l'espace
/// avant `FCFA` sont des espaces insecables (U+00A0), pour ne jamais couper un
/// montant en fin de ligne. Deterministe, independant de la locale.
final String _nbsp = String.fromCharCode(0xA0);

String formatFcfa(int amount) => '${formatFcfaDigits(amount)}${_nbsp}FCFA';

/// Montant formaté sans le suffixe FCFA — pour les affichages ou le suffixe
/// est porté par un autre élément (champ de saisie, AmountDisplay).
String formatFcfaDigits(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_nbsp);
    buffer.write(digits[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign$buffer';
}

/// Le franc CFA (XAF) n'a pas de sous-unite : les montants sont des entiers.
/// Format d'affichage : `15 000 FCFA` ou le separateur de milliers et l'espace
/// avant `FCFA` sont des espaces insecables (U+00A0), pour ne jamais couper un
/// montant en fin de ligne. Deterministe, independant de la locale.
final String _nbsp = String.fromCharCode(0xA0);

String formatFcfa(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_nbsp);
    buffer.write(digits[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign$buffer${_nbsp}FCFA';
}

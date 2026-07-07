import 'package:flutter/services.dart';

/// Retour haptique Fusy — trois intentions seulement, pour ne pas banaliser
/// la vibration : tap (sélection), succès (paiement, révélation), erreur.
abstract final class AppHaptics {
  static void tap() => HapticFeedback.selectionClick();

  static void success() => HapticFeedback.mediumImpact();

  static void error() => HapticFeedback.heavyImpact();
}

/// Grille d'espacement et rayons Fusy.
/// Grille : 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
  static const huge = 64.0;

  /// Marge d'écran mobile.
  static const screenMargin = 16.0;

  /// Cible tactile minimale.
  static const minTouchTarget = 48.0;
}

/// Rayons de coin.
abstract final class AppRadii {
  static const field = 8.0;
  static const button = 8.0;
  static const card = 12.0;
  static const modal = 16.0;
  static const sheetTop = 24.0;
}

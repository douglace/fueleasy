import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Ombres Fusy — une seule couleur (shadowNavy), deux niveaux d'élévation.
/// En liste, rester sur `card` (blur ≤ 12) pour préserver les 60 fps.
abstract final class AppShadows {
  static const card = [
    BoxShadow(
      color: AppColors.shadowNavy,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Réservé aux cartes héro isolées (budget, QR session) — jamais en liste.
  static const raised = [
    BoxShadow(
      color: AppColors.shadowNavy,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

/// Dégradés de marque.
abstract final class AppGradients {
  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navyDark, AppColors.navy, AppColors.navyLight],
  );
}

/// Durées standard des micro-interactions (150–400 ms).
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

abstract final class AppCurves {
  static const emphasized = Curves.easeOutCubic;
}

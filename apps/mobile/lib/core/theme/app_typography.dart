import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Échelle typographique Fusy — police unique Manrope (400–700).
/// Source : design-briefs/00-shared/brand-and-ui-system.md.
abstract final class AppTypography {
  static TextStyle _manrope(
    double size,
    double height,
    FontWeight weight, {
    Color color = AppColors.neutral900,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle get display => _manrope(32, 40, FontWeight.w700);
  static TextStyle get title1 =>
      _manrope(28, 36, FontWeight.w700).copyWith(letterSpacing: -0.3);
  static TextStyle get title2 =>
      _manrope(22, 30, FontWeight.w700).copyWith(letterSpacing: -0.3);
  static TextStyle get title3 =>
      _manrope(18, 26, FontWeight.w600).copyWith(letterSpacing: -0.3);
  static TextStyle get bodyLarge => _manrope(16, 24, FontWeight.w400);
  static TextStyle get body => _manrope(14, 22, FontWeight.w400);
  static TextStyle get label =>
      _manrope(12, 16, FontWeight.w600, color: AppColors.neutral700);
  static TextStyle get caption =>
      _manrope(11, 16, FontWeight.w500, color: AppColors.neutral500);

  /// Chiffres tabulaires — pour montants, codes, dates et colonnes numériques.
  static const tabular = FontFeature.tabularFigures();

  static TextStyle get amount =>
      display.copyWith(fontFeatures: const [tabular]);

  /// Montant héro (budget, succès de paiement). w700 max : Manrope n'est
  /// chargée qu'en 400–700, un poids supplémentaire coûterait un fetch réseau.
  static TextStyle get amountHero => _manrope(
    40,
    48,
    FontWeight.w700,
  ).copyWith(fontFeatures: const [tabular], letterSpacing: -0.5);

  /// Applique la couleur `onNavy` — texte posé sur le header navy.
  static TextStyle onNavy(TextStyle style) =>
      style.copyWith(color: AppColors.onNavy);

  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    headlineLarge: title1,
    headlineMedium: title2,
    titleLarge: title3,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    labelLarge: label,
    bodySmall: caption,
  );
}

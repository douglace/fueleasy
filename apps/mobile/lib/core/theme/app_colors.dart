import 'package:flutter/material.dart';

/// Palette Fusy — source : design-briefs/00-shared/brand-and-ui-system.md.
/// Ne pas introduire de couleur hors de cette liste.
abstract final class AppColors {
  // Marque
  static const navy = Color(0xFF003362);
  static const green = Color(0xFF00B473);
  static const greenDark = Color(0xFF007A4F);

  // Neutres
  static const neutral900 = Color(0xFF172B3A);
  static const neutral700 = Color(0xFF465B69);
  static const neutral600 = Color(0xFF5E6D78);
  static const neutral500 = Color(0xFF71808C);
  static const neutral300 = Color(0xFF9EAFBC);
  static const neutral200 = Color(0xFFDCE4EA);
  static const neutral100 = Color(0xFFEDF1F4);
  static const neutral50 = Color(0xFFF6F8FA);
  static const white = Color(0xFFFFFFFF);

  // États (texte + fond)
  static const successText = Color(0xFF007A4F);
  static const successBg = Color(0xFFE5F7EF);
  static const infoText = Color(0xFF00598F);
  static const infoBg = Color(0xFFE8F2F9);
  static const warningText = Color(0xFF915600);
  static const warningBg = Color(0xFFFFF3DA);
  static const errorText = Color(0xFFA52E2E);
  static const errorBg = Color(0xFFFDECEC);
  static const destructiveText = Color(0xFFC53939);
  static const destructiveBg = Color(0xFFFDECEC);
}

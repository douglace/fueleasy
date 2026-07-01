import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Ton d'un badge de statut. Un statut combine toujours couleur ET texte.
enum StatusTone { success, info, warning, error, neutral }

/// Badge textuel court : statut de paiement, accusé, etc.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  ({Color fg, Color bg}) get _colors => switch (tone) {
    StatusTone.success => (fg: AppColors.successText, bg: AppColors.successBg),
    StatusTone.info => (fg: AppColors.infoText, bg: AppColors.infoBg),
    StatusTone.warning => (fg: AppColors.warningText, bg: AppColors.warningBg),
    StatusTone.error => (fg: AppColors.errorText, bg: AppColors.errorBg),
    StatusTone.neutral => (fg: AppColors.neutral700, bg: AppColors.neutral100),
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadii.field),
      ),
      child: Text(label, style: AppTypography.label.copyWith(color: c.fg)),
    );
  }
}

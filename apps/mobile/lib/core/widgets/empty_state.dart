import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// État vide illustré : icône dans un cercle teinté, titre, message, CTA
/// optionnel. Une seule idée par écran vide.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconBg = AppColors.infoBg,
    this.iconColor = AppColors.infoText,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.title3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.body.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

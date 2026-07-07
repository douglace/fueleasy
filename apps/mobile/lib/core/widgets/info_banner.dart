import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum BannerTone { info, success, warning, error }

/// Bandeau inline pleine largeur avec ton sémantique et action optionnelle.
/// Remplace l'ancien InlineErrorBanner (conservé comme alias dans
/// app_text_field.dart) et sert le flux « compte non activé » du login.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.error,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final BannerTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  Color get _bg => switch (tone) {
    BannerTone.info => AppColors.infoBg,
    BannerTone.success => AppColors.successBg,
    BannerTone.warning => AppColors.warningBg,
    BannerTone.error => AppColors.errorBg,
  };

  Color get _fg => switch (tone) {
    BannerTone.info => AppColors.infoText,
    BannerTone.success => AppColors.successText,
    BannerTone.warning => AppColors.warningText,
    BannerTone.error => AppColors.errorText,
  };

  IconData get _icon => switch (tone) {
    BannerTone.info => Icons.info_outline_rounded,
    BannerTone.success => Icons.check_circle_outline_rounded,
    BannerTone.warning => Icons.warning_amber_rounded,
    BannerTone.error => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: 20, color: _fg),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body.copyWith(color: _fg),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: _fg,
                  minimumSize: const Size(48, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.body.copyWith(
                    color: _fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

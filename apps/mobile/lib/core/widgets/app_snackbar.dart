import 'package:flutter/material.dart';

import '../haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'info_banner.dart';

/// Snackbar Fusy : icône d'état + haptique adaptée au ton.
void showAppSnackBar(
  BuildContext context,
  String message, {
  BannerTone tone = BannerTone.info,
}) {
  switch (tone) {
    case BannerTone.success:
      AppHaptics.success();
    case BannerTone.error:
      AppHaptics.error();
    case BannerTone.info:
    case BannerTone.warning:
      AppHaptics.tap();
  }

  final icon = switch (tone) {
    BannerTone.info => Icons.info_outline_rounded,
    BannerTone.success => Icons.check_circle_outline_rounded,
    BannerTone.warning => Icons.warning_amber_rounded,
    BannerTone.error => Icons.error_outline_rounded,
  };
  final iconColor = switch (tone) {
    BannerTone.info => AppColors.white,
    BannerTone.success => AppColors.green,
    BannerTone.warning => AppColors.warningBg,
    BannerTone.error => AppColors.errorBg,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
}

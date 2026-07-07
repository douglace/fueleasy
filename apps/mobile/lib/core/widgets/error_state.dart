import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'empty_state.dart';

/// État d'erreur avec chemin de récupération : toujours un « Réessayer ».
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Une erreur est survenue',
    this.retryLabel = 'Réessayer',
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: title,
      message: message,
      actionLabel: retryLabel,
      onAction: onRetry,
      iconBg: AppColors.errorBg,
      iconColor: AppColors.errorText,
    );
  }
}

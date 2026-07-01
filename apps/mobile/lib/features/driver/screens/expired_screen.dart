import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import 'camera_permission_screen.dart';

/// La demande a expiré (5 minutes dépassées sans confirmation PIN).
/// Aucun débit n'a eu lieu.
class ExpiredScreen extends StatelessWidget {
  const ExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demande expirée')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_off,
                  size: 56,
                  color: AppColors.warningText,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'La demande a expiré après 5 minutes sans confirmation.',
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Aucun montant n\'a été débité.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Créer une nouvelle demande',
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.popUntil((route) => route.isFirst);
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => const CameraPermissionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

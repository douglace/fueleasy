import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
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
        child: Column(
          children: [
            Expanded(
              child: EmptyState(
                icon: Icons.timer_off_rounded,
                iconBg: AppColors.warningBg,
                iconColor: AppColors.warningText,
                title: 'La demande a expiré après 5 minutes sans confirmation.',
                message: 'Aucun montant n\'a été débité.',
                actionLabel: 'Créer une nouvelle demande',
                onAction: () {
                  final navigator = Navigator.of(context);
                  navigator.popUntil((route) => route.isFirst);
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const CameraPermissionScreen(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';

/// Page de blocage générique : une vérification préalable a échoué avant
/// création de la transaction (station non autorisée, budget/solde
/// insuffisant, compte suspendu…). Aucun débit n'a eu lieu.
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demande bloquée')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 56, color: AppColors.errorText),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message,
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
                  label: 'Retour à l\'accueil',
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

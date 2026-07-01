import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../auth_controller.dart';

/// Écran affiché pendant la vérification du jeton au démarrage.
/// Le routeur redirige automatiquement dès que l'état d'auth est résolu ;
/// cet écran ne gère que les cas chargement / erreur (ex. réseau indisponible).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: auth.when(
              loading: () =>
                  Image.asset('assets/images/primary-logo.png', height: 48),
              data: (_) =>
                  Image.asset('assets/images/primary-logo.png', height: 48),
              error: (error, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/primary-logo.png', height: 48),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Connexion au serveur impossible.',
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Vérifiez votre connexion et réessayez.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Réessayer',
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).retry(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

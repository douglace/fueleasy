import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../auth_controller.dart';
import 'widgets/auth_shell.dart';

/// Écran affiché pendant la vérification du jeton au démarrage.
/// Le routeur redirige automatiquement dès que l'état d'auth est résolu ;
/// cet écran ne gère que les cas chargement / erreur (ex. réseau indisponible).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.header),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                child: auth.when(
                  loading: () => const _SplashLogo(),
                  data: (_) => const _SplashLogo(),
                  error: (error, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LogoTile(size: 88),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Connexion au serveur impossible.',
                        style: AppTypography.onNavy(AppTypography.title3),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Vérifiez votre connexion et réessayez.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.onNavyMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: 'Réessayer',
                        background: AppColors.green,
                        onPressed: () =>
                            ref.read(authControllerProvider.notifier).retry(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoTile(size: 88),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.onNavyMuted,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../auth_controller.dart';

/// Affiché quand le compte connecté n'est ni chauffeur ni pompiste
/// (ex. compte admin) : ces rôles utilisent les dashboards web, pas l'app mobile.
class UnsupportedRoleScreen extends ConsumerWidget {
  const UnsupportedRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/primary-logo.png', height: 48),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Ce compte n\'est pas un compte mobile.',
                  style: AppTypography.title3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Les comptes administrateur utilisent les tableaux de bord web Fusy.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SecondaryButton(
                  label: 'Se déconnecter',
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

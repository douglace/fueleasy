import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Tuile logo posée sur fond navy : le PNG de marque a un fond blanc,
/// on l'assume en pastille arrondie type icône d'app.
class LogoTile extends StatelessWidget {
  const LogoTile({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size / 7.2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: AppShadows.raised,
      ),
      child: Image.asset('assets/images/primary-logo.png', fit: BoxFit.contain),
    );
  }
}

/// Gabarit des écrans d'auth : hero navy (logo + titre + sous-titre) et corps
/// clair arrondi qui accueille le formulaire dans une carte élevée.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.footer = const [],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.header),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.sm,
                    AppSpacing.screenMargin,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (onBack != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: IconButton(
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppColors.onNavy,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
                        )
                      else ...[
                        const SizedBox(height: AppSpacing.lg),
                        const Center(child: LogoTile()),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      Text(
                        title,
                        style: AppTypography.onNavy(AppTypography.title1),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTypography.body.copyWith(
                          color: AppColors.onNavyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadii.sheetTop),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        child,
                        ...footer,
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

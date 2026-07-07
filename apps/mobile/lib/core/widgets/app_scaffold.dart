import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Scaffold à header navy immersif : gradient de marque derrière la status
/// bar (icônes claires), titre + sous-titre + actions, et un `heroContent`
/// optionnel (carte élevée) posé dans le header, au-dessus du corps clair
/// arrondi. Supporte toute hauteur de carte héro (budget, QR de session…).
class NavyHeaderScaffold extends StatelessWidget {
  const NavyHeaderScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.heroContent,
    this.onBack,
    this.bottomNavigationBar,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// Carte mise en avant dans le header navy (ex. carte budget, QR session).
  final Widget? heroContent;
  final Widget body;
  final VoidCallback? onBack;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        bottomNavigationBar: bottomNavigationBar,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(gradient: AppGradients.header),
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
                left: AppSpacing.screenMargin,
                right: AppSpacing.screenMargin,
                bottom: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (onBack != null)
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppColors.onNavy,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.onNavy(AppTypography.title2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.onNavyMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                  if (heroContent != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    heroContent!,
                  ],
                ],
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
                clipBehavior: Clip.antiAlias,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

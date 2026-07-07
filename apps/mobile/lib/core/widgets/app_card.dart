import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';

/// Carte Fusy : une seule idée par carte. Bordure par défaut ; `elevated`
/// remplace la bordure par une ombre de marque (cartes héro, formulaires).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: elevated ? null : Border.all(color: AppColors.neutral200),
        boxShadow: elevated ? AppShadows.card : null,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: content,
    );
  }
}

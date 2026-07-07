import 'package:flutter/material.dart';

import '../format/money.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_typography.dart';

/// Montant héro masquable (budget chauffeur). Transition animée entre
/// `•••• FCFA` et le montant révélé. Le montant masqué n'est pas exposé aux
/// lecteurs d'écran.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.revealed = true,
    this.color = AppColors.neutral900,
    this.suffixColor = AppColors.neutral500,
  });

  /// Montant en FCFA (entier).
  final int amount;
  final bool revealed;
  final Color color;
  final Color suffixColor;

  @override
  Widget build(BuildContext context) {
    final text = revealed ? formatFcfaDigits(amount) : '••••••';
    return Semantics(
      label: revealed ? '${formatFcfa(amount)} FCFA' : 'Montant masqué',
      excludeSemantics: true,
      child: AnimatedSwitcher(
        duration: AppDurations.base,
        switchInCurve: AppCurves.emphasized,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Row(
          key: ValueKey(revealed),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.amountHero.copyWith(color: color),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'FCFA',
              style: AppTypography.title3.copyWith(color: suffixColor),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Socle commun : hauteur 52, effet pressed (scale 0.98), haptique tap.
class _BaseButton extends StatefulWidget {
  const _BaseButton({
    required this.label,
    required this.onPressed,
    required this.loading,
    required this.builder,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Widget Function(BuildContext, VoidCallback?, Widget) builder;

  @override
  State<_BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<_BaseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final onPressed = enabled
        ? () {
            AppHaptics.tap();
            widget.onPressed!();
          }
        : null;

    return AnimatedScale(
      scale: _pressed && enabled ? 0.98 : 1,
      duration: AppDurations.fast,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: widget.builder(context, onPressed, _content()),
        ),
      ),
    );
  }

  Widget _content() {
    if (widget.loading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }
    final text = Text(
      widget.label,
      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
    );
    if (widget.icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 22),
        const SizedBox(width: AppSpacing.sm),
        text,
      ],
    );
  }
}

/// Bouton principal Fusy : fond navy, texte blanc, une seule action dominante.
/// Gère l'état de chargement (bloque le double-envoi) et désactivé.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.background = AppColors.navy,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  /// `AppColors.green` pour le CTA héro (scanner une station).
  final Color background;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      icon: icon,
      builder: (context, onPressed, child) => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: AppColors.neutral300,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Bouton secondaire : fond blanc, bordure, texte navy.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      icon: icon,
      builder: (context, onPressed, child) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.neutral200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Action destructrice ou de sortie (déconnexion, annuler un flux).
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      icon: icon,
      builder: (context, onPressed, child) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.destructiveText,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.destructiveText),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        child: child,
      ),
    );
  }
}

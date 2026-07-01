import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Champ texte Fusy : libellé persistant au-dessus (jamais un simple
/// placeholder), aide sous le contrôle, erreur près du champ.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.helperText,
    this.errorText,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? helperText;
  final String? errorText;
  final bool autofocus;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autofocus: autofocus,
          enabled: enabled,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            helperText: helperText,
            errorText: errorText,
            errorMaxLines: 3,
            helperMaxLines: 3,
          ),
        ),
      ],
    );
  }
}

/// Bandeau d'erreur pleine largeur (identifiants invalides, PIN verrouillé…).
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        message,
        style: AppTypography.body.copyWith(color: AppColors.errorText),
      ),
    );
  }
}

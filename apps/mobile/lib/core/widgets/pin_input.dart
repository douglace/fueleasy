import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Saisie PIN à 4 chiffres, masquée, clavier numérique.
/// Ne jamais stocker ni afficher le PIN en clair ailleurs.
class PinInput extends StatelessWidget {
  const PinInput({
    super.key,
    required this.controller,
    this.length = 4,
    this.autofocus = false,
    this.hasError = false,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final bool autofocus;
  final bool hasError;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: length,
      textAlign: TextAlign.center,
      style: AppTypography.title1.copyWith(
        letterSpacing: 16,
        fontFeatures: const [AppTypography.tabular],
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        hintText: '••••'.substring(0, length),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: BorderSide(
            color: hasError ? AppColors.errorText : AppColors.neutral200,
          ),
        ),
      ),
      onChanged: (v) {
        if (v.length == length) onCompleted?.call(v);
      },
    );
  }
}

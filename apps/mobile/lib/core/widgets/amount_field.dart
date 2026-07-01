import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_typography.dart';

/// Reformate en direct les chiffres saisis avec un séparateur de milliers
/// (espace insécable), curseur toujours en fin de saisie.
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  static final _nbsp = String.fromCharCode(0xA0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_nbsp);
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Champ de saisie de montant en FCFA. Expose la valeur entière brute via
/// [onAmountChanged] (aucune sous-unité, franc CFA).
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.onAmountChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<int?> onAmountChanged;
  final bool autofocus;

  int? get _parsedAmount {
    final digits = controller.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      style: AppTypography.amount,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsSeparatorFormatter(),
      ],
      decoration: const InputDecoration(suffixText: 'FCFA'),
      onChanged: (_) => onAmountChanged(_parsedAmount),
    );
  }
}

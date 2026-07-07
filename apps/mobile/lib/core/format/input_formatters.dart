import 'package:flutter/services.dart';

/// Force la saisie en MAJUSCULES (codes organisation, matricules).
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Formatteurs du code organisation Fusy : 6 caractères alphanumériques
/// majuscules (voir OrganizationCode côté backend).
final organizationCodeFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
  UpperCaseTextFormatter(),
  LengthLimitingTextInputFormatter(6),
];

/// Formatteurs du code pompe (secours quand le scan QR est impossible) :
/// mêmes règles que le code organisation (voir PumpCode côté backend).
final pumpCodeFormatters = organizationCodeFormatters;

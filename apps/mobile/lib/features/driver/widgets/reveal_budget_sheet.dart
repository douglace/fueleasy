import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pin_input.dart';
import '../../../domain/entities.dart';

/// Feuille modale : saisie du PIN pour révéler temporairement le solde du
/// budget (`POST /budget/reveal`). Retourne le [BudgetReveal] au succès.
Future<BudgetReveal?> showRevealBudgetSheet(BuildContext context) {
  return showModalBottomSheet<BudgetReveal>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _RevealBudgetSheet(),
  );
}

class _RevealBudgetSheet extends ConsumerStatefulWidget {
  const _RevealBudgetSheet();

  @override
  ConsumerState<_RevealBudgetSheet> createState() => _RevealBudgetSheetState();
}

class _RevealBudgetSheetState extends ConsumerState<_RevealBudgetSheet> {
  final _pinController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  /// True pendant un clear() programmatique du PIN : la notification du
  /// controller ne doit pas effacer le message d'erreur affiché.
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinEdited);
  }

  void _onPinEdited() {
    if (_clearing) return;
    setState(() => _errorMessage = null);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pinController.text.length != 4 || _submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final reveal = await ref
          .read(meRepositoryProvider)
          .revealBudget(_pinController.text);
      if (mounted) Navigator.of(context).pop(reveal);
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
      _clearing = true;
      _pinController.clear();
      _clearing = false;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenMargin,
        right: AppSpacing.screenMargin,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Révéler le budget', style: AppTypography.title3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Saisissez votre PIN pour afficher le solde pendant 15 secondes.',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_errorMessage != null) ...[
            InlineErrorBanner(message: _errorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],
          PinInput(
            controller: _pinController,
            autofocus: true,
            hasError: _errorMessage != null,
            onCompleted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Confirmer',
            loading: _submitting,
            onPressed: _pinController.text.length == 4 ? _submit : null,
          ),
        ],
      ),
    );
  }
}

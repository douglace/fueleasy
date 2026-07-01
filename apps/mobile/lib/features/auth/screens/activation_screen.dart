import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pin_input.dart';
import '../auth_controller.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _orgCodeController = TextEditingController();
  final _identifierController = TextEditingController();
  final _temporaryPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _orgCodeController,
      _identifierController,
      _temporaryPinController,
      _newPinController,
      _confirmPinController,
    ]) {
      c.addListener(_onFieldsChanged);
    }
  }

  void _onFieldsChanged() => setState(() {});

  @override
  void dispose() {
    _orgCodeController.dispose();
    _identifierController.dispose();
    _temporaryPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  bool get _pinsMatch =>
      _newPinController.text.length == 4 &&
      _newPinController.text == _confirmPinController.text;

  bool get _canSubmit =>
      _orgCodeController.text.trim().isNotEmpty &&
      _identifierController.text.trim().isNotEmpty &&
      _temporaryPinController.text.length == 4 &&
      _pinsMatch &&
      !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .activate(
            organizationCode: _orgCodeController.text.trim(),
            identifier: _identifierController.text.trim(),
            temporaryPin: _temporaryPinController.text,
            newPin: _newPinController.text,
          );
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
      _temporaryPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMismatch = _confirmPinController.text.length == 4 && !_pinsMatch;

    return Scaffold(
      appBar: AppBar(title: const Text('Activation du compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Votre entreprise vous a remis un code entreprise et un PIN temporaire. Choisissez votre PIN personnel.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                label: 'Code entreprise',
                controller: _orgCodeController,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Téléphone ou matricule',
                controller: _identifierController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('PIN temporaire', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              PinInput(controller: _temporaryPinController),
              const SizedBox(height: AppSpacing.lg),
              Text('Nouveau PIN', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              PinInput(controller: _newPinController),
              const SizedBox(height: AppSpacing.lg),
              Text('Confirmer le nouveau PIN', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              PinInput(
                controller: _confirmPinController,
                hasError: showMismatch,
              ),
              if (showMismatch) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Les PIN ne correspondent pas.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.errorText,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Activer mon compte',
                loading: _submitting,
                onPressed: _canSubmit ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => context.go(loginPath),
                  child: const Text('Retour à la connexion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

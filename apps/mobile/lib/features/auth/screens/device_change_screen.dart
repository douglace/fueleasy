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

/// Changement d'appareil en deux étapes : demande d'un code SMS (avec le PIN
/// courant), puis confirmation avec ce code à 6 chiffres.
class DeviceChangeScreen extends ConsumerStatefulWidget {
  const DeviceChangeScreen({super.key});

  @override
  ConsumerState<DeviceChangeScreen> createState() => _DeviceChangeScreenState();
}

class _DeviceChangeScreenState extends ConsumerState<DeviceChangeScreen> {
  final _orgCodeController = TextEditingController();
  final _identifierController = TextEditingController();
  final _pinController = TextEditingController();
  final _smsCodeController = TextEditingController();

  bool _codeSent = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _orgCodeController,
      _identifierController,
      _pinController,
      _smsCodeController,
    ]) {
      c.addListener(_onFieldsChanged);
    }
  }

  void _onFieldsChanged() => setState(() {});

  @override
  void dispose() {
    _orgCodeController.dispose();
    _identifierController.dispose();
    _pinController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  bool get _canRequest =>
      _orgCodeController.text.trim().isNotEmpty &&
      _identifierController.text.trim().isNotEmpty &&
      _pinController.text.length == 4 &&
      !_submitting;

  bool get _canConfirm => _smsCodeController.text.length == 6 && !_submitting;

  Future<void> _requestCode() async {
    if (!_canRequest) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final message = await ref
          .read(authControllerProvider.notifier)
          .requestDeviceChange(
            organizationCode: _orgCodeController.text.trim(),
            identifier: _identifierController.text.trim(),
            pin: _pinController.text,
          );
      setState(() {
        _codeSent = true;
        _infoMessage = message;
      });
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
      _pinController.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _confirmCode() async {
    if (!_canConfirm) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .confirmDeviceChange(
            organizationCode: _orgCodeController.text.trim(),
            identifier: _identifierController.text.trim(),
            smsCode: _smsCodeController.text,
          );
      // Redirection vers le bon shell gérée par le routeur.
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
      _smsCodeController.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer d\'appareil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _codeSent
                    ? 'Un code vous a été envoyé par SMS. Saisissez-le pour activer ce nouvel appareil.'
                    : 'Confirmez votre identité avec votre PIN actuel pour recevoir un code SMS.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ] else if (_infoMessage != null) ...[
                Text(
                  _infoMessage!,
                  style: AppTypography.body.copyWith(
                    color: AppColors.successText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (!_codeSent) ...[
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
                Text('PIN actuel', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                PinInput(controller: _pinController),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Envoyer le code SMS',
                  loading: _submitting,
                  onPressed: _canRequest ? _requestCode : null,
                ),
              ] else ...[
                Text('Code reçu par SMS', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                PinInput(
                  controller: _smsCodeController,
                  length: 6,
                  hasError: _errorMessage != null,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Confirmer',
                  loading: _submitting,
                  onPressed: _canConfirm ? _confirmCode : null,
                ),
              ],
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

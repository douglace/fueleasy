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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _orgCodeController = TextEditingController();
  final _identifierController = TextEditingController();
  final _pinController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _orgCodeController,
      _identifierController,
      _pinController,
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
    super.dispose();
  }

  bool get _canSubmit =>
      _orgCodeController.text.trim().isNotEmpty &&
      _identifierController.text.trim().isNotEmpty &&
      _pinController.text.length == 4 &&
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
          .login(
            organizationCode: _orgCodeController.text.trim(),
            identifier: _identifierController.text.trim(),
            pin: _pinController.text,
          );
      // La redirection vers le bon shell est gérée par le routeur.
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
      _pinController.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Image.asset(
                  'assets/images/primary-logo.png',
                  height: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Connexion', style: AppTypography.title1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Entrez le code de votre entreprise, votre identifiant et votre PIN.',
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
              Text('PIN', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              PinInput(
                controller: _pinController,
                hasError: _errorMessage != null,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Se connecter',
                loading: _submitting,
                onPressed: _canSubmit ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: TextButton(
                  onPressed: () => context.go(activatePath),
                  child: const Text('Première connexion ? Activer mon compte'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.go(deviceChangePath),
                  child: const Text('Nouveau téléphone ? Changer d\'appareil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/input_formatters.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/pin_input.dart';
import '../auth_controller.dart';
import 'widgets/auth_shell.dart';

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
  bool _needsActivation = false;

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
      _needsActivation = false;
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
      final needsActivation =
          f is DomainFailure && f.reasonCode == accountNotActivatedReason;
      setState(() {
        _errorMessage = f.message;
        _needsActivation = needsActivation;
      });
      _pinController.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Ouvre l'activation pré-remplie avec le code org et l'identifiant saisis.
  void _goToActivation() {
    context.go(
      Uri(
        path: activatePath,
        queryParameters: {
          'org': _orgCodeController.text.trim(),
          'id': _identifierController.text.trim(),
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Connexion',
      subtitle:
          'Entrez le code de votre entreprise, votre identifiant et votre PIN.',
      footer: [
        const SizedBox(height: AppSpacing.lg),
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
      child: AppCard(
        elevated: true,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              if (_needsActivation)
                InlineBanner(
                  message: _errorMessage!,
                  tone: BannerTone.info,
                  actionLabel: 'Activer mon compte',
                  onAction: _goToActivation,
                )
              else
                InlineBanner(message: _errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppTextField(
              label: 'Code entreprise',
              controller: _orgCodeController,
              textInputAction: TextInputAction.next,
              helperText: '6 caractères — affiché sur votre espace Fusy',
              inputFormatters: organizationCodeFormatters,
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
              hasError: _errorMessage != null && !_needsActivation,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Se connecter',
              loading: _submitting,
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

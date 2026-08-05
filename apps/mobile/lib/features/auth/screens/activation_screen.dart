import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/input_formatters.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/pin_input.dart';
import '../auth_controller.dart';
import 'widgets/auth_shell.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({
    super.key,
    this.initialOrganizationCode,
    this.initialIdentifier,
  });

  /// Pré-remplissage depuis le login (flux « compte non activé »).
  final String? initialOrganizationCode;
  final String? initialIdentifier;

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  late final _orgCodeController = TextEditingController(
    text: widget.initialOrganizationCode ?? '',
  );
  late final _identifierController = TextEditingController(
    text: widget.initialIdentifier ?? '',
  );
  final _temporaryPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _temporaryPinFocus = FocusNode();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  bool _submitting = false;
  String? _errorMessage;

  /// True pendant un clear() programmatique des PIN : la notification des
  /// controllers ne doit pas effacer le message d'erreur affiché.
  bool _clearing = false;

  bool get _prefilled =>
      (widget.initialOrganizationCode ?? '').isNotEmpty &&
      (widget.initialIdentifier ?? '').isNotEmpty;

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

  void _onFieldsChanged() {
    if (_clearing) return;
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _orgCodeController.dispose();
    _identifierController.dispose();
    _temporaryPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _temporaryPinFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
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
      _clearing = true;
      _temporaryPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
      _clearing = false;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMismatch = _confirmPinController.text.length == 4 && !_pinsMatch;

    return AuthShell(
      title: 'Activation du compte',
      subtitle:
          'Votre entreprise vous a remis un code entreprise et un PIN temporaire. Choisissez votre PIN personnel.',
      onBack: () => context.go(loginPath),
      footer: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: () => context.go(loginPath),
            child: const Text('Retour à la connexion'),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            InlineBanner(message: _errorMessage!),
            const SizedBox(height: AppSpacing.lg),
          ],
          AppCard(
            elevated: true,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StepHeader(step: 1, label: 'Votre identité'),
                const SizedBox(height: AppSpacing.lg),
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
                Text('PIN temporaire', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                PinInput(
                  controller: _temporaryPinController,
                  focusNode: _temporaryPinFocus,
                  autofocus: _prefilled,
                  onCompleted: (_) => _newPinFocus.requestFocus(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            elevated: true,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StepHeader(step: 2, label: 'Votre nouveau PIN'),
                const SizedBox(height: AppSpacing.lg),
                Text('Nouveau PIN', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                PinInput(
                  controller: _newPinController,
                  focusNode: _newPinFocus,
                  onCompleted: (_) => _confirmPinFocus.requestFocus(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Confirmer le nouveau PIN', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                PinInput(
                  controller: _confirmPinController,
                  focusNode: _confirmPinFocus,
                  hasError: showMismatch,
                  onCompleted: (_) {
                    if (_pinsMatch) _submit();
                  },
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Activer mon compte',
            loading: _submitting,
            onPressed: _canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}

/// Pastille numérotée + libellé de section du parcours d'activation.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: AppTypography.label.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.title3),
      ],
    );
  }
}

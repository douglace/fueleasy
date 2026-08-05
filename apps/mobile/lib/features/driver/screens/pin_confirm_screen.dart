import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/countdown_timer.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/pin_input.dart';
import '../../../domain/entities.dart';
import '../../../domain/enums.dart';
import 'blocked_screen.dart';
import 'expired_screen.dart';
import 'success_screen.dart';

/// Récapitulatif non modifiable de la demande créée + confirmation PIN.
/// La confirmation débite immédiatement le compte entreprise et le budget.
class PinConfirmScreen extends ConsumerStatefulWidget {
  const PinConfirmScreen({
    super.key,
    required this.payment,
    required this.idempotencyKey,
    required this.stationName,
  });

  final Payment payment;
  final String idempotencyKey;
  final String stationName;

  @override
  ConsumerState<PinConfirmScreen> createState() => _PinConfirmScreenState();
}

class _PinConfirmScreenState extends ConsumerState<PinConfirmScreen> {
  final _pinController = TextEditingController();
  bool _submitting = false;
  bool _navigated = false;
  String? _errorMessage;

  /// Erreur portant sur le PIN lui-même (case rouge + shake). Les erreurs
  /// réseau/informatiques n'affectent pas la case : seule le message s'affiche.
  bool _pinHasError = false;

  /// True pendant un clear() programmatique du PIN : on ne veut PAS que la
  /// notification du controller efface le message d'erreur qu'on vient d'afficher.
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinEdited);
  }

  void _onPinEdited() {
    if (_clearing) return;
    setState(() {
      _errorMessage = null;
      _pinHasError = false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _replace(Widget screen) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  void _onExpired() {
    if (_submitting) return;
    _replace(const ExpiredScreen());
  }

  Future<void> _confirm() async {
    if (_submitting || _pinController.text.length != 4) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final updated = await ref
          .read(paymentRepositoryProvider)
          .confirm(
            paymentId: widget.payment.id,
            pin: _pinController.text,
            idempotencyKey: widget.idempotencyKey,
          );
      _replace(
        SuccessScreen(payment: updated, stationName: widget.stationName),
      );
    } on Failure catch (f) {
      if (f is NetworkFailure) {
        await _recoverAfterNetworkIssue();
        return;
      }
      final reason = f is DomainFailure ? f.paymentReason : null;
      if (reason == PaymentFailureReason.sessionExpired) {
        _replace(const ExpiredScreen());
        return;
      }
      if (reason == PaymentFailureReason.invalidPin) {
        setState(() {
          _errorMessage = f.message;
          _pinHasError = true;
        });
        _clearing = true;
        _pinController.clear();
        _clearing = false;
        return;
      }
      // pin_locked ou toute autre vérification ré-évaluée à la confirmation.
      _replace(BlockedScreen(message: f.message));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _recoverAfterNetworkIssue() async {
    setState(() => _errorMessage = 'Vérification du statut…');
    try {
      final found = await ref
          .read(paymentRepositoryProvider)
          .findByIdempotencyKey(widget.idempotencyKey);
      if (found != null && found.status.isPaid) {
        _replace(
          SuccessScreen(payment: found, stationName: widget.stationName),
        );
        return;
      }
      if (mounted) {
        setState(
          () => _errorMessage = 'Connexion instable. Vous pouvez réessayer.',
        );
      }
    } on Failure {
      if (mounted) {
        setState(
          () => _errorMessage = 'Connexion instable. Vous pouvez réessayer.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final expiresAt = payment.expiresAt;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                elevated: true,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Montant à payer',
                                style: AppTypography.label,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                formatFcfa(payment.amount),
                                style: AppTypography.amount,
                              ),
                            ],
                          ),
                        ),
                        if (expiresAt != null)
                          CountdownRing(
                            expiresAt: expiresAt,
                            // Une demande Fusy est valable 5 minutes.
                            totalDuration: const Duration(minutes: 5),
                            onExpired: _onExpired,
                            size: 56,
                          ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                    _Row(label: 'Station', value: widget.stationName),
                    const SizedBox(height: AppSpacing.sm),
                    _Row(label: 'Carburant', value: payment.fuelType.label),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                InlineBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text('PIN', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              PinInput(
                controller: _pinController,
                autofocus: true,
                hasError: _pinHasError,
                onCompleted: (_) => _confirm(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Confirmer ${formatFcfa(payment.amount)}',
                loading: _submitting,
                onPressed: _pinController.text.length == 4 ? _confirm : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

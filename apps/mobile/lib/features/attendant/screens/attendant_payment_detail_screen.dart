import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities.dart';
import '../attendant_providers.dart';
import '../widgets/ack_status_badge.dart';

/// Détail d'un paiement en lecture seule. Le pompiste ne modifie, ne valide
/// ni ne refuse jamais : il consulte et accuse réception.
class AttendantPaymentDetailScreen extends ConsumerStatefulWidget {
  const AttendantPaymentDetailScreen({super.key, required this.payment});

  final Payment payment;

  @override
  ConsumerState<AttendantPaymentDetailScreen> createState() =>
      _AttendantPaymentDetailScreenState();
}

class _AttendantPaymentDetailScreenState
    extends ConsumerState<AttendantPaymentDetailScreen> {
  late Payment _payment;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _payment = widget.payment;
  }

  Future<void> _acknowledge() async {
    if (_submitting || _payment.isAcknowledged) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(workSessionRepositoryProvider).acknowledge(_payment.id);
      ref.invalidate(attendantTodayPaymentsProvider);
      setState(
        () => _payment = _payment.copyWith(alertAcknowledgedAt: DateTime.now()),
      );
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentation = ackPresentation(_payment);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail paiement')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatFcfa(_payment.amount),
                    style: AppTypography.display,
                  ),
                  StatusBadge(
                    label: presentation.label,
                    tone: presentation.tone,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: 'Code court', value: _payment.shortCode),
                    const Divider(height: AppSpacing.xl),
                    _Row(label: 'Carburant', value: _payment.fuelType.label),
                    const Divider(height: AppSpacing.xl),
                    _Row(label: 'Référence', value: _payment.reference),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (!_payment.isAcknowledged)
                PrimaryButton(
                  label: 'Accuser réception',
                  loading: _submitting,
                  onPressed: _acknowledge,
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
        Flexible(
          child: SelectableText(
            value,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

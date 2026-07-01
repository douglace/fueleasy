import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities.dart';
import '../receipt/open_receipt.dart';
import '../widgets/payment_status_badge.dart';

/// Détail d'une transaction : statut, montant, carburant, chronologie,
/// identifiants copiables et accès au reçu PDF pour une transaction payée.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.payment});

  final Payment payment;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  bool _loadingReceipt = false;
  String? _errorMessage;

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat("d MMMM y 'à' HH:mm", 'fr_FR').format(date);
  }

  Future<void> _viewReceipt() async {
    setState(() {
      _loadingReceipt = true;
      _errorMessage = null;
    });
    try {
      final bytes = await ref
          .read(paymentRepositoryProvider)
          .receiptPdf(widget.payment.id);
      await openReceiptPdf(bytes: bytes, reference: widget.payment.reference);
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
    } finally {
      if (mounted) setState(() => _loadingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final presentation = paymentStatusPresentation(payment.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail transaction')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatFcfa(payment.amount), style: AppTypography.display),
                StatusBadge(label: presentation.label, tone: presentation.tone),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(label: 'Carburant', value: payment.fuelType.label),
                  const Divider(height: AppSpacing.xl),
                  _Row(label: 'Code court', value: payment.shortCode),
                  const Divider(height: AppSpacing.xl),
                  _Row(label: 'Référence', value: payment.reference),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Chronologie', style: AppTypography.title3),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(label: 'Créée', value: _formatDate(payment.createdAt)),
                  if (payment.confirmedAt != null) ...[
                    const Divider(height: AppSpacing.xl),
                    _Row(
                      label: 'Payée',
                      value: _formatDate(payment.confirmedAt),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (payment.status.isPaid) ...[
              if (_errorMessage != null) ...[
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              PrimaryButton(
                label: 'Voir le reçu',
                loading: _loadingReceipt,
                onPressed: _viewReceipt,
              ),
            ] else
              Text(
                'Ce document n\'est pas un reçu final.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
                textAlign: TextAlign.center,
              ),
          ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities.dart';
import '../attendant_providers.dart';
import '../widgets/ack_status_badge.dart';
import 'attendant_payment_detail_screen.dart';

enum _Filter { all, toAck, acked }

/// Historique du jour : total indicatif et filtre par statut d'accusé.
/// L'API pompiste n'expose que les paiements du jour (pas d'historique
/// multi-jours côté mobile).
class AttendantHistoryScreen extends ConsumerStatefulWidget {
  const AttendantHistoryScreen({super.key});

  @override
  ConsumerState<AttendantHistoryScreen> createState() =>
      _AttendantHistoryScreenState();
}

class _AttendantHistoryScreenState
    extends ConsumerState<AttendantHistoryScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(attendantTodayPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique du jour')),
      body: SafeArea(
        child: payments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Impossible de charger l\'historique.',
              style: AppTypography.body,
            ),
          ),
          data: (list) {
            final total = list.fold<int>(0, (sum, p) => sum + p.amount);
            final filtered = switch (_filter) {
              _Filter.all => list,
              _Filter.toAck => list.where((p) => !p.isAcknowledged).toList(),
              _Filter.acked => list.where((p) => p.isAcknowledged).toList(),
            };

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              children: [
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paiements', style: AppTypography.label),
                          const SizedBox(height: AppSpacing.xs),
                          Text('${list.length}', style: AppTypography.title2),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Montant total', style: AppTypography.label),
                          const SizedBox(height: AppSpacing.xs),
                          Text(formatFcfa(total), style: AppTypography.title2),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('Tous'),
                      selected: _filter == _Filter.all,
                      onSelected: (_) => setState(() => _filter = _Filter.all),
                    ),
                    ChoiceChip(
                      label: const Text('À accuser'),
                      selected: _filter == _Filter.toAck,
                      onSelected: (_) =>
                          setState(() => _filter = _Filter.toAck),
                    ),
                    ChoiceChip(
                      label: const Text('Accusés'),
                      selected: _filter == _Filter.acked,
                      onSelected: (_) =>
                          setState(() => _filter = _Filter.acked),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Text(
                      'Aucun paiement pour ce filtre.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (final payment in filtered) ...[
                    _HistoryRow(payment: payment),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final presentation = ackPresentation(payment);

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AttendantPaymentDetailScreen(payment: payment),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(payment.shortCode, style: AppTypography.bodyLarge),
          Row(
            children: [
              Text(formatFcfa(payment.amount), style: AppTypography.bodyLarge),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(label: presentation.label, tone: presentation.tone),
            ],
          ),
        ],
      ),
    );
  }
}

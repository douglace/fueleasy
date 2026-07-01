import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities.dart';
import '../driver_providers.dart';
import '../widgets/payment_status_badge.dart';
import 'transaction_detail_screen.dart';

/// Liste des transactions récentes groupées par date, état vide et
/// possibilité d'actualiser.
class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(driverHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(driverHistoryProvider.future),
          child: history.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Center(
                  child: Text(
                    'Impossible de charger l\'historique.',
                    style: AppTypography.body,
                  ),
                ),
              ],
            ),
            data: (payments) {
              if (payments.isEmpty) return const _EmptyHistory();
              return _GroupedHistoryList(payments: payments);
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          'Aucune transaction pour le moment',
          style: AppTypography.title3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Votre premier reçu apparaîtra ici après une transaction payée.',
          style: AppTypography.body.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GroupedHistoryList extends StatelessWidget {
  const _GroupedHistoryList({required this.payments});

  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Payment>>{};
    for (final payment in payments) {
      final date = payment.createdAt;
      final key = date != null
          ? DateFormat('d MMMM y', 'fr_FR').format(date)
          : 'Date inconnue';
      groups.putIfAbsent(key, () => []).add(payment);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(entry.key, style: AppTypography.label),
          ),
          for (final payment in entry.value) ...[
            _HistoryRow(payment: payment),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final presentation = paymentStatusPresentation(payment.status);
    final time = payment.createdAt != null
        ? DateFormat('HH:mm').format(payment.createdAt!)
        : '';

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(payment: payment),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.fuelType.label, style: AppTypography.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(time, style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatFcfa(payment.amount), style: AppTypography.bodyLarge),
              const SizedBox(height: AppSpacing.xs),
              StatusBadge(label: presentation.label, tone: presentation.tone),
            ],
          ),
        ],
      ),
    );
  }
}

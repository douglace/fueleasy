import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
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
            loading: () => const SkeletonList(),
            error: (error, _) => ErrorState(
              message:
                  'Impossible de charger l\'historique. Vérifiez votre connexion.',
              onRetry: () => ref.invalidate(driverHistoryProvider),
            ),
            data: (payments) {
              if (payments.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'Aucune transaction pour le moment',
                  message:
                      'Votre premier reçu apparaîtra ici après une transaction payée.',
                );
              }
              return _GroupedHistoryList(payments: payments);
            },
          ),
        ),
      ),
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
            child: Text(
              entry.key,
              style: AppTypography.label.copyWith(color: AppColors.neutral500),
            ),
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              size: 20,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
              Text(
                formatFcfa(payment.amount),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [AppTypography.tabular],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              StatusBadge(label: presentation.label, tone: presentation.tone),
            ],
          ),
        ],
      ),
    );
  }
}

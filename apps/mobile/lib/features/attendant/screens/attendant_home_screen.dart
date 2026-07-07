import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities.dart';
import '../attendant_providers.dart';
import '../widgets/ack_status_badge.dart';
import '../widgets/session_card.dart';
import 'attendant_payment_detail_screen.dart';
import 'search_code_screen.dart';

/// Accueil pompiste : session de travail (QR) + paiements du jour de la
/// station. Le pompiste consulte uniquement ; il ne valide, ne refuse ni ne
/// modifie jamais un paiement.
class AttendantHomeScreen extends ConsumerWidget {
  const AttendantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(attendantTodayPaymentsProvider);

    return NavyHeaderScaffold(
      title: 'Paiements',
      subtitle: 'Votre pompe et les paiements du jour.',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          color: AppColors.onNavy,
          tooltip: 'Rechercher un code',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SearchCodeScreen())),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(attendantTodayPaymentsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            const SessionCard(),
            const SizedBox(height: AppSpacing.xl),
            payments.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (list) => _TodayHeader(payments: list),
            ),
            const SizedBox(height: AppSpacing.sm),
            payments.when(
              loading: () => const SkeletonTheme(
                child: Column(
                  children: [
                    SkeletonCard(),
                    SizedBox(height: AppSpacing.md),
                    SkeletonCard(),
                    SizedBox(height: AppSpacing.md),
                    SkeletonCard(),
                  ],
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  'Impossible de charger les paiements.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.infoBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_empty_rounded,
                            size: 32,
                            color: AppColors.infoText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Aucun paiement aujourd\'hui dans cette station.',
                          style: AppTypography.body.copyWith(
                            color: AppColors.neutral600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final payment in list) ...[
                      _PaymentRow(payment: payment),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête « Aujourd'hui » + total encaissé du jour (paiements payés).
class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.payments});

  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    final total = payments
        .where((p) => p.status.isPaid)
        .fold<int>(0, (sum, p) => sum + p.amount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Aujourd\'hui', style: AppTypography.title3),
        if (payments.isNotEmpty)
          Text(
            formatFcfa(total),
            style: AppTypography.title3.copyWith(
              color: AppColors.greenDark,
              fontFeatures: const [AppTypography.tabular],
            ),
          ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.shortCode,
                  style: AppTypography.title3.copyWith(
                    fontFeatures: const [AppTypography.tabular],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(payment.fuelType.label, style: AppTypography.caption),
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

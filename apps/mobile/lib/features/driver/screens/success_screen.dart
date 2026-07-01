import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../domain/entities.dart';

/// Transaction payée : montant, station, date/heure, carburant, identifiant
/// et code court à présenter au pompiste pour qu'il serve le carburant.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.payment,
    required this.stationName,
  });

  final Payment payment;
  final String stationName;

  @override
  Widget build(BuildContext context) {
    final confirmedAt = payment.confirmedAt;
    final dateLabel = confirmedAt != null
        ? DateFormat("d MMMM y 'à' HH:mm", 'fr_FR').format(confirmedAt)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction payée'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Icon(
                Icons.check_circle,
                size: 56,
                color: AppColors.successText,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                formatFcfa(payment.amount),
                style: AppTypography.display,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Code à présenter au pompiste',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      payment.shortCode,
                      style: AppTypography.title1.copyWith(
                        letterSpacing: 8,
                        fontFeatures: const [AppTypography.tabular],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: 'Station', value: stationName),
                    const Divider(height: AppSpacing.xl),
                    _Row(label: 'Carburant', value: payment.fuelType.label),
                    if (dateLabel.isNotEmpty) ...[
                      const Divider(height: AppSpacing.xl),
                      _Row(label: 'Date', value: dateLabel),
                    ],
                    const Divider(height: AppSpacing.xl),
                    _Row(label: 'Référence', value: payment.reference),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Retour à l\'accueil',
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
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
          child: Text(
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

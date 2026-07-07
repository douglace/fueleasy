import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../domain/enums.dart';
import '../models/payment_draft.dart';
import 'recap_screen.dart';

/// Station verrouillée (issue du scan) + saisie du montant, du carburant et
/// d'un champ libre optionnel.
class AmountEntryScreen extends StatefulWidget {
  const AmountEntryScreen({super.key, required this.draft});

  final PaymentDraft draft;

  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  static const _quickAmounts = [5000, 10000, 20000];

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late PaymentDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectFuel(FuelType fuel) {
    AppHaptics.tap();
    setState(() => _draft = _draft.copyWith(fuelType: fuel));
  }

  void _applyQuickAmount(int amount) {
    AppHaptics.tap();
    // Le formateur de milliers ne tourne que sur saisie clavier : on formate
    // nous-mêmes pour rester cohérent à l'écran.
    _amountController.text = formatFcfaDigits(amount);
    setState(() => _draft = _draft.copyWith(amount: amount));
  }

  void _continue() {
    final draft = _draft.copyWith(note: _noteController.text.trim());
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecapScreen(draft: draft)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle demande')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_gas_station_rounded,
                        size: 20,
                        color: AppColors.successText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Station', style: AppTypography.label),
                          const SizedBox(height: 2),
                          Text(
                            _draft.station.name,
                            style: AppTypography.title3,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.neutral300,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Montant de la demande', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              AmountField(
                controller: _amountController,
                autofocus: true,
                onAmountChanged: (amount) =>
                    setState(() => _draft = _draft.copyWith(amount: amount)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final amount in _quickAmounts)
                    ActionChip(
                      label: Text(formatFcfaDigits(amount)),
                      onPressed: () => _applyQuickAmount(amount),
                      labelStyle: AppTypography.body.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [AppTypography.tabular],
                      ),
                      side: const BorderSide(color: AppColors.neutral200),
                      backgroundColor: AppColors.white,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Type de carburant', style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: _draft.pump.availableFuels
                    .where((f) => f != FuelType.unknown)
                    .map(
                      (fuel) => ChoiceChip(
                        label: Text(fuel.label),
                        selected: _draft.fuelType == fuel,
                        onSelected: (_) => _selectFuel(fuel),
                        selectedColor: AppColors.navy,
                        labelStyle: AppTypography.body.copyWith(
                          color: _draft.fuelType == fuel
                              ? AppColors.white
                              : AppColors.neutral900,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Véhicule, plaque ou mission (optionnel)',
                controller: _noteController,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Continuer',
                onPressed: _draft.isComplete ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

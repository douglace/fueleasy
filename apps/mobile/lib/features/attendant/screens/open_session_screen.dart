import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/haptics.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/skeleton.dart';
import '../attendant_providers.dart';

/// Choix de la pompe pour ouvrir une session de travail.
class OpenSessionScreen extends ConsumerStatefulWidget {
  const OpenSessionScreen({super.key});

  @override
  ConsumerState<OpenSessionScreen> createState() => _OpenSessionScreenState();
}

class _OpenSessionScreenState extends ConsumerState<OpenSessionScreen> {
  int? _selectedPumpId;
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _openSession() async {
    if (_selectedPumpId == null || _submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(workSessionRepositoryProvider).open(_selectedPumpId!);
      ref.invalidate(currentSessionProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pumps = ref.watch(attendantPumpsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ouvrir une session')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choisissez la pompe sur laquelle vous travaillez.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_errorMessage != null) ...[
                InlineBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              Expanded(
                child: pumps.when(
                  loading: () => const SkeletonList(count: 3, itemHeight: 64),
                  error: (error, _) => ErrorState(
                    message: 'Impossible de charger les pompes.',
                    onRetry: () => ref.invalidate(attendantPumpsProvider),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return const EmptyState(
                        icon: Icons.local_gas_station_rounded,
                        title: 'Aucune pompe active',
                        message: 'Aucune pompe active pour cette station.',
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final pump = list[index];
                        final selected = pump.id == _selectedPumpId;
                        return _PumpCard(
                          label: pump.label,
                          selected: selected,
                          onTap: () {
                            AppHaptics.tap();
                            setState(() => _selectedPumpId = pump.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Ouvrir la session',
                loading: _submitting,
                onPressed: _selectedPumpId != null ? _openSession : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte-radio de pompe : bordure et fond marqués quand sélectionnée,
/// zone tactile pleine largeur ≥ 56 dp.
class _PumpCard extends StatelessWidget {
  const _PumpCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: selected ? AppColors.infoBg : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: selected ? AppColors.navy : AppColors.neutral200,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_gas_station_rounded,
                    size: 22,
                    color: selected ? AppColors.navy : AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.navy : AppColors.neutral300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

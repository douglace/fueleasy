import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
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
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              Expanded(
                child: pumps.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Impossible de charger les pompes.',
                      style: AppTypography.body,
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucune pompe active pour cette station.',
                          style: AppTypography.body,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final pump = list[index];
                        final selected = pump.id == _selectedPumpId;
                        return AppCard(
                          onTap: () =>
                              setState(() => _selectedPumpId = pump.id),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(pump.label, style: AppTypography.bodyLarge),
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppColors.navy
                                    : AppColors.neutral300,
                              ),
                            ],
                          ),
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

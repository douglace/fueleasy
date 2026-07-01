import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../models/payment_draft.dart';
import 'blocked_screen.dart';
import 'pin_confirm_screen.dart';

/// Répète la station, le montant, le carburant et le champ libre. Le bouton
/// principal déclenche `POST /payments` : c'est le moment où la demande est
/// réellement créée côté serveur. Le débit lui-même intervient plus tard,
/// à la confirmation du PIN.
class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({super.key, required this.draft});

  final PaymentDraft draft;

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final draft = widget.draft;
    try {
      final payment = await ref
          .read(paymentRepositoryProvider)
          .create(
            qr: draft.qr,
            fuelType: draft.fuelType!,
            amount: draft.amount!,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PinConfirmScreen(
            payment: payment,
            idempotencyKey: const Uuid().v4(),
            stationName: draft.station.name,
          ),
        ),
      );
    } on Failure catch (f) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BlockedScreen(message: f.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Scaffold(
      appBar: AppBar(title: const Text('Récapitulatif')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RecapRow(label: 'Station', value: draft.station.name),
                    const Divider(height: AppSpacing.xl),
                    _RecapRow(
                      label: 'Montant',
                      value: formatFcfa(draft.amount!),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _RecapRow(label: 'Carburant', value: draft.fuelType!.label),
                    if (draft.note != null && draft.note!.isNotEmpty) ...[
                      const Divider(height: AppSpacing.xl),
                      _RecapRow(label: 'Référence', value: draft.note!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Le débit interviendra à la confirmation de votre PIN.',
                style: AppTypography.caption,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Confirmer avec le PIN',
                loading: _submitting,
                onPressed: _confirm,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

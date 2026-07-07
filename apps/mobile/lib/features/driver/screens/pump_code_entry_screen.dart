import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/format/input_formatters.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/payment_draft.dart';
import 'amount_entry_screen.dart';

/// Saisie manuelle du code pompe — secours quand le scan QR est impossible
/// (caméra refusée, QR illisible). Le code de 6 caractères est affiché sur la
/// pompe à côté du QR ; il est résolu via `POST /scan {code}` puis le parcours
/// continue exactement comme après un scan.
class PumpCodeEntryScreen extends ConsumerStatefulWidget {
  const PumpCodeEntryScreen({super.key});

  @override
  ConsumerState<PumpCodeEntryScreen> createState() =>
      _PumpCodeEntryScreenState();
}

class _PumpCodeEntryScreenState extends ConsumerState<PumpCodeEntryScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isComplete => _controller.text.length == 6;

  Future<void> _submit() async {
    if (_submitting || !_isComplete) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final code = _controller.text;
    try {
      final context0 = await ref
          .read(paymentRepositoryProvider)
          .scanByCode(code);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AmountEntryScreen(
            draft: PaymentDraft(
              code: code,
              station: context0.station,
              pump: context0.pump,
            ),
          ),
        ),
      );
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() {
        _errorMessage = f.message;
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code de la pompe')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Saisissez le code affiché sur la pompe',
                style: AppTypography.title3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Le code de 6 caractères est affiché à côté du QR code. '
                'Utilisez-le si le scan est impossible.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Code pompe',
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                inputFormatters: pumpCodeFormatters,
                helperText: '6 caractères — ex. K7M2XQ',
                errorText: _errorMessage,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continuer',
                loading: _submitting,
                onPressed: _isComplete && !_submitting ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

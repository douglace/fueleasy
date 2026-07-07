import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import 'attendant_payment_detail_screen.dart';

/// Recherche d'un paiement par son code court (4 chiffres).
class SearchCodeScreen extends ConsumerStatefulWidget {
  const SearchCodeScreen({super.key});

  @override
  ConsumerState<SearchCodeScreen> createState() => _SearchCodeScreenState();
}

class _SearchCodeScreenState extends ConsumerState<SearchCodeScreen> {
  final _codeController = TextEditingController();
  bool _searching = false;
  String? _notFoundMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _search(String code) async {
    if (_searching) return;
    setState(() {
      _searching = true;
      _notFoundMessage = null;
    });
    try {
      final payment = await ref
          .read(workSessionRepositoryProvider)
          .searchByCode(code);
      if (!mounted) return;
      if (payment == null) {
        setState(
          () => _notFoundMessage =
              'Aucun paiement avec le code $code aujourd\'hui dans cette station.',
        );
        _codeController.clear();
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AttendantPaymentDetailScreen(payment: payment),
        ),
      );
    } on Failure catch (f) {
      setState(() => _notFoundMessage = f.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher un code')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Demandez au chauffeur le code affiché sur son reçu.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Code du paiement',
                style: AppTypography.label,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Code visible (ce n'est pas un secret), géant et tabulaire
              // pour une lecture sans erreur à la pompe.
              TextField(
                controller: _codeController,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: AppTypography.amountHero.copyWith(letterSpacing: 12),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '0000',
                  hintStyle: AppTypography.amountHero.copyWith(
                    letterSpacing: 12,
                    color: AppColors.neutral200,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.field),
                    borderSide: BorderSide(
                      color: _notFoundMessage != null
                          ? AppColors.errorText
                          : AppColors.neutral200,
                    ),
                  ),
                ),
                onChanged: (v) {
                  if (v.length == 4) _search(v);
                },
              ),
              if (_searching) ...[
                const SizedBox(height: AppSpacing.xl),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_notFoundMessage != null) ...[
                const SizedBox(height: AppSpacing.xl),
                EmptyState(
                  icon: Icons.search_off_rounded,
                  iconBg: AppColors.warningBg,
                  iconColor: AppColors.warningText,
                  title: 'Aucun résultat',
                  message: _notFoundMessage!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

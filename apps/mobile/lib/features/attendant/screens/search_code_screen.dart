import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pin_input.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('Code du paiement', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              PinInput(
                controller: _codeController,
                autofocus: true,
                hasError: _notFoundMessage != null,
                onCompleted: _search,
              ),
              if (_searching) ...[
                const SizedBox(height: AppSpacing.lg),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_notFoundMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _notFoundMessage!,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

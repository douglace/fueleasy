import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/payment_draft.dart';
import 'amount_entry_screen.dart';

/// Vue caméra + cadre de scan. Résout le QR via `POST /scan` dès qu'un code
/// est lu ; un seul appel à la fois (`_processing`) pour éviter les doublons.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _controller = MobileScannerController();
  bool _processing = false;
  bool _torchOn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcodes = capture.barcodes;
    final raw = barcodes.isNotEmpty ? barcodes.first.rawValue : null;
    if (raw == null || raw.isEmpty) return;

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final context0 = await ref.read(paymentRepositoryProvider).scan(raw);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AmountEntryScreen(
            draft: PaymentDraft(
              qr: raw,
              station: context0.station,
              pump: context0.pump,
            ),
          ),
        ),
      );
    } on Failure catch (f) {
      setState(() {
        _errorMessage = f.message;
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _ScanOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: Icon(
                      _torchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.toggleTorch();
                      setState(() => _torchOn = !_torchOn);
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: _errorMessage != null
                  ? _ErrorBanner(
                      message: _errorMessage!,
                      onRetry: () => setState(() => _errorMessage = null),
                    )
                  : Text(
                      _processing
                          ? 'Vérification…'
                          : 'Placez le QR de la station dans le cadre',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.errorText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

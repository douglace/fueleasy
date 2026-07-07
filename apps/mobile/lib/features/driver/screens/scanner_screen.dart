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
import 'pump_code_entry_screen.dart';

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

  void _goToCodeEntry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PumpCodeEntryScreen()),
    );
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    _ErrorBanner(
                      message: _errorMessage!,
                      onRetry: () => setState(() => _errorMessage = null),
                    )
                  else
                    Text(
                      _processing
                          ? 'Vérification…'
                          : 'Placez le QR de la station dans le cadre',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: _goToCodeEntry,
                    child: Text(
                      'Saisir le code de la pompe',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
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
    return CustomPaint(size: Size.infinite, painter: _ScanOverlayPainter());
  }
}

/// Scrim sombre avec découpe arrondie centrale et coins verts façon viseur.
class _ScanOverlayPainter extends CustomPainter {
  static const _window = 260.0;
  static const _radius = 24.0;
  static const _cornerLength = 36.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final window = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: _window, height: _window),
      const Radius.circular(_radius),
    );

    // Scrim percé de la fenêtre de scan.
    final scrim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(window)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      scrim,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Quatre coins verts (repère de visée, lisible en plein soleil).
    final corner = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final rect = window.outerRect;

    void arc(Offset arcCenter, double startAngle) {
      canvas.drawArc(
        Rect.fromCircle(center: arcCenter, radius: _radius),
        startAngle,
        1.5708, // 90°
        false,
        corner,
      );
    }

    // Arcs des quatre coins + amorces droites.
    arc(rect.topLeft.translate(_radius, _radius), 3.1416);
    arc(rect.topRight.translate(-_radius, _radius), -1.5708);
    arc(rect.bottomRight.translate(-_radius, -_radius), 0);
    arc(rect.bottomLeft.translate(_radius, -_radius), 1.5708);

    void line(Offset from, Offset to) => canvas.drawLine(from, to, corner);
    final l = _cornerLength - _radius;
    line(
      rect.topLeft.translate(_radius, 0),
      rect.topLeft.translate(_radius + l, 0),
    );
    line(
      rect.topLeft.translate(0, _radius),
      rect.topLeft.translate(0, _radius + l),
    );
    line(
      rect.topRight.translate(-_radius, 0),
      rect.topRight.translate(-_radius - l, 0),
    );
    line(
      rect.topRight.translate(0, _radius),
      rect.topRight.translate(0, _radius + l),
    );
    line(
      rect.bottomLeft.translate(_radius, 0),
      rect.bottomLeft.translate(_radius + l, 0),
    );
    line(
      rect.bottomLeft.translate(0, -_radius),
      rect.bottomLeft.translate(0, -_radius - l),
    );
    line(
      rect.bottomRight.translate(-_radius, 0),
      rect.bottomRight.translate(-_radius - l, 0),
    );
    line(
      rect.bottomRight.translate(0, -_radius),
      rect.bottomRight.translate(0, -_radius - l),
    );
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) => false;
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

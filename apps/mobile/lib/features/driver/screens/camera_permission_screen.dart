import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import 'scanner_screen.dart';

/// Pré-permission caméra : explique l'usage avant de déclencher la demande
/// système. Si l'accès est déjà accordé, passe directement au scanner.
class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  bool _requesting = false;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _goToScanner();
    }
  }

  void _goToScanner() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const ScannerScreen()));
  }

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _requesting = false;
      _permanentlyDenied = status.isPermanentlyDenied;
    });
    if (status.isGranted) _goToScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner une station')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Icon(Icons.qr_code_scanner, size: 64, color: AppColors.navy),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Fusy a besoin de la caméra',
                style: AppTypography.title2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pour scanner le QR code affiché dans la station et démarrer une transaction.',
                style: AppTypography.body.copyWith(color: AppColors.neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_permanentlyDenied) ...[
                Text(
                  'L\'accès à la caméra a été refusé. Autorisez-le dans les réglages de l\'appareil.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.errorText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Ouvrir les réglages',
                  onPressed: openAppSettings,
                ),
              ] else
                PrimaryButton(
                  label: 'Autoriser la caméra',
                  loading: _requesting,
                  onPressed: _requestPermission,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

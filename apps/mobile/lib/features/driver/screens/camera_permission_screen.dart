import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/empty_state.dart';
import 'pump_code_entry_screen.dart';
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

  void _goToCodeEntry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PumpCodeEntryScreen()),
    );
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
        child: Column(
          children: [
            Expanded(
              child: _permanentlyDenied
                  ? EmptyState(
                      icon: Icons.no_photography_rounded,
                      iconBg: AppColors.errorBg,
                      iconColor: AppColors.errorText,
                      title: 'Accès caméra refusé',
                      message:
                          'L\'accès à la caméra a été refusé. Autorisez-le dans les réglages de l\'appareil.',
                      actionLabel: 'Ouvrir les réglages',
                      onAction: openAppSettings,
                    )
                  : EmptyState(
                      icon: Icons.qr_code_scanner_rounded,
                      iconBg: AppColors.infoBg,
                      iconColor: AppColors.navy,
                      title: 'Fusy a besoin de la caméra',
                      message:
                          'Pour scanner le QR code affiché dans la station et démarrer une transaction.',
                    ),
            ),
            if (!_permanentlyDenied)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                child: PrimaryButton(
                  label: 'Autoriser la caméra',
                  loading: _requesting,
                  onPressed: _requestPermission,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              child: SecondaryButton(
                label: 'Saisir le code de la pompe',
                onPressed: _goToCodeEntry,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Annuler',
                  style: AppTypography.body.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

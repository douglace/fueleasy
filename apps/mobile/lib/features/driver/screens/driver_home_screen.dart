import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/amount_display.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/countdown_timer.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/auth_controller.dart';
import '../widgets/reveal_budget_sheet.dart';
import 'camera_permission_screen.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  int? _revealedBalance;
  DateTime? _revealExpiresAt;
  Duration _revealDuration = const Duration(seconds: 15);
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Future<void> _revealBudget() async {
    final reveal = await showRevealBudgetSheet(context);
    if (reveal == null || !mounted) return;
    AppHaptics.success();
    _hideTimer?.cancel();
    final duration = Duration(seconds: reveal.revealSeconds);
    setState(() {
      _revealedBalance = reveal.balance;
      _revealDuration = duration;
      _revealExpiresAt = DateTime.now().add(duration);
    });
    _hideTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _revealedBalance = null;
          _revealExpiresAt = null;
        });
      }
    });
  }

  void _openScanner() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CameraPermissionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.value;
    final revealed = _revealedBalance != null;

    return NavyHeaderScaffold(
      title: profile == null ? 'Accueil' : 'Bonjour, ${profile.name}',
      subtitle: 'Votre budget carburant, toujours à portée de main.',
      heroContent: AppCard(
        elevated: true,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: profile == null
            ? const SkeletonTheme(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 120),
                    SizedBox(height: AppSpacing.md),
                    SkeletonBox(width: 200, height: 40),
                    SizedBox(height: AppSpacing.md),
                    SkeletonLine(width: 160),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Budget disponible',
                          style: AppTypography.label,
                        ),
                      ),
                      if (revealed && _revealExpiresAt != null)
                        CountdownRing(
                          expiresAt: _revealExpiresAt!,
                          totalDuration: _revealDuration,
                          size: 36,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AmountDisplay(
                          amount: _revealedBalance ?? 0,
                          revealed: revealed,
                        ),
                      ),
                      if (!revealed)
                        TextButton.icon(
                          onPressed: _revealBudget,
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          label: const Text('Révéler'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                    ],
                  ),
                  if (profile.budget != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _budgetModeLabel(profile.budget!.mode.value),
                      style: AppTypography.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  StatusBadge(
                    label: profile.enterpriseStatus == 'operational'
                        ? 'Compte opérationnel'
                        : 'Recharge nécessaire',
                    tone: profile.enterpriseStatus == 'operational'
                        ? StatusTone.success
                        : StatusTone.warning,
                  ),
                ],
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        children: [
          SizedBox(
            height: 56,
            child: PrimaryButton(
              label: 'Scanner une station',
              icon: Icons.qr_code_scanner_rounded,
              background: AppColors.green,
              onPressed: _openScanner,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.infoBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.infoText,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Scannez le QR affiché à la pompe, saisissez le montant, puis confirmez avec votre PIN.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _budgetModeLabel(String mode) => switch (mode) {
    'weekly' => 'Renouvellement hebdomadaire',
    'monthly' => 'Renouvellement mensuel',
    _ => 'Attribution manuelle',
  };
}

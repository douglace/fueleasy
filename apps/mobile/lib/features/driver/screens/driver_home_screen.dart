import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
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
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Future<void> _revealBudget() async {
    final reveal = await showRevealBudgetSheet(context);
    if (reveal == null || !mounted) return;
    _hideTimer?.cancel();
    setState(() => _revealedBalance = reveal.balance);
    _hideTimer = Timer(Duration(seconds: reveal.revealSeconds), () {
      if (mounted) setState(() => _revealedBalance = null);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            Text(profile?.name ?? '', style: AppTypography.title2),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budget disponible', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xs),
                  if (_revealedBalance != null)
                    Text(
                      formatFcfa(_revealedBalance!),
                      style: AppTypography.amount,
                    )
                  else
                    Row(
                      children: [
                        Text('•••• FCFA', style: AppTypography.amount),
                        const SizedBox(width: AppSpacing.md),
                        TextButton(
                          onPressed: _revealBudget,
                          child: const Text('Révéler'),
                        ),
                      ],
                    ),
                  if (profile?.budget != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _budgetModeLabel(profile!.budget!.mode.value),
                      style: AppTypography.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  StatusBadge(
                    label: profile?.enterpriseStatus == 'operational'
                        ? 'Compte opérationnel'
                        : 'Recharge nécessaire',
                    tone: profile?.enterpriseStatus == 'operational'
                        ? StatusTone.success
                        : StatusTone.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Scanner une station',
              onPressed: _openScanner,
            ),
          ],
        ),
      ),
    );
  }

  String _budgetModeLabel(String mode) => switch (mode) {
    'weekly' => 'Renouvellement hebdomadaire',
    'monthly' => 'Renouvellement mensuel',
    _ => 'Attribution manuelle',
  };
}

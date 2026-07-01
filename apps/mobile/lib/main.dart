import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/format/money.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/app_buttons.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/status_badge.dart';

void main() {
  runApp(const ProviderScope(child: FusyApp()));
}

class FusyApp extends StatelessWidget {
  const FusyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fusy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _FoundationsDemoScreen(),
    );
  }
}

/// Écran de démonstration Phase 0 : vérifie que les tokens et composants
/// s'affichent correctement. Sera remplacé par le routage réel en Phase 2.
class _FoundationsDemoScreen extends StatelessWidget {
  const _FoundationsDemoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fusy — Fondations')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            Image.asset('assets/images/primary-logo.png', height: 56),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budget disponible', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xs),
                  Text(formatFcfa(50000), style: AppTypography.amount),
                  const SizedBox(height: AppSpacing.md),
                  const Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      StatusBadge(label: 'Payée', tone: StatusTone.success),
                      StatusBadge(label: 'À accuser', tone: StatusTone.warning),
                      StatusBadge(label: 'Expirée', tone: StatusTone.neutral),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Backend : ${AppConfig.apiBaseUrl}',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Scanner une station', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(label: 'Voir le reçu', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            const PrimaryButton(label: 'Chargement…', loading: true),
          ],
        ),
      ),
    );
  }
}

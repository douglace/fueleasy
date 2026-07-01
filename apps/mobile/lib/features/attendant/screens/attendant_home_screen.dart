import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/auth_controller.dart';

/// Stub de l'espace pompiste — remplacé par l'écran complet en Phase 5.
class AttendantHomeScreen extends ConsumerWidget {
  const AttendantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final name = auth.value?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Espace pompiste')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connecté', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text(name, style: AppTypography.title2),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SecondaryButton(
                label: 'Se déconnecter',
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/auth_controller.dart';

/// Identité en lecture seule et déconnexion.
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.value;
    final name = profile?.name ?? '';
    final initials = name.isEmpty
        ? '?'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join();

    return NavyHeaderScaffold(
      title: 'Profil',
      subtitle: 'Votre compte chauffeur Fusy.',
      heroContent: AppCard(
        elevated: true,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: AppTypography.title3.copyWith(
                  color: AppColors.greenDark,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chauffeur', style: AppTypography.label),
                  const SizedBox(height: 2),
                  Text(name, style: AppTypography.title2),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            DestructiveButton(
              label: 'Se déconnecter',
              icon: Icons.logout_rounded,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

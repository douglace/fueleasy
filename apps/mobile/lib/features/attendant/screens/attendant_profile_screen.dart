import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/info_banner.dart';
import '../../auth/auth_controller.dart';
import '../attendant_providers.dart';

/// Identité en lecture seule, session de travail en cours et déconnexion.
class AttendantProfileScreen extends ConsumerStatefulWidget {
  const AttendantProfileScreen({super.key});

  @override
  ConsumerState<AttendantProfileScreen> createState() =>
      _AttendantProfileScreenState();
}

class _AttendantProfileScreenState
    extends ConsumerState<AttendantProfileScreen> {
  bool _closing = false;
  String? _errorMessage;

  Future<void> _closeSession(int workSessionId) async {
    if (_closing) return;
    setState(() {
      _closing = true;
      _errorMessage = null;
    });
    try {
      await ref.read(workSessionRepositoryProvider).close(workSessionId);
      ref.invalidate(currentSessionProvider);
    } on Failure catch (f) {
      setState(() => _errorMessage = f.message);
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.value;
    final session = ref.watch(currentSessionProvider);
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
      subtitle: 'Votre compte pompiste Fusy.',
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
                color: AppColors.infoBg,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: AppTypography.title3.copyWith(color: AppColors.navy),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pompiste', style: AppTypography.label),
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
            session.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
              data: (qr) {
                if (qr == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      InlineBanner(message: _errorMessage!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    SecondaryButton(
                      label: 'Fermer la session',
                      icon: Icons.stop_circle_outlined,
                      onPressed: _closing
                          ? null
                          : () => _closeSession(qr.workSessionId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
            ),
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

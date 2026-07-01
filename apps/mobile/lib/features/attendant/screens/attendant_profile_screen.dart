import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
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
                    Text('Pompiste', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text(profile?.name ?? '', style: AppTypography.title2),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              session.when(
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
                data: (qr) {
                  if (qr == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        InlineErrorBanner(message: _errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      SecondaryButton(
                        label: 'Fermer la session',
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

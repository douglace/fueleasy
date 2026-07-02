import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../attendant_providers.dart';
import '../screens/open_session_screen.dart';

/// Carte de session : QR de la pompe affiché en grand, auto-rafraîchi avant
/// expiration (TTL 60 s côté serveur), ou invitation à ouvrir une session.
class SessionCard extends ConsumerStatefulWidget {
  const SessionCard({super.key});

  @override
  ConsumerState<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<SessionCard> {
  Timer? _refreshTimer;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleRefresh(int expiresInSeconds) {
    _refreshTimer?.cancel();
    final delay = Duration(seconds: (expiresInSeconds - 10).clamp(5, 120));
    _refreshTimer = Timer(delay, () {
      if (mounted) ref.invalidate(currentSessionProvider);
    });
  }

  Future<void> _openSession() async {
    final opened = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const OpenSessionScreen()));
    if (opened == true) ref.invalidate(currentSessionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentSessionProvider);

    return session.when(
      loading: () =>
          const AppCard(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => AppCard(
        child: Text(
          'Impossible de vérifier la session en cours.',
          style: AppTypography.body,
        ),
      ),
      data: (qr) {
        if (qr == null) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aucune session ouverte', style: AppTypography.title3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ouvrez une session pour afficher le QR de votre pompe.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Ouvrir une session',
                  onPressed: _openSession,
                ),
              ],
            ),
          );
        }

        _scheduleRefresh(qr.expiresIn);

        final pumps = ref.watch(attendantPumpsProvider).value ?? const [];
        final matches = pumps.where((p) => p.id == qr.pumpId);
        final pumpLabel = matches.isNotEmpty
            ? matches.first.label
            : 'Pompe ${qr.pumpId}';

        return AppCard(
          child: Column(
            children: [
              Text(pumpLabel, style: AppTypography.title3),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                image: true,
                label: 'QR code de la pompe à scanner par le chauffeur',
                child: QrImageView(
                  data: qr.qr,
                  size: 200,
                  backgroundColor: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Présentez ce QR au chauffeur',
                style: AppTypography.caption,
              ),
            ],
          ),
        );
      },
    );
  }
}

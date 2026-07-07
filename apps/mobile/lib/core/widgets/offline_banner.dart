import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Enveloppe l'app : affiche un bandeau persistant `Hors ligne` en bas dès que
/// la connexion est perdue. N'occulte jamais les actions (bandeau fin, en bas).
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).value ?? false;

    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: offline ? Offset.zero : const Offset(0, 1),
            duration: AppDurations.base,
            curve: AppCurves.emphasized,
            child: AnimatedOpacity(
              opacity: offline ? 1 : 0,
              duration: AppDurations.base,
              child: Semantics(
                liveRegion: true,
                container: true,
                label: 'Hors ligne, reconnexion automatique',
                child: Material(
                  color: Colors.transparent,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.warningText,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.lg,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 16,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Hors ligne — reconnexion automatique',
                            style: AppTypography.label.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

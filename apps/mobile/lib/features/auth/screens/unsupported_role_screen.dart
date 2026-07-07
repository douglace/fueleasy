import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/empty_state.dart';
import '../auth_controller.dart';

/// Affiché quand le compte connecté n'est ni chauffeur ni pompiste
/// (ex. compte admin) : ces rôles utilisent les dashboards web, pas l'app mobile.
class UnsupportedRoleScreen extends ConsumerWidget {
  const UnsupportedRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: EmptyState(
                icon: Icons.desktop_windows_rounded,
                title: 'Ce compte n\'est pas un compte mobile.',
                message:
                    'Les comptes administrateur utilisent les tableaux de bord web Fusy.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: DestructiveButton(
                label: 'Se déconnecter',
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

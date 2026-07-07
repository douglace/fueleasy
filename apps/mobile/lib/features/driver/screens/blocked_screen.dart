import 'package:flutter/material.dart';

import '../../../core/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

/// Page de blocage générique : une vérification préalable a échoué avant
/// création de la transaction (station non autorisée, budget/solde
/// insuffisant, compte suspendu…). Aucun débit n'a eu lieu.
class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key, required this.message});

  final String message;

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  @override
  void initState() {
    super.initState();
    AppHaptics.error();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demande bloquée')),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.block_rounded,
          iconBg: AppColors.errorBg,
          iconColor: AppColors.errorText,
          title: widget.message,
          message: 'Aucun montant n\'a été débité.',
          actionLabel: 'Retour à l\'accueil',
          onAction: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }
}

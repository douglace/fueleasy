import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import '../../core/providers.dart';
import '../../domain/entities.dart';

/// Pompes actives de la station du pompiste (choix à l'ouverture de session).
final attendantPumpsProvider = FutureProvider<List<PumpRef>>((ref) {
  return ref.watch(workSessionRepositoryProvider).pumps();
});

/// Session de travail ouverte courante, `null` si aucune n'est ouverte.
final currentSessionProvider = FutureProvider<WorkSessionQr?>((ref) async {
  try {
    return await ref.watch(workSessionRepositoryProvider).currentQr();
  } on NotFoundFailure {
    return null;
  }
});

/// Paiements du jour de la station du pompiste.
final attendantTodayPaymentsProvider = FutureProvider<List<Payment>>((ref) {
  return ref.watch(workSessionRepositoryProvider).todaysPayments();
});

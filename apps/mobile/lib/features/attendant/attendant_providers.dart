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

/// Périmètre d'historique choisi par le pompiste : sa pompe (défaut) ou
/// toute la station.
enum HistoryScope { pump, station }

class HistoryScopeNotifier extends Notifier<HistoryScope> {
  @override
  HistoryScope build() => HistoryScope.pump;

  void set(HistoryScope scope) => state = scope;
}

final historyScopeProvider =
    NotifierProvider<HistoryScopeNotifier, HistoryScope>(
      HistoryScopeNotifier.new,
    );

/// Paiements du jour, filtrés selon [historyScopeProvider]. Le serveur peut
/// élargir en vue station si aucune session n'est ouverte (voir
/// [TodayPayments.appliedScope]).
final attendantTodayPaymentsProvider = FutureProvider<TodayPayments>((ref) {
  final scope = ref.watch(historyScopeProvider);
  return ref
      .watch(workSessionRepositoryProvider)
      .todaysPayments(scope: scope.name);
});

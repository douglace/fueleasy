import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/entities.dart';

/// Historique du chauffeur (50 dernières transactions).
final driverHistoryProvider = FutureProvider<List<Payment>>((ref) {
  return ref.watch(paymentRepositoryProvider).history();
});

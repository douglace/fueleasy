import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `true` lorsque l'appareil n'a aucune connexion réseau.
/// Émet l'état courant au démarrage puis à chaque changement.
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  bool isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  yield isOffline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(isOffline);
});

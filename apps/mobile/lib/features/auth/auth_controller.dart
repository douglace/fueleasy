import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import '../../core/providers.dart';
import '../../domain/entities.dart';

/// État d'authentification global : `null` = non authentifié, sinon le profil
/// courant. `AsyncLoading` pendant la vérification initiale du jeton (splash),
/// `AsyncError` si la vérification échoue pour une raison autre que
/// "non authentifié" (ex. réseau indisponible).
class AuthController extends AsyncNotifier<MeProfile?> {
  @override
  Future<MeProfile?> build() async {
    final token = await ref.read(tokenStoreProvider).readToken();
    if (token == null || token.isEmpty) return null;

    try {
      return await ref.read(meRepositoryProvider).me();
    } on UnauthenticatedFailure {
      // Jeton invalide/révoqué : on nettoie et on retombe sur l'écran de connexion.
      await ref.read(tokenStoreProvider).clearToken();
      return null;
    }
    // Les autres échecs (réseau, etc.) se propagent en AsyncError : le splash
    // affiche un état d'erreur avec action "Réessayer".
  }

  Future<void> login({
    required String organizationCode,
    required String identifier,
    required String pin,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .login(
          organizationCode: organizationCode,
          identifier: identifier,
          pin: pin,
        );
    await _refreshProfile();
  }

  Future<void> activate({
    required String organizationCode,
    required String identifier,
    required String temporaryPin,
    required String newPin,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .activate(
          organizationCode: organizationCode,
          identifier: identifier,
          temporaryPin: temporaryPin,
          newPin: newPin,
        );
    await _refreshProfile();
  }

  Future<String> requestDeviceChange({
    required String organizationCode,
    required String identifier,
    required String pin,
  }) {
    return ref
        .read(authRepositoryProvider)
        .requestDeviceChange(
          organizationCode: organizationCode,
          identifier: identifier,
          pin: pin,
        );
  }

  Future<void> confirmDeviceChange({
    required String organizationCode,
    required String identifier,
    required String smsCode,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .confirmDeviceChange(
          organizationCode: organizationCode,
          identifier: identifier,
          smsCode: smsCode,
        );
    await _refreshProfile();
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> _refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(meRepositoryProvider).me());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, MeProfile?>(AuthController.new);

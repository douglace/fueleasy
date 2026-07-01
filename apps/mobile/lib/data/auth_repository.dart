import 'package:dio/dio.dart';

import '../core/network/api_executor.dart';
import '../core/storage/token_store.dart';
import '../domain/entities.dart';

/// Authentification mobile : activation, connexion, changement d'appareil.
/// Persiste le jeton dans [TokenStore] après une auth réussie.
class AuthRepository {
  AuthRepository(this._dio, this._tokenStore);

  final Dio _dio;
  final TokenStore _tokenStore;

  Future<AuthSession> activate({
    required String organizationCode,
    required String identifier,
    required String temporaryPin,
    required String newPin,
    String? deviceName,
  }) async {
    final deviceId = await _tokenStore.getOrCreateDeviceId();
    final session = await runApi(
      () => _dio.post(
        'auth/activate',
        data: {
          'organization_code': organizationCode,
          'identifier': identifier,
          'temporary_pin': temporaryPin,
          'new_pin': newPin,
          'device_id': deviceId,
          'device_name': ?deviceName,
        },
      ),
      (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
    await _tokenStore.writeToken(session.token);
    return session;
  }

  Future<AuthSession> login({
    required String organizationCode,
    required String identifier,
    required String pin,
  }) async {
    final deviceId = await _tokenStore.getOrCreateDeviceId();
    final session = await runApi(
      () => _dio.post(
        'auth/login',
        data: {
          'organization_code': organizationCode,
          'identifier': identifier,
          'pin': pin,
          'device_id': deviceId,
        },
      ),
      (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
    await _tokenStore.writeToken(session.token);
    return session;
  }

  /// Étape 1 du changement d'appareil : envoie un code SMS. Retourne le message.
  Future<String> requestDeviceChange({
    required String organizationCode,
    required String identifier,
    required String pin,
  }) async {
    final deviceId = await _tokenStore.getOrCreateDeviceId();
    return runApi(
      () => _dio.post(
        'auth/device/request',
        data: {
          'organization_code': organizationCode,
          'identifier': identifier,
          'pin': pin,
          'device_id': deviceId,
        },
      ),
      (data) => (data as Map<String, dynamic>)['message'] as String? ?? '',
    );
  }

  /// Étape 2 : confirme le changement d'appareil avec le code SMS.
  Future<AuthSession> confirmDeviceChange({
    required String organizationCode,
    required String identifier,
    required String smsCode,
  }) async {
    final deviceId = await _tokenStore.getOrCreateDeviceId();
    final session = await runApi(
      () => _dio.post(
        'auth/device/confirm',
        data: {
          'organization_code': organizationCode,
          'identifier': identifier,
          'sms_code': smsCode,
          'device_id': deviceId,
        },
      ),
      (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
    await _tokenStore.writeToken(session.token);
    return session;
  }

  /// Déconnexion locale (révoque le jeton stocké).
  Future<void> logout() => _tokenStore.clearToken();
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Stockage sécurisé du jeton Bearer et d'un identifiant d'appareil stable.
/// Un seul appareil actif par compte côté backend ; le device_id est généré
/// une fois puis persisté (stable tant que l'app n'est pas désinstallée).
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'fusy_token';
  static const _deviceIdKey = 'fusy_device_id';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  /// Retourne l'identifiant d'appareil, en le créant au premier appel.
  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }
}

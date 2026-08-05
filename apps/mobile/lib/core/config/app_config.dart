import 'package:flutter/foundation.dart' show kReleaseMode;

/// Configuration d'environnement injectée au build via --dart-define.
///
/// Résolution de l'URL du backend :
///   1. `--dart-define=API_BASE_URL=...` explicite : toujours prioritaire.
///   2. Sinon, défaut selon le mode de build :
///      - release : production `https://fusy.velko-pos.com`
///      - debug/profile : local `http://localhost:8000`
///
/// Exemples :
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   (émulateur Android)
///   flutter run --dart-define=API_BASE_URL=http://localhost:8000   (simulateur iOS)
///   flutter run --dart-define=API_BASE_URL=http://IP-DU-LAN:8000     (appareil physique)
///   flutter build apk --release                                    (production, défaut)
abstract final class AppConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');
  static const _production = 'https://fusy.velko-pos.com';
  static const _local = 'http://localhost:8000';

  /// URL racine du backend (sans le suffixe /api).
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    return kReleaseMode ? _production : _local;
  }

  /// Préfixe de l'API mobile versionnée (slash final pour une jointure fiable
  /// avec des chemins relatifs, ex. `auth/login`).
  static String get mobileApiUrl => '$apiBaseUrl/api/v1/mobile/';
}

/// Configuration d'environnement injectée au build via --dart-define.
///
/// Exemples :
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   (émulateur Android)
///   flutter run --dart-define=API_BASE_URL=http://localhost:8000   (simulateur iOS)
///   flutter run --dart-define=API_BASE_URL=http://IP-DU-LAN:8000     (appareil physique)
abstract final class AppConfig {
  /// URL racine du backend (sans le suffixe /api).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Préfixe de l'API mobile versionnée (slash final pour une jointure fiable
  /// avec des chemins relatifs, ex. `auth/login`).
  static String get mobileApiUrl => '$apiBaseUrl/api/v1/mobile/';
}

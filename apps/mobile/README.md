# Fusy — App mobile (Flutter)

App Flutter **unique** qui affiche l'interface **chauffeur** ou **pompiste** selon le
rôle du compte connecté (`role` renvoyé par `GET /me`). Elle consomme l'API mobile du
backend Laravel `apps/platform` (`/api/v1/mobile`).

## Prérequis

- **Flutter 3.41.6** (stable). Sur cette machine, le SDK est à
  `/Volumes/Work/flutterSdk/flutter/bin` et **n'est pas dans le PATH** :
  ```bash
  export PATH="/Volumes/Work/flutterSdk/flutter/bin:$PATH"
  ```
- Backend lancé (voir `apps/platform/docker/README.md`) : `docker compose up -d` → `:8000`.

## Configuration du backend (URL)

L'URL de l'API est injectée au build via `--dart-define=API_BASE_URL` (défaut
`http://localhost:8000`) :

| Cible | Valeur |
|---|---|
| Simulateur iOS | `http://localhost:8000` |
| Émulateur Android | `http://10.0.2.2:8000` |
| Appareil physique | `http://IP_LAN_DE_LA_MACHINE:8000` |

## Commandes

Toutes depuis `apps/mobile/` (avec le PATH Flutter exporté) :

| But | Commande |
|---|---|
| Installer les dépendances | `flutter pub get` |
| Lancer (simulateur iOS) | `flutter run --dart-define=API_BASE_URL=http://localhost:8000` |
| Lancer (émulateur Android) | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000` |
| Analyse statique | `flutter analyze` |
| Formatage | `dart format .` |
| Tests | `flutter test` |
| Build APK (Android) | `flutter build apk --dart-define=API_BASE_URL=...` |
| Build iOS | `flutter build ios --dart-define=API_BASE_URL=...` |

> Android : les `cmdline-tools` du SDK Android doivent être installés (via Android Studio
> ou le paquet cmdline-tools + `ANDROID_HOME`) avant de builder pour Android.

## Architecture

`lib/core` (thème, widgets, réseau, routeur, stockage, erreurs) · `lib/domain` (entités +
enums) · `lib/data` (repositories + DTO) · `lib/features` (auth, driver, attendant).
Stack : **Riverpod** (état/DI) + **Dio** (HTTP) + **go_router** (navigation par rôle).

Le plan de construction par phases est suivi hors dépôt. État actuel : **Phase 0 —
fondations** (thème, tokens, composants de base, config, CI).

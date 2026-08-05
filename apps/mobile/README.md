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

L'URL de l'API se résout ainsi (voir `lib/core/config/app_config.dart`) :

1. **Override explicite** : `--dart-define=API_BASE_URL=...` (toujours prioritaire).
2. **Défaut selon le mode de build** :
   - **release** (production) : `https://fusy.velko-pos.com`
   - **debug/profile** : `http://localhost:8000`

| Cible | Commande / valeur |
|---|---|
| Production (release, défaut) | `flutter build apk --release` → `https://fusy.velko-pos.com` |
| Simulateur iOS | `flutter run --dart-define=API_BASE_URL=http://localhost:8000` |
| Émulateur Android | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000` |
| Appareil physique | `flutter run --dart-define=API_BASE_URL=http://IP_LAN_DE_LA_MACHINE:8000` |

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
| Build APK (Android) | `flutter build apk --dart-define=API_BASE_URL=...` — sans `--dart-define`, l'APK release pointe vers la production `https://fusy.velko-pos.com` |
| Build iOS | `flutter build ios --dart-define=API_BASE_URL=...` — idem, release → production par défaut |

> Android : les `cmdline-tools` du SDK Android doivent être installés (via Android Studio
> ou le paquet cmdline-tools + `ANDROID_HOME`) avant de builder pour Android.

## Architecture

`lib/core` (thème, widgets, réseau, routeur, stockage, erreurs) · `lib/domain` (entités +
enums) · `lib/data` (repositories + DTO) · `lib/features` (auth, driver, attendant).
Stack : **Riverpod** (état/DI) + **Dio** (HTTP) + **go_router** (navigation par rôle).

## Comptes de test

Les comptes mobiles (chauffeur/pompiste) sont créés côté back-office. Pour tester,
générer un PIN temporaire via tinker dans le conteneur `apps/platform` :

```bash
docker compose exec app php artisan tinker --execute='
  $u = App\Models\User::find(3); // chauffeur seedé (Boris Mballa)
  echo app(App\Application\Identity\MobileAccountAdmin::class)->resetPin($u, null);'
```

Puis, dans l'app : **Activer mon compte** avec code entreprise `SCEFEA`, le téléphone du
compte et ce PIN temporaire. Le scan QR nécessite un **appareil physique** (le simulateur
iOS n'a pas de caméra) ; le token QR de la pompe seedée s'obtient aussi via tinker.

## Localisation

App **mono-locale française** (MVP). `flutter_localizations` + `Locale('fr')` fournissent
les libellés Material et le formatage des dates. Une extraction i18n complète (ARB) est
volontairement **différée** tant qu'aucune 2ᵉ langue n'est requise (YAGNI).

## Icône & splash

Générés via `flutter_launcher_icons` / `flutter_native_splash` depuis
`assets/images/` (config dans `pubspec.yaml`) :

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

> ⚠️ L'export `app-icon.png` a un extérieur noir à retravailler avant la production
> (cf. `design-briefs/00-shared/assets-index.md`). Régénérer après avoir remplacé l'asset.

## Builds release

- **Android** (AAB) : `flutter build appbundle --dart-define=API_BASE_URL=...`.
  Prérequis non installés sur cette machine : `cmdline-tools` du SDK Android
  (`flutter doctor` le signale) + acceptation des licences.
- **iOS** : `flutter build ipa --dart-define=API_BASE_URL=...` — nécessite une identité de
  signature Apple configurée dans Xcode. Vérif de compilation sans signature :
  `flutter build ios --simulator --dart-define=API_BASE_URL=...`.

## État de construction

Construite par phases (plan suivi hors dépôt). **Phases 0 à 6 livrées** :
fondations/design system, couche données & contrat API, auth + aiguillage par rôle,
parcours paiement chauffeur, historique & reçus, espace pompiste (session + consultation +
accusé), finition (localisation FR, bandeau hors-ligne, icône/splash, accessibilité).

# Fusy Apps Initialization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialiser dans `apps/` la plateforme Laravel + Inertia React et l'application Flutter unifiée de Fusy, avec des builds et tests de base fonctionnels.

**Architecture:** Le monorepo contient une plateforme serveur unique dans `apps/platform` et une application mobile unique dans `apps/mobile`. Laravel porte l'API, les dashboards Fusy/entreprise/station et le domaine métier. Flutter porte les interfaces chauffeur et pompiste selon le rôle retourné par l'API.

**Tech Stack:** PHP 8.4, Laravel 13, PostgreSQL, Inertia, React 19, TypeScript, Tailwind CSS, Node.js 20, npm 10, Flutter 3.44+, Dart, Android, iOS.

## Global Constraints

- Conserver tous les projets applicatifs sous `apps/`.
- Utiliser une seule plateforme Laravel/Inertia et une seule app Flutter.
- Utiliser PostgreSQL comme base cible.
- Utiliser PHPUnit pour les tests Laravel.
- Générer uniquement les plateformes Flutter Android et iOS.
- Ne pas ajouter de dépendance métier pendant cette initialisation.
- Ne pas ajouter de mention d'IA ou de co-auteur dans les commits.
- Exclure `.DS_Store`, `.superpowers/`, le CV personnel et les secrets locaux du dépôt.
- Le contrôle Sonatype doit être réessayé avant installation ; si son authentification reste indisponible, documenter le résultat et exécuter les audits Composer/npm après scaffolding.

---

### Task 1: Préparer La Racine Du Monorepo

**Files:**
- Create: `.gitignore`
- Create: `apps/README.md`

**Interfaces:**
- Consumes: le dossier de projet `/Volumes/vexi/www/openintech/fueleasy`.
- Produces: la convention `apps/platform` et `apps/mobile` utilisée par les tâches suivantes.

- [ ] **Step 1: Créer le fichier `.gitignore`**

```gitignore
.DS_Store
**/.DS_Store
.superpowers/
Douglace_K_CV_Developpeur_Fullstack_Laravel.pdf

# Secrets et environnements locaux
.env
.env.*
!.env.example

# Laravel
apps/platform/vendor/
apps/platform/node_modules/
apps/platform/public/build/
apps/platform/storage/*.key
apps/platform/storage/logs/*.log

# Flutter
apps/mobile/.dart_tool/
apps/mobile/.flutter-plugins
apps/mobile/.flutter-plugins-dependencies
apps/mobile/.packages
apps/mobile/build/
apps/mobile/ios/Pods/
apps/mobile/ios/.symlinks/
```

- [ ] **Step 2: Documenter les applications**

Créer `apps/README.md` :

```markdown
# Fusy Applications

## platform

Application Laravel unique : API, dashboards Fusy/entreprise/station et logique métier.

## mobile

Application Flutter unique : interface chauffeur ou pompiste selon le rôle du compte.
```

- [ ] **Step 3: Initialiser Git si nécessaire**

Run:

```bash
test -d .git || git init -b main
```

Expected: dépôt Git local sur la branche `main`.

- [ ] **Step 4: Vérifier les exclusions**

Run:

```bash
git status --short
```

Expected: le CV, `.DS_Store` et `.superpowers/` ne figurent pas dans la liste.

- [ ] **Step 5: Commit**

```bash
git add .gitignore apps/README.md
git commit -m "chore: prepare Fusy monorepo"
```

---

### Task 2: Initialiser La Plateforme Laravel Inertia React

**Files:**
- Create: `apps/platform/`
- Verify: `apps/platform/composer.json`
- Verify: `apps/platform/package.json`
- Verify: `apps/platform/resources/js/app.tsx`
- Test: `apps/platform/tests/`

**Interfaces:**
- Consumes: PHP 8.4, Composer 2.7, Node.js 20, npm 10 et Laravel Installer 5.24+.
- Produces: application Laravel `apps/platform`, commande `php artisan`, frontend Inertia React et suite PHPUnit.

- [ ] **Step 1: Réessayer le contrôle de dépendances Sonatype**

Analyser avant installation :

```text
pkg:composer/laravel/framework@13
pkg:npm/react@19
pkg:npm/@inertiajs/react@3
```

Expected: rapport de sécurité/licence disponible, ou échec d'authentification explicitement consigné.

- [ ] **Step 2: Générer le starter kit React officiel**

Run depuis la racine :

```bash
laravel new apps/platform --react --database=pgsql --npm --phpunit --no-interaction
```

Expected: application Laravel avec React, TypeScript, Inertia, Tailwind et authentification intégrée.

- [ ] **Step 3: Vérifier la version et la configuration**

Run:

```bash
cd apps/platform
php artisan --version
php artisan about
```

Expected: Laravel 13.x, PHP 8.4.x et environnement local chargé.

- [ ] **Step 4: Exécuter les tests générés**

Run:

```bash
php artisan test
```

Expected: tous les tests générés passent.

- [ ] **Step 5: Construire le frontend**

Run:

```bash
npm run build
```

Expected: build Vite réussi sans erreur TypeScript.

- [ ] **Step 6: Auditer les dépendances installées**

Run:

```bash
composer audit
npm audit --audit-level=high
```

Expected: aucune vulnérabilité haute/critique non traitée.

- [ ] **Step 7: Commit**

```bash
cd ../..
git add apps/platform
git commit -m "chore: scaffold Fusy platform"
```

---

### Task 3: Poser Les Conventions Minimales De La Plateforme

**Files:**
- Modify: `apps/platform/.env.example`
- Create: `apps/platform/docs/architecture.md`
- Test: `apps/platform/tests/Feature/HealthCheckTest.php`
- Create: `apps/platform/routes/api.php`

**Interfaces:**
- Consumes: application Laravel générée par Task 2.
- Produces: endpoint public `GET /api/health` retournant `{"status":"ok","app":"Fusy"}` et conventions d'architecture.

- [ ] **Step 1: Écrire le test de health check**

Créer `apps/platform/tests/Feature/HealthCheckTest.php` :

```php
<?php

declare(strict_types=1);

namespace Tests\Feature;

use Tests\TestCase;

final class HealthCheckTest extends TestCase
{
    public function test_health_endpoint_returns_application_status(): void
    {
        $this->getJson('/api/health')
            ->assertOk()
            ->assertExactJson([
                'status' => 'ok',
                'app' => 'Fusy',
            ]);
    }
}
```

- [ ] **Step 2: Vérifier que le test échoue**

Run:

```bash
cd apps/platform
php artisan test --filter=HealthCheckTest
```

Expected: FAIL avec une réponse 404.

- [ ] **Step 3: Créer la route API minimale**

Créer `apps/platform/routes/api.php` :

```php
<?php

declare(strict_types=1);

use Illuminate\Support\Facades\Route;

Route::get('/health', static fn (): array => [
    'status' => 'ok',
    'app' => 'Fusy',
]);
```

Enregistrer `routes/api.php` dans `bootstrap/app.php` via l'argument `api` de `withRouting`.

- [ ] **Step 4: Configurer le nom et PostgreSQL d'exemple**

Dans `apps/platform/.env.example`, définir :

```dotenv
APP_NAME=Fusy
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=fusy
DB_USERNAME=postgres
DB_PASSWORD=
```

- [ ] **Step 5: Documenter les frontières applicatives**

Créer `apps/platform/docs/architecture.md` :

```markdown
# Platform Architecture

- `app/Domain`: règles métier indépendantes du transport HTTP.
- `app/Application`: cas d'usage et orchestration.
- `app/Http`: contrôleurs, middlewares, requests et resources.
- `resources/js`: dashboards Inertia React selon organisation/rôle.
- `routes/web.php`: dashboards web.
- `routes/api.php`: API mobile versionnée.
```

- [ ] **Step 6: Vérifier le test et le build**

Run:

```bash
php artisan test --filter=HealthCheckTest
npm run build
```

Expected: test PASS et build Vite réussi.

- [ ] **Step 7: Commit**

```bash
cd ../..
git add apps/platform
git commit -m "chore: configure Fusy platform baseline"
```

---

### Task 4: Installer Flutter Et Initialiser L'Application Mobile

**Files:**
- Create: `apps/mobile/`
- Verify: `apps/mobile/pubspec.yaml`
- Modify: `apps/mobile/lib/main.dart`
- Test: `apps/mobile/test/widget_test.dart`

**Interfaces:**
- Consumes: Flutter SDK 3.44+ et Dart fournis par Flutter.
- Produces: application `fusy` Android/iOS exécutable avec une suite de tests de base.

- [ ] **Step 1: Installer ou exposer Flutter dans le PATH**

Suivre l'installation macOS officielle Flutter 3.44+, puis vérifier :

```bash
flutter --version
flutter doctor -v
```

Expected: Flutter 3.44+ détecté. Les composants Android et Xcode requis sont identifiés par `flutter doctor`.

- [ ] **Step 2: Générer l'application mobile minimale**

Run depuis la racine :

```bash
flutter create apps/mobile --org com.fusy --project-name fusy --platforms=android,ios --empty
```

Expected: projets Android/iOS et `lib/main.dart` générés.

- [ ] **Step 3: Vérifier l'analyse statique**

Run:

```bash
cd apps/mobile
flutter analyze
```

Expected: `No issues found!`.

- [ ] **Step 4: Exécuter les tests Flutter**

Run:

```bash
flutter test
```

Expected: tous les tests générés passent.

- [ ] **Step 5: Vérifier les builds sans signature**

Run:

```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```

Expected: APK debug Android et build iOS sans signature générés.

- [ ] **Step 6: Commit**

```bash
cd ../..
git add apps/mobile
git commit -m "chore: scaffold Fusy mobile app"
```

---

### Task 5: Vérifier Le Monorepo Initialisé

**Files:**
- Modify: `apps/README.md`

**Interfaces:**
- Consumes: `apps/platform` et `apps/mobile` initialisés.
- Produces: commandes de démarrage locales documentées et baseline vérifiée.

- [ ] **Step 1: Ajouter les commandes de démarrage**

Compléter `apps/README.md` :

````markdown
## Démarrer la plateforme

```bash
cd apps/platform
composer run dev
```

## Démarrer l'app mobile

```bash
cd apps/mobile
flutter run
```

## Vérifications

```bash
cd apps/platform && php artisan test && npm run build
cd ../mobile && flutter analyze && flutter test
```
````

- [ ] **Step 2: Lancer la vérification Laravel finale**

Run:

```bash
cd apps/platform
php artisan test
npm run build
```

Expected: suite Laravel et build frontend réussis.

- [ ] **Step 3: Lancer la vérification Flutter finale**

Run:

```bash
cd ../mobile
flutter analyze
flutter test
```

Expected: analyse et tests Flutter réussis.

- [ ] **Step 4: Vérifier le statut Git**

Run:

```bash
cd ../..
git status --short
```

Expected: aucune modification non commitée liée à l'initialisation.

- [ ] **Step 5: Commit documentation si nécessaire**

```bash
git add apps/README.md
git commit -m "docs: document Fusy app workflows"
```

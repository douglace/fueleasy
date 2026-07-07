# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

**Fusy** — plateforme B2B de gestion des budgets carburant. Elle remplace les bons carburant papier et les avances cash par un compte carburant prépayé par entreprise, des budgets par chauffeur, des stations autorisées et une validation digitale à la pompe. Le MVP est **fermé** : entreprises, stations et pompistes sont créés manuellement par Fusy après signature commerciale (pas de self-service, pas de B2C).

Le plan produit complet et la matrice des sprints se trouvent dans [`plan_mvp/`](plan_mvp/00_OVERVIEW.md) et le cahier des charges dans `CDC_FINAL.md`. Lire `plan_mvp/00_OVERVIEW.md` avant toute décision produit — il contient les décisions MVP validées et le périmètre out-of-scope.

## Structure du monorepo

Un seul dépôt git à la racine `fueleasy/`. Le code applicatif vit dans `apps/` :

- `apps/platform/` — **application Laravel** : API mobile, dashboards web (admin Fusy / entreprise / station) et toute la logique métier. **C'est ici que se passe ~tout le travail de code.**
- `apps/mobile/` — app Flutter (chauffeur ou pompiste selon le rôle du compte). Non présente à ce jour.

`docs/`, `design-briefs/`, `assets/` et `plan_mvp/` sont de la documentation/specs, pas du code.

## Commandes

**Toutes les commandes ci-dessous se lancent depuis `apps/platform/`.**

| But | Commande |
|---|---|
| Installer + initialiser (env, key, migrate, build) | `composer setup` |
| Dev complet (serveur + queue + logs Pail + Vite) | `composer dev` |
| Tests PHP | `php artisan test` |
| Un seul test | `php artisan test --filter=NomDuTest` |
| Suite CI complète (lint + format + types + tests) | `composer ci:check` |
| Lint PHP (fix) / check | `composer lint` / `composer lint:check` |
| Analyse statique PHPStan (larastan, level 7) | `composer types:check` |
| Lint JS/TS (fix) / check | `npm run lint` / `npm run lint:check` |
| Format Prettier (write) / check | `npm run format` / `npm run format:check` |
| Types TS | `npm run types:check` |
| Build front | `npm run build` |

Le script `composer test` enchaîne `lint:check` + `types:check` + `php artisan test` — c'est le filet de sécurité avant commit. La CI GitHub (`apps/platform/.github/workflows/`) exécute lint et tests séparément.

## Stack & conventions

- **Backend** : Laravel 13, PHP ^8.3. Auth via **Fortify** (2FA + passkeys déjà câblés, voir `app/Providers/FortifyServiceProvider.php`). Style imposé par **Pint** (`pint.json`), analyse **PHPStan/larastan level 7** sur `app/`, `config/`, `database/`, `routes/`, `bootstrap/app.php`.
- **Frontend** : **Inertia + React 19 + TypeScript**, Tailwind 4, composants Radix/shadcn (`components.json`), Vite 8. Lint ESLint + Prettier (`prettier-plugin-tailwindcss`).
- **Base de données** : **PostgreSQL** en dev/prod (`DB_CONNECTION=pgsql`, base `fusy`) **et en test** (base `fusy_testing`, voir `phpunit.xml`). Le schéma utilise des fonctionnalités PostgreSQL natives (index uniques partiels, triggers d'immutabilité du ledger, verrous `FOR UPDATE`) ; SQLite n'est pas supporté. Les tests de concurrence (`PaymentConcurrencyTest`) utilisent `pcntl_fork` pour de vrais processus parallèles. Sessions, cache et queue sur driver `database`.

### Wayfinder & routes typées (piège important)

`laravel/wayfinder` + `@laravel/vite-plugin-wayfinder` **génèrent** `resources/js/actions/`, `resources/js/routes/` et `resources/js/wayfinder/` à partir des routes/contrôleurs PHP. Ces dossiers sont **git-ignorés et régénérés au build/dev** — ne pas les éditer à la main et ne pas se fier à leur contenu comme source de vérité. La source de vérité reste `routes/*.php` et les contrôleurs.

## Architecture cible (`apps/platform`)

Le doc `apps/platform/docs/architecture.md` décrit la cible :

- `app/Domain` — règles métier indépendantes du transport HTTP.
- `app/Application` — cas d'usage / orchestration.
- `app/Http` — contrôleurs, middlewares, requests, resources.
- `resources/js` — dashboards Inertia React par organisation/rôle.
- `routes/web.php` — dashboards web ; `routes/api.php` — API mobile versionnée.

**État actuel** : la plateforme V3 est implémentée. Les couches `app/Domain` (Organizations, Identity, FuelAccounts, DriverBudgets, Stations, Payments, Operations, Demo, Shared) et `app/Application` (mêmes modules) sont en place. `routes/api.php` expose l'API mobile versionnée `v1/mobile` (auth PIN/appareil, scan, paiement, reçus, alertes pompiste). `routes/web.php` expose les dashboards Inertia Admin Fusy / Entreprise / Station (RBAC via middleware `role:`). `routes/console.php` planifie les jobs (expiration paiements, reset budgets, reversements). Vérifier les namespaces existants avant d'ajouter du code.

## Modèle métier (à implémenter)

Acteurs : **Admin Fusy**, **Entreprise** (compte carburant prépayé), **Chauffeur** (budget + PIN 4 chiffres), **Pompiste**, **Station** (QR fixe).

Flux transaction de référence (voir `plan_mvp/00_OVERVIEW.md` §5) : le chauffeur scanne le QR station → Fusy vérifie (station autorisée pour l'entreprise, chauffeur/entreprise/station actifs, budget chauffeur, solde entreprise) **avant création** → le chauffeur saisit montant + type carburant → demande valable **5 min** → le chauffeur **confirme par PIN** → débit **immédiat** du compte entreprise **et** du budget chauffeur → reçu généré. Le **pompiste ne valide ni ne refuse** : il **consulte** les paiements de sa station (jour, recherche par code) et **accuse réception** de l'alerte ; il ne modifie jamais le montant. États réels du paiement (`app/Domain/Payments/PaymentStatus.php`) : `Pending → Paid → Expired/Failed/Refunded` — il n'existe aucun état de validation pompiste.

Distinction structurante à préserver dans l'UI et le code : le **budget chauffeur** (enveloppe d'autorisation) n'est pas le **solde du compte carburant entreprise** (argent réel prépayé). Un reset de budget *remplace* le solde restant, il ne l'additionne pas.

## État livré & à venir

- **App mobile Flutter** (`apps/mobile/`) — **livrée, phases 0→6** (Flutter 3.41.6, Riverpod + Dio + go_router). Une seule app qui affiche l'interface chauffeur ou pompiste selon le `role` renvoyé par `GET /me`. Consomme l'API `v1/mobile`. Périmètre couvert : design system + composants ; couche données typée (repositories Auth/Me/Payment/WorkSession) ; auth (activation code entreprise + identifiant + PIN, login, changement d'appareil) et aiguillage par rôle ; parcours paiement chauffeur (scan QR → montant/carburant → PIN → reçu, avec expiration/blocages/reprise réseau) ; historique & reçus PDF ; espace pompiste (session de travail + QR, paiements du jour, recherche par code, accusé de réception) ; finition (localisation FR, bandeau hors-ligne, icône/splash, a11y). 60 tests + build iOS simulateur vérifiés. Commandes et détails dans [`apps/mobile/README.md`](apps/mobile/README.md). **Le SDK Flutter n'est pas dans le PATH** sur cette machine : `export PATH="/Volumes/Work/flutterSdk/flutter/bin:$PATH"`. URL backend injectée via `--dart-define=API_BASE_URL=...` (émulateur Android : `http://10.0.2.2:8000`). Reste hors app : scan QR testable seulement sur appareil physique (pas de caméra simulateur), builds release (cmdline-tools Android + signature iOS), retouche de l'icône (extérieur noir).
- **Contrat API mobile — 2 ajustements faits côté `apps/platform` pendant le build mobile** : `PaymentResource` expose désormais `alert_acknowledged_at` ; nouvel endpoint `GET v1/mobile/station/pumps` (pompes actives de la station du pompiste). Les réponses `POST/GET payments` et `confirm` sont **enveloppées dans `{data:...}`** (PaymentResource via `->response()`), contrairement à `search`/`by-key`/`today` — piège vérifié en direct.
- **Mise en conformité 2026-07-07** : (1) **fallback code pompe** — chaque pompe porte un `code` court (6 chars, `PumpCode`, unique global) affiché dans le dashboard station ; `POST scan`/`POST payments` acceptent `{qr}` OU `{code}` (`via='code'`, résolu par `ResolvePumpCode` qui suit `pump.status`, pas `fixed_qr_active`) ; écran mobile `PumpCodeEntryScreen` accessible depuis le scanner et l'écran permission caméra. (2) **Historique pompiste par pompe** — `GET station/payments/today?scope=pump|station` (défaut `pump` = pompe de la session ouverte, fallback station sans session) ; réponse enrichie de `scope`/`pump_id` ; toggle « Ma pompe / Toute la station » côté mobile. (3) Édition de fiches chauffeur/pompiste (`PATCH`), colonne « Accusé » côté station, suspension d'organisation admin (`SetOrganizationStatus`), vue admin `stations/{id}`, filtres serveur sur les transactions admin.
- **Déploiement** — runbook manuel VPS documenté dans [`docs/RUNBOOK_DEPLOIEMENT.md`](apps/platform/docs/RUNBOOK_DEPLOIEMENT.md) (migrations, build, queue + scheduler, sauvegarde, rollback).
- **Seeders pilote** — `database/seeders/DatabaseSeeder.php` seede un environnement pilote complet (Admin Fusy `admin@fusy.test`/`password`, entreprise créditée + chauffeurs/budgets, station + pompe + pompiste, autorisation, organisation démo). Idempotent. Lancer : `php artisan migrate:fresh --seed`.
- **Checklist d'implémentation** : [`docs/IMPLEMENTATION_CHECKLIST.md`](apps/platform/docs/IMPLEMENTATION_CHECKLIST.md).

### Préparer la base de test (PostgreSQL)

```bash
createdb fusy && createdb fusy_testing   # une fois
php artisan migrate                       # base dev
php artisan test                          # tourne sur fusy_testing (voir phpunit.xml)
```

## Bug tracking

Ce projet suit la règle `lesson.md` (cf. instructions globales). Avant de débugger, lire `apps/platform/lesson.md` s'il existe ; après un fix non trivial, y ajouter une entrée en tête.

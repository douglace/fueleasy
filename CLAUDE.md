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

Flux transaction de référence (voir `plan_mvp/00_OVERVIEW.md` §5) : le chauffeur scanne le QR station → Fusy vérifie (station autorisée pour l'entreprise, chauffeur/entreprise/station actifs, budget chauffeur, solde entreprise) **avant création** → le chauffeur saisit montant + type carburant → demande valable **5 min** → le pompiste valide/refuse (il ne modifie jamais le montant) → le chauffeur confirme par **PIN** → débit du compte entreprise **et** du budget chauffeur → reçu généré.

Distinction structurante à préserver dans l'UI et le code : le **budget chauffeur** (enveloppe d'autorisation) n'est pas le **solde du compte carburant entreprise** (argent réel prépayé). Un reset de budget *remplace* le solde restant, il ne l'additionne pas.

## État livré & à venir

- **App mobile Flutter** (`apps/mobile/`) — **hors périmètre de ce dépôt**. Tous les contrats API nécessaires sont opérationnels et testés sous `routes/api.php` (`v1/mobile`). À sa création, documenter ici les commandes Flutter.
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

# Lessons — apps/platform

## 2026-06-25 — `php artisan serve` écrase l'env du conteneur avec le .env

**Symptôme** : en Docker, les migrations passaient (connexion à `db`) mais les pages web renvoyaient 500 avec `SQLSTATE[08006] connection to server at "127.0.0.1" port 5432 failed`. `config('database.connections.pgsql.host')` via `tinker` retournait pourtant `db`.

**Cause** : `php artisan serve` lit le fichier `.env` et **passe ces valeurs au sous-process du serveur PHP**, écrasant les variables d'environnement héritées du conteneur. Le `.env` (issu de `.env.example`) contenait `DB_HOST=127.0.0.1`. Les commandes directes (migrate, tinker) voyaient l'env Docker (`db`) ; le serveur, lui, recevait `127.0.0.1` du `.env`. D'où l'incohérence.

**Correction** : l'entrypoint Docker synchronise le `.env` avec les variables d'environnement du conteneur avant `artisan serve` (`docker-entrypoint.sh`, fonction `sync_env`).

**Pour la prochaine fois** : migrations OK mais requêtes web KO sur le même host de DB en conteneur ⇒ suspecter le passthrough `.env` de `artisan serve`, pas la config Laravel.

## 2026-06-25 — Image Docker PHP 8.3 vs composer.lock résolu en 8.4

**Symptôme** : `composer install` dans le build Docker échoue : `symfony/* v8.1.0 requires php >=8.4.1 -> your php version (8.3.31) does not satisfy`.

**Cause** : `composer.json` déclare `"php": "^8.3"` mais le `composer.lock` a été généré sur l'hôte en PHP 8.4.1, épinglant des paquets Symfony v8 exigeant 8.4.1. Une image de base `php:8.3` ne satisfait pas le lock.

**Correction** : `Dockerfile` en `php:8.4-cli-bookworm` (aligné sur le lock et l'hôte).

**Pour la prochaine fois** : erreur `requires php >= X -> your php version (Y)` au build ⇒ aligner l'image de base sur la version qui a généré `composer.lock`, pas seulement sur la contrainte de `composer.json`.

## 2026-06-24 — Double comptage du reversement après remboursement

**Symptôme** : `pendingAmount` d'une station valait 40 000 au lieu de 50 000 après remboursement d'un paiement de 10 000 (sur 60 000 de ventes).

**Cause** : un paiement remboursé passe en statut `Refunded`, donc il quitte déjà la somme des paiements `Paid`. Déduire EN PLUS le montant du remboursement le comptait deux fois. La déduction d'un remboursement ne doit s'appliquer qu'aux paiements **déjà reversés** (`payments.settled_batch_id IS NOT NULL`) — argent déjà versé à la station, à reprendre.

**Correction** : `SettlementService::pendingAmount` et `generateForStation` filtrent les remboursements déductibles sur `payments.settled_batch_id IS NOT NULL` (`app/Application/Operations/SettlementService.php`).

**Pour la prochaine fois** : tout calcul de solde net mêlant changement de statut ET écriture compensatoire ⇒ vérifier qu'un même montant n'est pas retiré deux fois (une fois par le statut, une fois par la compensation).

## 2026-06-24 — FK sur un id codé en dur casse en fin de suite (séquences PG)

**Symptôme** : un test passant isolément échoue avec `FK violation: Key (decided_by)=(1) is not present in users` quand il s'exécute après d'autres tests.

**Cause** : sous `RefreshDatabase` (transactions enveloppantes), un rollback n'annule PAS l'avancement des séquences PostgreSQL. Les `id` augmentent de test en test, donc `id = 1` n'existe plus dans les tests tardifs. Coder un id en dur (`decidedBy: 1`) est fragile.

**Correction** : créer l'acteur réel dans le test (`User::factory()->fusyAdmin()->create()`) et utiliser `$admin->id`.

**Pour la prochaine fois** : « Key (...)=(1) is not present » intermittent selon l'ordre des tests ⇒ id codé en dur, créer l'entité.

## 2026-06-24 — Désactiver une feature Fortify casse le build Wayfinder

**Symptôme** : après retrait de `Features::registration()` de `config/fortify.php`, `npm run build` échoue (ou les pages référencent un export inexistant) car `resources/js/pages/*.tsx` importaient `{ register } from '@/routes'`.

**Cause** : `laravel/wayfinder` génère `resources/js/routes/` à partir des routes PHP enregistrées. Supprimer une feature Fortify supprime sa route, donc l'export TS correspondant disparaît. Tout composant qui l'importe casse le build. Ce n'est pas visible côté PHP (tests verts) — seul le build front le révèle.

**Correction** : retirer aussi `registerView`, l'action `CreateNewUser`, la page `auth/register.tsx`, et toutes les références `register()` dans `welcome.tsx` / `auth/login.tsx`. Toujours lancer `npm run build` après avoir touché aux features Fortify/aux routes.

**Pour la prochaine fois** : « export X introuvable dans @/routes » ou build front cassé après modif d'auth ⇒ une route PHP a disparu, chercher les imports Wayfinder orphelins.

## 2026-06-24 — Tests sur PostgreSQL, pas SQLite

**Symptôme** : choix d'environnement de test à l'amorçage du projet.

**Cause** : le schéma utilise des fonctionnalités PostgreSQL natives (index uniques **partiels** `WHERE ... IS NOT NULL`, verrouillage `FOR UPDATE`, contraintes financières). SQLite ne les supporte pas identiquement et masquerait des bugs de concurrence/atomicité sur un système financier.

**Correction** : `phpunit.xml` pointe sur la base `fusy_testing` (pgsql). Bases créées : `fusy` (dev) et `fusy_testing` (test), owner `computer-care`. `.env` corrigé (l'original pointait vers `DB_DATABASE=apps/platform` / `DB_USERNAME=root`, invalides).

**Pour la prochaine fois** : un test qui passe en local mais devrait tester un verrou/une contrainte ⇒ vérifier qu'il tourne bien sur PG et non SQLite.

# Lessons — apps/platform

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

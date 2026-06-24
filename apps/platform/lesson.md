# Lessons — apps/platform

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

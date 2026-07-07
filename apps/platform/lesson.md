# Lessons — apps/platform

## 2026-07-07 — Gate CI masquée par un pipe ; callback http_mock_adapter exécuté à l'enregistrement

**Symptôme** : (1) `composer ci:check 2>&1 | tail` annoncé « exit 0 » alors que PHPUnit avait échoué (136 tests KO, base Postgres arrêtée) — la porte de sortie avant commit était un faux positif. (2) Côté mobile, un test `http_mock_adapter` qui posait un flag dans le callback `onPost('…/close', (server) { called = true; … })` voyait le flag à `true` sans qu'aucune requête ne parte.

**Cause** : (1) dans un pipe zsh, le code de sortie est celui de la **dernière** commande (`tail`) — l'échec de `composer ci:check` est avalé. (2) `http_mock_adapter` exécute le callback `onPost/onGet` **au moment de l'enregistrement** (pour construire la réponse), pas au moment de la requête : tout effet de bord y est déclenché immédiatement.

**Correction** : (1) lire le JSON `{"tool":"phpunit","result":…}` de la sortie (ou `set -o pipefail`) plutôt que se fier au code de sortie d'un pipe ; le conteneur `platform-db-1` doit tourner (`docker start platform-db-1`). (2) Tracer les appels réels via un `InterceptorsWrapper` sur Dio (`onRequest` → liste des paths) et garder les callbacks d'adapter purs (uniquement `server.reply`).

**Pour la prochaine fois** : ne jamais conclure « gate verte » depuis un pipe tronqué — chercher la ligne `"result":"passed"` de chaque outil. Dans les tests Flutter, un callback d'adapter n'est pas un espion de requête.

## 2026-07-03 — `public/hot` résiduel casse le serve hôte ; lock npm désynchronisé casse le build Docker

**Symptôme** : (1) `php artisan serve` hôte rend des pages blanches — tous les assets en `ERR_CONNECTION_REFUSED` alors que `public/build/` est frais. (2) `docker compose build` échoue sur `RUN npm ci` : « package.json and package-lock.json are not in sync — Missing: @emnapi/core… ».

**Cause** : (1) un fichier `public/hot` résiduel (laissé par un `composer dev`/Vite tué) pointe vers `http://0.0.0.0:5173` ; Laravel sert alors les URLs Vite dev au lieu du manifest buildé. (2) le `npm i` de réparation des bindings natifs (leçon précédente) avait laissé `package-lock.json` incomplet (entrées `@emnapi/*` manquantes) : l'hôte tournait, mais `npm ci` — strict — refusait dans l'image.

**Correction** : (1) `rm public/hot` (régénéré au prochain dev). (2) `npm install` pour resynchroniser le lock (+44 lignes `@emnapi`), puis rebuild.

**Pour la prochaine fois** : pages blanches avec assets refusés sur un serve hôte ⇒ vérifier `cat public/hot` avant tout. Après tout `npm i` correctif, tester `docker compose build` (ou `npm ci`) : le lock peut être valide pour l'hôte mais refusé par `npm ci`. Les changements front/PHP ne sont visibles sur localhost:8000 qu'après `docker compose build app queue && docker compose up -d app queue` (pas de volume code monté).

## 2026-07-03 — Outillage hôte désynchronisé : bindings npm Linux, vendor incomplet, phpunit.xml d'une autre machine

**Symptôme** : `composer ci:check` échoue en cascade sur une machine qui n'a pas servi au dernier dev : (1) ESLint plante avec « Cannot find native binding » (`unrs-resolver`), (2) PHPStan ne trouve pas `Dompdf\Dompdf` alors que le paquet est dans `composer.lock`, (3) les tests échouent en « connection refused » sur 127.0.0.1:5432.

**Cause** : `node_modules/` et `vendor/` avaient été installés depuis un conteneur Docker Linux (volume partagé) — seuls les bindings natifs **linux-arm64** étaient présents, et `vendor/` était incomplet par rapport au lock. `phpunit.xml` pointait vers un Postgres local d'une autre machine (user `computer-care`, port 5432) alors que le `docker-compose.yml` du projet expose Postgres sur l'hôte au port **5433** (user `fusy`/`secret`). La CI GitHub n'avait par ailleurs **aucun service Postgres** — `php artisan test` n'y a jamais pu passer.

**Correction** : `npm i` + `composer install` sur l'hôte (le conteneur build sa propre image, `.dockerignore` exclut `node_modules`/`vendor`/`.env` — aucune interférence). `phpunit.xml` aligné sur le compose du projet (127.0.0.1:5433, `fusy`/`secret`, base `fusy_testing` à créer via `docker exec platform-db-1 createdb -U fusy fusy_testing`). Service `postgres:16-alpine` ajouté à `.github/workflows/tests.yml` avec les mêmes credentials. `.env` local pointé sur 127.0.0.1:5433 pour les commandes artisan hôte.

**Pour la prochaine fois** : sur ce repo, tooling hôte et runtime conteneur sont indépendants ; si un binaire natif « n'existe pas », vérifier `ls node_modules/@unrs` (plateforme du binding) avant de soupçonner le code. La base de test vit dans le conteneur `platform-db-1`, port hôte 5433.

## 2026-06-25 — React Compiler interdit `useMemo` manuel et `setState` dans un effet

**Symptôme** : `npm run lint` échoue (errors, pas warnings) sur du code React pourtant valide : `react-hooks/preserve-manual-memoization` ("Existing memoization could not be preserved") sur un `useMemo`, et `react-hooks/set-state-in-effect` ("Avoid calling setState() directly within an effect") sur un `setState` appelé dans le corps d'un `useEffect`.

**Cause** : ce projet active le **React Compiler** (`babel-plugin-react-compiler` dans vite.config.ts) avec les règles ESLint associées en mode error. Le compilateur mémoïse automatiquement ; un `useMemo` manuel dont il ne peut pas prouver l'équivalence devient une erreur, et tout `setState` synchrone dans un effet est rejeté (cascade de rendus). Piège : du code React parfaitement standard ailleurs casse ici le lint.

**Correction** : (1) supprimer les `useMemo` manuels de filtrage/dérivation — calculer la valeur directement dans le corps du composant, le compilateur s'en charge (`resources/js/pages/admin/settlements.tsx`). (2) Éviter `setState` dans un `useEffect` : pour des overlays animés, rendre conditionnellement sur la prop `open` et jouer l'animation d'entrée en CSS (`@keyframes`) plutôt qu'avec un flag d'état (`resources/js/components/overlays.tsx` + `.modal.show/.drawer.show` dans `resources/css/fusy-kit.css`).

**Pour la prochaine fois** : lint qui casse sur `useMemo`/`setState`-in-effect alors que tsc passe ⇒ c'est le React Compiler, pas un vrai bug ; retirer la mémoïsation manuelle / sortir le setState de l'effet.

## 2026-06-25 — Collision de noms de variables CSS lors du portage d'un kit dans shadcn/Tailwind v4

**Symptôme** : en portant le CSS d'un design system externe (FUSY-DASH) dans l'app, certains éléments avaient des couleurs incohérentes (texte « muted » devenant une surface, ring de focus erroné) bien que les classes soient identiques à l'original.

**Cause** : le kit externe et shadcn utilisent les **mêmes noms de variables** (`--muted`, `--ring`, `--card`, `--border`) avec une **sémantique différente** : côté Fusy `--muted` = couleur de texte gris, côté shadcn `--muted` = couleur de surface ; `--ring` = ombre rgba chez Fusy vs couleur pleine chez shadcn. Réutiliser tels quels fait que les classes du kit héritent des valeurs shadcn.

**Correction** : dans le CSS du kit (`resources/css/fusy-kit.css`), référencer des tokens bruts **distincts** non collisionnés : `--card-surface`, `--line`, `--fg-muted`, `--ring-fusy`, `--sidebar-bg` (définis dans `resources/css/app.css`), au lieu de `--card`/`--border`/`--muted`/`--ring`/`--sidebar`.

**Pour la prochaine fois** : couleurs « presque bonnes » après import d'un CSS tiers dans un projet shadcn ⇒ suspecter une collision de noms de custom properties avec les tokens shadcn ; renommer les tokens du kit.

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

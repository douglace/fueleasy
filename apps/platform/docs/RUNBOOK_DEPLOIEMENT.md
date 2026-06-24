# Runbook de déploiement — Fusy Platform (VPS, déploiement manuel)

Cible : staging + production sur VPS. Déploiement manuel documenté (pas de CD automatique au MVP).

## 1. Prérequis serveur

- PHP 8.3+ avec extensions `pdo_pgsql`, `pgsql`, `mbstring`, `bcmath`, `intl`.
- PostgreSQL 14+.
- Node.js 20+ et npm (pour le build front).
- Composer 2.
- Un superviseur de process (systemd ou supervisor) pour la queue et le scheduler.

## 2. Base de données

```bash
# Créer la base et l'utilisateur applicatif
createdb fusy
createuser fusy_app --pwprompt
psql -c "GRANT ALL PRIVILEGES ON DATABASE fusy TO fusy_app;"
```

Renseigner dans `.env` : `DB_CONNECTION=pgsql`, `DB_DATABASE=fusy`, `DB_USERNAME=fusy_app`, `DB_PASSWORD=...`.

> Les contraintes financières reposent sur PostgreSQL (index partiels, triggers d'immutabilité du ledger, verrous `FOR UPDATE`). SQLite n'est pas supporté en production.

## 3. Première installation

```bash
cd apps/platform
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan migrate --force          # migrations depuis une base vide
php artisan db:seed --force          # facultatif : environnement pilote
npm ci && npm run build
php artisan config:cache route:cache view:cache
```

## 4. Mise à jour (déploiement)

```bash
cd apps/platform
php artisan down                     # mode maintenance
git pull --ff-only
composer install --no-dev --optimize-autoloader
php artisan migrate --force
npm ci && npm run build
php artisan config:cache route:cache view:cache
php artisan queue:restart
php artisan up
```

## 5. Queue & scheduler (jobs)

Les jobs critiques (expiration des sessions de paiement, reset des budgets périodiques,
génération des lots de reversement, SMS de secours) tournent via la queue et le scheduler.

- **Worker queue** (process supervisé) :
  ```bash
  php artisan queue:work --tries=3 --timeout=60
  ```
- **Scheduler** (cron, une ligne) :
  ```cron
  * * * * * cd /chemin/apps/platform && php artisan schedule:run >> /dev/null 2>&1
  ```
  Le scheduler déclenche : `ExpireStalePayments` (minute), `ResetDueDriverBudgets` (heure),
  `GenerateWeeklySettlements` (lundi 02:00).

## 6. Vérifications post-déploiement

```bash
curl -s https://<host>/up                 # health check framework
curl -s https://<host>/api/health         # {"status":"ok","app":"Fusy"}
php artisan migrate:status
php artisan about
```

## 7. Sauvegarde

```bash
# Dump quotidien recommandé (cron)
pg_dump fusy | gzip > /backups/fusy-$(date +\%F).sql.gz
```

Restauration : `gunzip -c fusy-AAAA-MM-JJ.sql.gz | psql fusy`.

## 8. Rollback

1. `php artisan down`
2. `git checkout <tag-précédent>` puis `composer install` + `npm run build`
3. Si une migration doit être annulée : `php artisan migrate:rollback --step=1 --force`
   (vérifier d'abord la réversibilité ; le trigger d'immutabilité du ledger est recréé par la migration `down`).
4. `php artisan config:cache && php artisan up`

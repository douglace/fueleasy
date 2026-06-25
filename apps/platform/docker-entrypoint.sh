#!/usr/bin/env sh
set -e

echo "[fusy] Attente de la base de données ${DB_HOST}:${DB_PORT}..."
until php -r "exit(@fsockopen(getenv('DB_HOST'), (int)getenv('DB_PORT')) ? 0 : 1);" 2>/dev/null; do
    sleep 2
done
echo "[fusy] Base de données joignable."

php artisan config:clear

echo "[fusy] Migrations..."
php artisan migrate --force

# Seed du pilote au premier démarrage (idempotent).
if [ "${FUSY_SEED:-true}" = "true" ]; then
    php artisan db:seed --force || true
fi

echo "[fusy] Démarrage du serveur sur 0.0.0.0:8000"
exec php artisan serve --host=0.0.0.0 --port=8000

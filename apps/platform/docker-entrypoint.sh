#!/usr/bin/env sh
set -e

# `php artisan serve` lit le .env et le passe au sous-process serveur, écrasant
# les variables d'environnement du conteneur. On synchronise donc le .env avec
# l'environnement Docker avant de démarrer.
sync_env() {
    key="$1"
    val="$2"
    [ -z "$val" ] && return 0
    if grep -q "^${key}=" .env; then
        # Échappe les caractères spéciaux pour sed.
        esc=$(printf '%s' "$val" | sed -e 's/[\/&|]/\\&/g')
        sed -i "s|^${key}=.*|${key}=${esc}|" .env
    else
        echo "${key}=${val}" >> .env
    fi
}

for k in APP_NAME APP_ENV APP_DEBUG APP_URL \
         DB_CONNECTION DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD \
         SESSION_DRIVER CACHE_STORE QUEUE_CONNECTION; do
    eval "v=\$$k"
    sync_env "$k" "$v"
done

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

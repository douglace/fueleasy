# Image unique PHP 8.4 + Node 20 : Wayfinder appelle `php artisan` pendant le build
# Vite, donc PHP doit être présent au moment du build des assets.
# PHP 8.4 requis : composer.lock épingle des paquets Symfony exigeant php >= 8.4.1.
FROM php:8.4-cli-bookworm

# Dépendances système + extensions PHP requises par Fusy
# (PostgreSQL, dompdf -> gd/dom/mbstring, intl, bcmath, pcntl pour la concurrence).
RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip curl ca-certificates gnupg \
        libpq-dev libzip-dev libicu-dev libonig-dev \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo_pgsql pgsql gd zip intl bcmath mbstring pcntl dom \
    && rm -rf /var/lib/apt/lists/*

# Node 20 (build front Vite/Inertia).
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Composer.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Dépendances PHP (cache de couche : copie d'abord les manifestes).
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-progress --no-scripts --no-autoloader

# Dépendances Node.
COPY package.json package-lock.json ./
RUN npm ci

# Code applicatif.
COPY . .

# .env de conteneur + clé applicative, autoload optimisé, build des assets.
RUN cp .env.example .env \
    && composer dump-autoload --optimize \
    && php artisan key:generate \
    && npm run build \
    && chmod -R ug+rw storage bootstrap/cache

EXPOSE 8000

ENTRYPOINT ["/app/docker-entrypoint.sh"]

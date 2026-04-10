FROM composer:2.8 AS vendor
WORKDIR /app

COPY . .
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

FROM php:8.4-cli-alpine
WORKDIR /app

RUN apk add --no-cache bash icu-dev libzip-dev mysql-client oniguruma-dev unzip zip \
    && docker-php-ext-install intl pdo_mysql zip

COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer
COPY --from=vendor /app /app

RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

COPY docker/entrypoint.sh /usr/local/bin/petitsuivi-backend-entrypoint
RUN chmod +x /usr/local/bin/petitsuivi-backend-entrypoint

EXPOSE 8000

ENTRYPOINT ["petitsuivi-backend-entrypoint"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

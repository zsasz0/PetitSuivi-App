#!/bin/sh
set -e

if [ ! -f .env ]; then
  cp .env.example .env
fi

if [ -n "$DB_CONNECTION" ]; then
  sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=${DB_CONNECTION}/" .env
fi

if [ -n "$DB_HOST" ]; then
  sed -i "s/^# DB_HOST=.*/DB_HOST=${DB_HOST}/; s/^DB_HOST=.*/DB_HOST=${DB_HOST}/" .env
fi

if [ -n "$DB_PORT" ]; then
  sed -i "s/^# DB_PORT=.*/DB_PORT=${DB_PORT}/; s/^DB_PORT=.*/DB_PORT=${DB_PORT}/" .env
fi

if [ -n "$DB_DATABASE" ]; then
  sed -i "s/^# DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/; s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/" .env
fi

if [ -n "$DB_USERNAME" ]; then
  sed -i "s/^# DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/; s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/" .env
fi

if [ -n "$DB_PASSWORD" ]; then
  sed -i "s/^# DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/; s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
fi

php artisan optimize:clear

if ! grep -q '^APP_KEY=base64:' .env; then
  php artisan key:generate --force
fi

php artisan migrate --force

exec "$@"

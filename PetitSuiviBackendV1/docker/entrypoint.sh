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

if [ -n "$SESSION_DRIVER" ]; then
  if grep -q '^SESSION_DRIVER=' .env; then
    sed -i "s/^SESSION_DRIVER=.*/SESSION_DRIVER=${SESSION_DRIVER}/" .env
  else
    printf '\nSESSION_DRIVER=%s\n' "$SESSION_DRIVER" >> .env
  fi
fi

if [ -n "$CACHE_STORE" ]; then
  if grep -q '^CACHE_STORE=' .env; then
    sed -i "s/^CACHE_STORE=.*/CACHE_STORE=${CACHE_STORE}/" .env
  else
    printf '\nCACHE_STORE=%s\n' "$CACHE_STORE" >> .env
  fi
fi

if [ -n "$COPILOT_API_URL" ]; then
  if grep -q '^COPILOT_API_URL=' .env; then
    sed -i "s|^COPILOT_API_URL=.*|COPILOT_API_URL=${COPILOT_API_URL}|" .env
  else
    printf '\nCOPILOT_API_URL=%s\n' "$COPILOT_API_URL" >> .env
  fi
fi

php artisan optimize:clear

if ! grep -q '^APP_KEY=base64:' .env; then
  php artisan key:generate --force
fi

php artisan migrate --force

exec "$@"

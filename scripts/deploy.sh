#!/bin/bash

set -euo pipefail

TARGET_DIR="${1:-$HOME/PetitSuivi-App}"
shift || true

SERVICES=("$@")

if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Deployment directory is not a git repository: $TARGET_DIR" >&2
    exit 1
fi

cd "$TARGET_DIR"

git fetch origin main
git checkout main
git reset --hard origin/main

if [ ${#SERVICES[@]} -eq 0 ]; then
    SERVICES=(mysql backend frontreact copilot phpmyadmin)
fi

echo "Deploying services: ${SERVICES[*]}"
docker compose up -d --build "${SERVICES[@]}"
docker compose ps

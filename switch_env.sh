#!/bin/bash

# Configuration
# ==========================================
# PRODUCTION URLs
PROD_API_URL="https://api.petitsuivi.me"
PROD_REACT_URL="https://api.petitsuivi.me/api"

# LOCAL URLs
LOCAL_API_URL="http://127.0.0.1:8000"
LOCAL_REACT_URL="http://127.0.0.1:8000/api"
LOCAL_FLUTTER_URL="http://192.168.100.14:8000" # 10.0.2.2 is used for Android emulator to reach local host
# ==========================================

ROOT_ENV_FILE=".env"
REACT_ENV_FILE="PetitSuiviAdminFrontEndV1/.env"

update_env_var() {
    local file="$1"
    local key="$2"
    local value="$3"

    touch "$file"

    if grep -q "^${key}=" "$file"; then
        sed -i "s|^${key}=.*|${key}=${value}|g" "$file"
    else
        printf '\n%s=%s\n' "$key" "$value" >> "$file"
    fi
}

ENV=$1

if [ -z "$ENV" ]; then
    echo "❌ Please specify an environment."
    echo "Usage: ./switch_env.sh [local|prod]"
    exit 1
fi

if [ "$ENV" = "local" ]; then
    echo "🔄 Switching to LOCAL environment..."
    
    # 1. Update React
    if [ -f "$REACT_ENV_FILE" ]; then
        update_env_var "$REACT_ENV_FILE" "REACT_APP_API_URL" "$LOCAL_REACT_URL"
        echo "✅ React env updated: $LOCAL_REACT_URL"
    else
        echo "⚠️  React .env not found."
    fi

    update_env_var "$ROOT_ENV_FILE" "APP_URL" "$LOCAL_API_URL"
    update_env_var "$ROOT_ENV_FILE" "FRONTEND_URL" "http://localhost:5000"
    update_env_var "$ROOT_ENV_FILE" "REACT_APP_API_URL" "$LOCAL_REACT_URL"
    
    # 2. Update Flutter
    if [ -f "PetitSuiviMobileFrontEndV1/lib/utils/api_constants.dart" ]; then
        sed -i "s|baseUrl = '.*'|baseUrl = '$LOCAL_FLUTTER_URL'|g" PetitSuiviMobileFrontEndV1/lib/utils/api_constants.dart
        echo "✅ Flutter updated: $LOCAL_FLUTTER_URL"
    else
        echo "⚠️  Flutter api_constants.dart not found."
    fi
    
    # 3. Update Laravel
    if [ -f "PetitSuiviBackendV1/.env" ]; then
        sed -i "s|^APP_URL=.*|APP_URL=$LOCAL_API_URL|g" PetitSuiviBackendV1/.env
        echo "✅ Laravel APP_URL updated: $LOCAL_API_URL"
    else
        echo "⚠️  Laravel .env not found."
    fi

    echo "🎉 Successfully switched all apps to LOCAL configuration!"

elif [ "$ENV" = "prod" ]; then
    echo "🔄 Switching to PRODUCTION environment..."
    
    # 1. Update React
    if [ -f "$REACT_ENV_FILE" ]; then
        update_env_var "$REACT_ENV_FILE" "REACT_APP_API_URL" "$PROD_REACT_URL"
        echo "✅ React env updated: $PROD_REACT_URL"
    else
        echo "⚠️  React .env not found."
    fi

    update_env_var "$ROOT_ENV_FILE" "APP_URL" "$PROD_API_URL"
    update_env_var "$ROOT_ENV_FILE" "FRONTEND_URL" "$PROD_API_URL"
    update_env_var "$ROOT_ENV_FILE" "REACT_APP_API_URL" "$PROD_REACT_URL"
    
    # 2. Update Flutter
    if [ -f "PetitSuiviMobileFrontEndV1/lib/utils/api_constants.dart" ]; then
        sed -i "s|baseUrl = '.*'|baseUrl = '$PROD_API_URL'|g" PetitSuiviMobileFrontEndV1/lib/utils/api_constants.dart
        echo "✅ Flutter updated: $PROD_API_URL"
    else
        echo "⚠️  Flutter api_constants.dart not found."
    fi
    
    # 3. Update Laravel
    if [ -f "PetitSuiviBackendV1/.env" ]; then
        sed -i "s|^APP_URL=.*|APP_URL=$PROD_API_URL|g" PetitSuiviBackendV1/.env
        echo "✅ Laravel APP_URL updated: $PROD_API_URL"
    else
        echo "⚠️  Laravel .env not found."
    fi

    echo "🎉 Successfully switched all apps to PRODUCTION configuration!"

else
    echo "❌ Invalid environment: $ENV"
    echo "Usage: ./switch_env.sh [local|prod]"
    exit 1
fi

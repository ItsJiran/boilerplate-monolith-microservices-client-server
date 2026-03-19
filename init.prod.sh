#!/usr/bin/env bash

set -euo pipefail

# Production initialization workflow.
# Mirrors init.sh structure, but uses production env + docker-compose.prod.yml.

# ----------------------------------------------------------
# Step 1: Setup the production environment

./setup.sh setup-env.sh --force --env=production

source ./.env
source ./.env.backend
source ./.env.devops

# Fallback jika SERVICE_SERVER_SLUG kosong/ketimpa oleh file env lain.
APP_SLUG_SAFE="${SERVICE_SERVER_SLUG:-}"
if [ -z "$APP_SLUG_SAFE" ]; then
	APP_SLUG_SAFE="$(printf '%s' "${SERVICE_SERVER_DOMAIN:-app}" | sed -E 's~^https?://~~; s~/.*$~~; s/\..*$//; s/[^A-Za-z0-9_-]+/-/g; s/^-+|-+$//g')"
fi
[ -z "$APP_SLUG_SAFE" ] && APP_SLUG_SAFE="app"

# ----------------------------------------------------------
# Step 2: Provision production SSL certificates (Let's Encrypt)

./run.sh run.prod.ssl.sh --domains="${SERVICE_SERVER_DOMAIN:-},${SERVICE_API_DOMAIN:-},${SERVICE_REVERB_DOMAIN:-},${SERVICE_S3_DOMAIN:-},${SERVICE_S3_CONSOLE_DOMAIN:-},${SERVICE_PMA_DOMAIN:-}" --email="${CERTBOT_EMAIL:-admin@${SERVICE_SERVER_DOMAIN:-example.com}}"

# ----------------------------------------------------------
# Step 3: Build nginx host templates for VPS

./setup.sh setup-nginx-host-template.sh --single --service=app --domain="${SERVICE_SERVER_DOMAIN:-${SERVICE_SERVER_URL:-app.example.com}}" --host-file-name="${SERVICE_SERVER_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=pma --domain="${SERVICE_PMA_DOMAIN:-${SERVICE_PMA_ABSOLUTE_URI:-pma.${SERVICE_SERVER_DOMAIN:-app.example.com}}}" --host-file-name="${SERVICE_SERVER_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=s3 --domain="${SERVICE_S3_DOMAIN:-${S3_URL:-s3.${SERVICE_SERVER_DOMAIN:-app.example.com}}}" --host-file-name="${SERVICE_SERVER_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=s3-console --domain="${SERVICE_S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${SERVICE_SERVER_DOMAIN:-app.example.com}}}" --host-file-name="${SERVICE_SERVER_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=reverb --domain="${SERVICE_REVERB_DOMAIN:-${SERVICE_REVERB_URL:-reverb.${SERVICE_SERVER_DOMAIN:-app.example.com}}}" --host-file-name="${SERVICE_SERVER_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt

# ----------------------------------------------------------
# Step 4: Build nginx LB templates for docker nginx

./setup.sh setup-nginx-template.sh --single --service=app --domain="${SERVICE_SERVER_DOMAIN:-${SERVICE_SERVER_URL:-app.example.com}}"
./setup.sh setup-nginx-template.sh --single --service=pma --domain="${SERVICE_PMA_DOMAIN:-${SERVICE_PMA_ABSOLUTE_URI:-pma.${SERVICE_SERVER_DOMAIN:-app.example.com}}}"
./setup.sh setup-nginx-template.sh --single --service=s3 --domain="${SERVICE_S3_DOMAIN:-${S3_URL:-s3.${SERVICE_SERVER_DOMAIN:-app.example.com}}}"
./setup.sh setup-nginx-template.sh --single --service=s3-console --domain="${SERVICE_S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${SERVICE_SERVER_DOMAIN:-app.example.com}}}"
./setup.sh setup-nginx-template.sh --single --service=reverb --domain="${SERVICE_REVERB_DOMAIN:-${SERVICE_REVERB_URL:-reverb.${SERVICE_SERVER_DOMAIN:-app.example.com}}}"

# ----------------------------------------------------------
# Step 5: Deploy host nginx template into /etc/nginx

./setup.sh setup-nginx-host-vps.sh --file-name="${SERVICE_SERVER_DOMAIN:-app.example.com}"

# ----------------------------------------------------------
# Step 6: Deploy production application workflow

APP_PROD_SERVICES_BOOTSTRAP="mariadb redis db-init"
APP_PROD_SERVICES_RUNTIME="app app-worker app-socket app-cron load_balancer"

./run.sh run.app.sh up --file docker-compose.prod.yml --one-by-one $APP_PROD_SERVICES_BOOTSTRAP
./run.sh run.app.sh up --file docker-compose.prod.yml --one-by-one $APP_PROD_SERVICES_RUNTIME

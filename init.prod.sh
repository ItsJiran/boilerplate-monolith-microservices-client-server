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

# Fallback jika APP_SLUG kosong/ketimpa oleh file env lain.
APP_SLUG_SAFE="${APP_SLUG:-}"
if [ -z "$APP_SLUG_SAFE" ]; then
	APP_SLUG_SAFE="$(printf '%s' "${APP_DOMAIN:-app}" | sed -E 's~^https?://~~; s~/.*$~~; s/\..*$//; s/[^A-Za-z0-9_-]+/-/g; s/^-+|-+$//g')"
fi
[ -z "$APP_SLUG_SAFE" ] && APP_SLUG_SAFE="app"

# ----------------------------------------------------------
# Step 2: Provision production SSL certificates (Let's Encrypt)

./run.sh run.prod.ssl.sh --domains="${APP_DOMAIN:-},${API_DOMAIN:-},${REVERB_DOMAIN:-},${S3_DOMAIN:-},${S3_CONSOLE_DOMAIN:-},${PMA_DOMAIN:-}" --email="${CERTBOT_EMAIL:-admin@${APP_DOMAIN:-example.com}}"

# ----------------------------------------------------------
# Step 3: Build nginx host templates for VPS

./setup.sh setup-nginx-host-template.sh --single --service=app --domain="${APP_DOMAIN:-${APP_URL:-app.example.com}}" --host-file-name="${APP_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=pma --domain="${PMA_DOMAIN:-${PMA_ABSOLUTE_URI:-pma.${APP_DOMAIN:-app.example.com}}}" --host-file-name="${APP_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=s3 --domain="${S3_DOMAIN:-${S3_URL:-s3.${APP_DOMAIN:-app.example.com}}}" --host-file-name="${APP_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=s3-console --domain="${S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${APP_DOMAIN:-app.example.com}}}" --host-file-name="${APP_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt
./setup.sh setup-nginx-host-template.sh --single --service=reverb --domain="${REVERB_DOMAIN:-${REVERB_URL:-reverb.${APP_DOMAIN:-app.example.com}}}" --host-file-name="${APP_DOMAIN:-app.example.com}" --ssl-mode=letsencrypt

# ----------------------------------------------------------
# Step 4: Build nginx LB templates for docker nginx

./setup.sh setup-nginx-template.sh --single --service=app --domain="${APP_DOMAIN:-${APP_URL:-app.example.com}}"
./setup.sh setup-nginx-template.sh --single --service=pma --domain="${PMA_DOMAIN:-${PMA_ABSOLUTE_URI:-pma.${APP_DOMAIN:-app.example.com}}}"
./setup.sh setup-nginx-template.sh --single --service=s3 --domain="${S3_DOMAIN:-${S3_URL:-s3.${APP_DOMAIN:-app.example.com}}}"
./setup.sh setup-nginx-template.sh --single --service=s3-console --domain="${S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${APP_DOMAIN:-app.example.com}}}"
./setup.sh setup-nginx-template.sh --single --service=reverb --domain="${REVERB_DOMAIN:-${REVERB_URL:-reverb.${APP_DOMAIN:-app.example.com}}}"

# ----------------------------------------------------------
# Step 5: Deploy host nginx template into /etc/nginx

./setup.sh setup-nginx-host-vps.sh --file-name="${APP_DOMAIN:-app.example.com}"

# ----------------------------------------------------------
# Step 6: Deploy production application workflow

APP_PROD_SERVICES_BOOTSTRAP="mariadb redis db-init"
APP_PROD_SERVICES_RUNTIME="app app-worker app-socket app-cron load_balancer"

./run.sh run.app.sh up --file docker-compose.prod.yml --one-by-one $APP_PROD_SERVICES_BOOTSTRAP
./run.sh run.app.sh up --file docker-compose.prod.yml --one-by-one $APP_PROD_SERVICES_RUNTIME

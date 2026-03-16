#!/usr/bin/env bash

set -euo pipefail

# This is a example of workflow deployment
# It will setup the environment and deploy the workflow
# This pattern allows you to separate the environment setup and workflow deployment, making 
# it easier to manage and maintain your workflows.

# This pattern also used in the deployment workflow, where we have a separate workflow for deploying the environment and another workflow for deploying the application. This allows us to deploy the environment once and then deploy 
# the application multiple times without having to worry about the environment setup each time.

# Of course, in production you need to manualy configure match with ur needs, but this is a 
# good starting point for understanding how to structure your workflows and separate concerns.
   
# Developed by github.com/itsjiran   

# ----------------------------------------------------------
# Step 1: Setup the environment

./setup.sh setup-env.sh --force

source ./.env
source ./.env.backend 
source ./.env.devops

# Fallback jika APP_SLUG kosong/ketimpa oleh file env lain.
APP_SLUG_SAFE="${APP_SLUG:-}"
if [ -z "$APP_SLUG_SAFE" ]; then
	APP_SLUG_SAFE="$(printf '%s' "${APP_DOMAIN:-app}" | sed -E 's~^https?://~~; s~/.*$~~; s/\..*$//; s/[^A-Za-z0-9_-]+/-/g; s/^-+|-+$//g')"
fi
[ -z "$APP_SLUG_SAFE" ] && APP_SLUG_SAFE="app"

SSL_CERT_PATH="/etc/nginx/ssl/${APP_SLUG_SAFE}.pem"
SSL_KEY_PATH="/etc/nginx/ssl/${APP_SLUG_SAFE}.key"

# ----------------------------------------------------------
# Step 2: Run the step-ca workflow

./run.sh run.step-ca.sh 

# ----------------------------------------------------------
# Step 3: Run the dns workflow to setup dns records for the application

./run.sh run.dev.ssl.sh
./run.sh run.dev.ssl.ca.sh
./run.sh run.dev.ssl.verify.sh

# ----------------------------------------------------------
# Step 4: Buat template untuk nginx-host (vps) 

./setup.sh setup-nginx-host-template.sh --single --service=app --domain="${APP_DOMAIN:-${APP_URL:-app.test}}" --ssl-cert="$SSL_CERT_PATH" --ssl-key="$SSL_KEY_PATH"
./setup.sh setup-nginx-host-template.sh --single --service=pma --domain="${PMA_DOMAIN:-${PMA_ABSOLUTE_URI:-pma.${APP_DOMAIN:-app.test}}}" --ssl-cert="$SSL_CERT_PATH" --ssl-key="$SSL_KEY_PATH"
./setup.sh setup-nginx-host-template.sh --single --service=s3 --domain="${S3_DOMAIN:-${S3_URL:-s3.${APP_DOMAIN:-app.test}}}" --ssl-cert="$SSL_CERT_PATH" --ssl-key="$SSL_KEY_PATH"
./setup.sh setup-nginx-host-template.sh --single --service=s3-console --domain="${S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${APP_DOMAIN:-app.test}}}" --ssl-cert="$SSL_CERT_PATH" --ssl-key="$SSL_KEY_PATH"
./setup.sh setup-nginx-host-template.sh --single --service=reverb --domain="${REVERB_DOMAIN:-${REVERB_URL:-reverb.${APP_DOMAIN:-app.test}}}" --ssl-cert="$SSL_CERT_PATH" --ssl-key="$SSL_KEY_PATH"
./setup.sh setup-nginx-host-template.sh --single --service=hmr --domain="${HMR_DOMAIN:-${HMR_URL:-hmr.${APP_DOMAIN:-app.test}}}" --ssl-cert="$SSL_CERT_PATH" --ssl-key="$SSL_KEY_PATH"

# ----------------------------------------------------------
# Step 5: Konfigurasi nginx untuk nginx-lb (docker) 

./setup.sh setup-nginx-template.sh --single --service=app --domain="${APP_DOMAIN:-${APP_URL:-app.test}}"
./setup.sh setup-nginx-template.sh --single --service=pma --domain="${PMA_DOMAIN:-${PMA_ABSOLUTE_URI:-pma.${APP_DOMAIN:-app.test}}}"
./setup.sh setup-nginx-template.sh --single --service=s3 --domain="${S3_DOMAIN:-${S3_URL:-s3.${APP_DOMAIN:-app.test}}}"
./setup.sh setup-nginx-template.sh --single --service=s3-console --domain="${S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${APP_DOMAIN:-app.test}}}"
./setup.sh setup-nginx-template.sh --single --service=reverb --domain="${REVERB_DOMAIN:-${REVERB_URL:-reverb.${APP_DOMAIN:-app.test}}}"
./setup.sh setup-nginx-template.sh --single --service=hmr --domain="${HMR_DOMAIN:-${HMR_URL:-hmr.${APP_DOMAIN:-app.test}}}"

# ----------------------------------------------------------
# Step 6: Setup the host template into the etc nginx and also setup to the host file (for local development)

./setup.sh setup-hosts.sh
./setup.sh setup-nginx-host-vps.sh

# ----------------------------------------------------------
# Step 7: Deploy the application workflow

APP_SERVICES_BOOTSTRAP="mariadb redis minio db-init createbuckets"
APP_SERVICES_RUNTIME="app app-worker app-socket app-cron load_balancer phpmyadmin app-hmr"

# Jalankan service satu per satu agar modular dan mudah disesuaikan per environment.
./run.sh run.app.sh up --build --one-by-one $APP_SERVICES_BOOTSTRAP
./run.sh run.app.sh up --build --one-by-one $APP_SERVICES_RUNTIME

# ----------------------------------------------------------
# Step 8: Jalanin test untuk memastikan semuanya berjalan dengan baik (opsional)

./run.sh test.sh
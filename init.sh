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

# ----------------------------------------------------------
# Step 2: Run the step-ca workflow

./run.sh run.step-ca.sh 

# ----------------------------------------------------------
# Step 3: Run the dns workflow to setup dns records for the application

./run.sh run.dev.ssl.sh --domains="${SERVICE_SERVER_DOMAIN},${SERVICE_PMA_DOMAIN},${SERVICE_S3_DOMAIN},${SERVICE_S3_CONSOLE_DOMAIN},${SERVICE_REVERB_DOMAIN},${HMR_DOMAIN}" --output-dir="/etc/nginx/ssl"
./run.sh run.dev.ssl.ca.sh
# ./run.sh run.dev.ssl.verify.sh

# ----------------------------------------------------------
# Step 4: Buat template untuk nginx-host (vps) 

./setup.sh setup-nginx-host-template.sh --single --service=app --domain="${SERVICE_SERVER_DOMAIN}" --ssl-cert="/etc/nginx/ssl/${SERVICE_SERVER_DOMAIN}.pem" --ssl-key="/etc/nginx/ssl/${SERVICE_SERVER_DOMAIN}.key"
./setup.sh setup-nginx-host-template.sh --single --service=pma --domain="${SERVICE_PMA_DOMAIN}" --ssl-cert="/etc/nginx/ssl/${SERVICE_PMA_DOMAIN}.pem" --ssl-key="/etc/nginx/ssl/${SERVICE_PMA_DOMAIN}.key"
./setup.sh setup-nginx-host-template.sh --single --service=s3 --domain="${SERVICE_S3_DOMAIN}" --ssl-cert="/etc/nginx/ssl/${SERVICE_S3_DOMAIN}.pem" --ssl-key="/etc/nginx/ssl/${SERVICE_S3_DOMAIN}.key"
./setup.sh setup-nginx-host-template.sh --single --service=s3-console --domain="${SERVICE_S3_CONSOLE_DOMAIN}" --ssl-cert="/etc/nginx/ssl/${SERVICE_S3_CONSOLE_DOMAIN}.pem" --ssl-key="/etc/nginx/ssl/${SERVICE_S3_CONSOLE_DOMAIN}.key"
./setup.sh setup-nginx-host-template.sh --single --service=reverb --domain="${SERVICE_REVERB_DOMAIN}" --ssl-cert="/etc/nginx/ssl/${SERVICE_REVERB_DOMAIN}.pem" --ssl-key="/etc/nginx/ssl/${SERVICE_REVERB_DOMAIN}.key"
./setup.sh setup-nginx-host-template.sh --single --service=hmr --domain="${HMR_DOMAIN}" --ssl-cert="/etc/nginx/ssl/${HMR_DOMAIN}.pem" --ssl-key="/etc/nginx/ssl/${HMR_DOMAIN}.key"

# ----------------------------------------------------------
# Step 5: Konfigurasi nginx untuk nginx-lb (docker) 

./setup.sh setup-nginx-template.sh --single --service=app --domain="${SERVICE_SERVER_DOMAIN}"
./setup.sh setup-nginx-template.sh --single --service=pma --domain="${SERVICE_PMA_DOMAIN}"
./setup.sh setup-nginx-template.sh --single --service=s3 --domain="${SERVICE_S3_DOMAIN}"
./setup.sh setup-nginx-template.sh --single --service=s3-console --domain="${SERVICE_S3_CONSOLE_DOMAIN}"
./setup.sh setup-nginx-template.sh --single --service=reverb --domain="${SERVICE_REVERB_DOMAIN}"
./setup.sh setup-nginx-template.sh --single --service=hmr --domain="${HMR_DOMAIN}"

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
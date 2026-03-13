#!/bin/bash

# =========================================================
# PRODUCTION SSL SETUP (LET'S ENCRYPT)
# =========================================================
# Automates the retrieval of SSL certificates using Certbot
# via Docker (Standalone Mode).
#
# Usage: 
#   ./run.prod.ssl.sh --domain example.com --email admin@example.com
# 
# Note: This script temporarily stops the 'load_balancer' service
# to allow Certbot to bind to port 80 for validation.
# =========================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Variables Defaults ---
DOMAIN=""
EMAIL=""
STAGING_FLAG="" # Set to "--test-cert" for staging/testing

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --domain|--url) DOMAIN="$2"; shift ;;
        --email) EMAIL="$2"; shift ;;
        --staging) STAGING_FLAG="--test-cert" ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# --- Load Environment Variables (Backup) ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    source "$ROOT_DIR/.env"
    set +a
fi

# Fallback to .env if arguments missing
if [ -z "$DOMAIN" ]; then
    DOMAIN="${APP_DOMAIN}"
fi
if [ -z "$EMAIL" ]; then
    EMAIL="${CERTBOT_EMAIL:-admin@${DOMAIN}}"
fi

# --- Validation ---
if [ -z "$DOMAIN" ] || [ "$DOMAIN" == "myapp.test" ]; then
    echo -e "${RED}[ERROR] Invalid Domain: '$DOMAIN'${NC}"
    echo "Please provide a valid production domain via argument or .env"
    echo "Usage: ./run.prod.ssl.sh --domain yourdomain.com --email admin@yourdomain.com"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo -e "${RED}[ERROR] Email is required for Let's Encrypt registration.${NC}"
    echo "Usage: ./run.prod.ssl.sh --domain yourdomain.com --email admin@yourdomain.com"
    exit 1
fi

echo -e "${BLUE}=========================================================${NC}"
echo -e "${BLUE}       SSL CERTIFICATE AUTO-PROVISIONING (CERTBOT)       ${NC}"
echo -e "${BLUE}=========================================================${NC}"
echo -e "Domain : ${YELLOW}$DOMAIN${NC}"
echo -e "Email  : ${YELLOW}$EMAIL${NC}"
echo -e "Mode   : ${YELLOW}Standalone (Docker)${NC}"
echo ""

# --- 1. Stop Load Balancer (Port 80 Conflict) ---
echo -e "${YELLOW}[1/3] Stopping Nginx Load Balancer to free Port 80...${NC}"
docker compose stop load_balancer

# --- 2. Run Certbot ---
echo -e "${YELLOW}[2/3] Requesting Certificate from Let's Encrypt...${NC}"
if [ -n "$STAGING_FLAG" ]; then
    echo -e "${YELLOW}(Running in STAGING mode - Invalid Certificate)${NC}"
fi

docker run --rm \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
  -p 80:80 \
  certbot/certbot certonly --standalone \
  -d "$DOMAIN" \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  $STAGING_FLAG

EXIT_CODE=$?

# --- 3. Restart Load Balancer ---
echo -e "${YELLOW}[3/3] Restarting Nginx Load Balancer...${NC}"
docker compose start load_balancer

# --- Result Check ---
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}SUCCESS! Certificate obtained for $DOMAIN${NC}"
    echo -e "Certificates should be in: /etc/letsencrypt/live/$DOMAIN/"
    echo -e "Ensure your Nginx config is updated to use these certificates."
else
    echo -e "${RED}FAILED! Certbot could not obtain certificate.${NC}"
    echo "Check the error logs above."
    # Attempt to start LB anyway so site isn't down forever
    exit 1
fi

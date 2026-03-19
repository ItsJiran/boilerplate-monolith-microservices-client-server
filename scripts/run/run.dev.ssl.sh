#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# DEVELOPMENT SSL SETUP (STEP CA)
# =========================================================
# Usage examples:
#   ./run.dev.ssl.sh --domain=app.test
#   ./run.dev.ssl.sh --domains=app.test,pma.app.test,s3.app.test --output-dir=/etc/nginx/ssl
# =========================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAINS=()
OUTPUT_DIR="/etc/nginx/ssl"
CA_URL_ARG=""

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --domain=VALUE       Domain/URL manual (boleh berulang)
  --domains=LIST       Daftar domain (comma separated)
  --output-dir=PATH    Direktori output cert/key (default: /etc/nginx/ssl)
  --ca-url=URL         Override STEP_CA_URL
  --help               Tampilkan bantuan
EOF
}

extract_host() {
  local value="$1"
  local host="$value"
  host="${host#http://}"
  host="${host#https://}"
  host="${host%%/*}"
  host="${host%%:*}"
  printf '%s\n' "$host"
}

add_domain_unique() {
  local candidate
  candidate="$(extract_host "$1")"
  [ -z "$candidate" ] && return

  local existing
  for existing in "${DOMAINS[@]}"; do
    [ "$existing" = "$candidate" ] && return
  done
  DOMAINS+=("$candidate")
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --domains=*)
      IFS=',' read -r -a domain_list <<< "${1#*=}"
      for item in "${domain_list[@]}"; do
        add_domain_unique "$item"
      done
      ;;
    --domain=*|--url=*) add_domain_unique "${1#*=}" ;;
    --domain|--url) add_domain_unique "$2"; shift ;;
    --output-dir=*) OUTPUT_DIR="${1#*=}" ;;
    --output-dir) OUTPUT_DIR="$2"; shift ;;
    --ca-url=*) CA_URL_ARG="${1#*=}" ;;
    --ca-url) CA_URL_ARG="$2"; shift ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}[ERROR] Unknown parameter: $1${NC}"
      usage
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo -e "${RED}[ERROR] File .env tidak ditemukan di $ENV_FILE${NC}" >&2
  exit 1
fi

set -a
source "$ENV_FILE"
[ -f "$ROOT_DIR/.env.backend" ] && source "$ROOT_DIR/.env.backend"
[ -f "$ROOT_DIR/.env.devops" ] && source "$ROOT_DIR/.env.devops"
set +a

if [ -z "$CA_URL_ARG" ]; then
  STEP_CA_PORT="${STEP_CA_PORT:-9000}"
  CA_URL="${STEP_CA_URL:-https://localhost:${STEP_CA_PORT}}"
else
  CA_URL="$CA_URL_ARG"
fi

STEP_CA_PROVISIONER="${STEP_CA_PROVISIONER:-admin}"
STEP_CA_PASSWORD="${STEP_CA_PASSWORD:-changeme}"
CONTAINER_NAME="${SERVICE_SERVER_SLUG:-app-boilerplate}-step-ca"
ROOT_CA_FILE="$ROOT_DIR/step-ca-public-root.pem"

if [ ${#DOMAINS[@]} -eq 0 ]; then
  add_domain_unique "${SERVICE_SERVER_DOMAIN:-${SERVICE_SERVER_URL:-app.test}}"
  add_domain_unique "${SERVICE_PMA_DOMAIN:-${SERVICE_PMA_ABSOLUTE_URI:-pma.${SERVICE_SERVER_DOMAIN:-app.test}}}"
  add_domain_unique "${SERVICE_S3_DOMAIN:-${S3_URL:-s3.${SERVICE_SERVER_DOMAIN:-app.test}}}"
  add_domain_unique "${SERVICE_S3_CONSOLE_DOMAIN:-${S3_CONSOLE_URL:-s3-console.${SERVICE_SERVER_DOMAIN:-app.test}}}"
  add_domain_unique "${SERVICE_REVERB_DOMAIN:-${SERVICE_REVERB_URL:-reverb.${SERVICE_SERVER_DOMAIN:-app.test}}}"
  add_domain_unique "${HMR_DOMAIN:-${SERVICE_HMR_URL:-hmr.${SERVICE_SERVER_DOMAIN:-app.test}}}"
fi

if [ ${#DOMAINS[@]} -eq 0 ]; then
  echo -e "${RED}[ERROR] Domain list kosong.${NC}"
  exit 1
fi

echo -e "${BLUE}=========================================================${NC}"
echo -e "${BLUE}        DEVELOPMENT SSL AUTO-PROVISIONING (STEP CA)      ${NC}"
echo -e "${BLUE}=========================================================${NC}"
echo -e "Domains    : ${YELLOW}${DOMAINS[*]}${NC}"
echo -e "Output dir : ${YELLOW}${OUTPUT_DIR}${NC}"
echo -e "CA URL     : ${YELLOW}${CA_URL}${NC}"
echo ""

if ! docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
  echo -e "${RED}[ERROR] Container '$CONTAINER_NAME' tidak berjalan.${NC}" >&2
  exit 1
fi

echo -e "${YELLOW}[1/3] Download Root CA...${NC}"
curl -s -k "${CA_URL}/roots.pem" > "$ROOT_CA_FILE"
if [[ ! -s "$ROOT_CA_FILE" ]]; then
  echo -e "${RED}[ERROR] Gagal mengunduh Root CA dari ${CA_URL}/roots.pem${NC}" >&2
  exit 1
fi

echo -e "${YELLOW}[2/3] Generate SSL per domain...${NC}"
sudo mkdir -p "$OUTPUT_DIR"

FAILED_DOMAINS=()
for DOMAIN in "${DOMAINS[@]}"; do
  echo -e "${BLUE}  -> $DOMAIN${NC}"

  SAFE_NAME="${DOMAIN// /-}"
  SAFE_NAME="${SAFE_NAME,,}"

  CSR_LOCAL="$ROOT_DIR/gen-${SAFE_NAME}.csr"
  KEY_LOCAL="$ROOT_DIR/gen-${SAFE_NAME}.key"
  CERT_LOCAL="$ROOT_DIR/gen-${SAFE_NAME}.crt"

  rm -f "$CSR_LOCAL" "$KEY_LOCAL" "$CERT_LOCAL"

  if ! step-cli certificate create "$DOMAIN" "$CSR_LOCAL" "$KEY_LOCAL" \
    --csr --insecure --no-password --force \
    --san "$DOMAIN" \
    --san "localhost" \
    --san "127.0.0.1"; then
    FAILED_DOMAINS+=("$DOMAIN")
    continue
  fi

  if ! echo "$STEP_CA_PASSWORD" | step-cli ca sign "$CSR_LOCAL" "$CERT_LOCAL" \
    --ca-url "$CA_URL" \
    --root "$ROOT_CA_FILE" \
    --provisioner "$STEP_CA_PROVISIONER" \
    --provisioner-password-file /dev/stdin \
    --force; then
    FAILED_DOMAINS+=("$DOMAIN")
    continue
  fi

  CERT_FILE="${OUTPUT_DIR%/}/${DOMAIN}.pem"
  KEY_FILE="${OUTPUT_DIR%/}/${DOMAIN}.key"

  cat "$CERT_LOCAL" "$ROOT_CA_FILE" | sudo tee "$CERT_FILE" >/dev/null
  sudo cp "$KEY_LOCAL" "$KEY_FILE"

  rm -f "$CSR_LOCAL" "$KEY_LOCAL" "$CERT_LOCAL"
done

echo -e "${YELLOW}[3/3] Cleanup...${NC}"
rm -f "$ROOT_CA_FILE"

if [ ${#FAILED_DOMAINS[@]} -eq 0 ]; then
  echo -e "${GREEN}SUCCESS! Certificates generated for: ${DOMAINS[*]}${NC}"
  echo ""
  echo "Generated files:"
  for DOMAIN in "${DOMAINS[@]}"; do
    echo "  - ${OUTPUT_DIR%/}/${DOMAIN}.pem"
    echo "  - ${OUTPUT_DIR%/}/${DOMAIN}.key"
  done
else
  echo -e "${RED}FAILED for: ${FAILED_DOMAINS[*]}${NC}"
  exit 1
fi

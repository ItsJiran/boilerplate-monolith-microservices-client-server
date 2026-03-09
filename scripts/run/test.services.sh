#!/bin/bash

# =========================================================
# TEST CONNECTIONS & HEALTHCHECKS
# =========================================================

# --- Warna ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo -e "${CYAN}=========================================================${NC}"
echo -e "${CYAN}        MENJALANKAN INTEGRATION & HEALTH TESTS           ${NC}"
echo -e "${CYAN}=========================================================${NC}"

# --- Load Environment ---
if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    source "$ROOT_DIR/.env"
    set +a
else
    echo -e "${RED}[ERROR] File .env tidak ditemukan! Pastikan sudah install.${NC}"
    exit 1
fi

APP_CONTAINER="${APP_SLUG}-server"

function print_result() {
    local status=$1
    local name=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}  ✓ [OK]    ${name}${NC}"
    else
        echo -e "${RED}  ✗ [FAIL]  ${name}${NC}"
    fi
}

echo -e "\n${YELLOW}1. Host to External Services (via Nginx/Load Balancer)${NC}"

# Test Main App
curl -s -k -o /dev/null --fail "https://${APP_DOMAIN}"
print_result $? "Aplikasi Utama (https://${APP_DOMAIN})"

# Test Reverb (It usually returns 404 for root path, but server responds)
HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" "https://reverb.${APP_DOMAIN}")
if [ "$HTTP_CODE" -eq 404 ] || [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 400 ] || [ "$HTTP_CODE" -eq 426 ]; then
    print_result 0 "Websocket Reverb (https://reverb.${APP_DOMAIN})"
else
    print_result 1 "Websocket Reverb (https://reverb.${APP_DOMAIN}) - Code: $HTTP_CODE"
fi

# Test MinIO
curl -s -k -o /dev/null --fail "https://minio.${APP_DOMAIN}/minio/health/live"
print_result $? "MinIO Console Health (https://minio.${APP_DOMAIN})"

echo -e "\n${YELLOW}2. Internal Container Connections (Dari dalam container App/PHP)${NC}"

# Cek apakah container app running
if ! docker inspect --format '{{.State.Running}}' "$APP_CONTAINER" 2>/dev/null | grep -q true; then
    echo -e "${RED}[ERROR] Container $APP_CONTAINER tidak berjalan! Lewati tes internal.${NC}"
else
    # Test Redis Ping
    docker exec "$APP_CONTAINER" ping -c 1 redis >/dev/null 2>&1
    print_result $? "Ping Redis"

    # Test MariaDB Ping
    docker exec "$APP_CONTAINER" ping -c 1 mariadb >/dev/null 2>&1
    print_result $? "Ping MariaDB"

    # Test MinIO Internal Port
    docker exec "$APP_CONTAINER" curl -s -o /dev/null --fail "http://minio:9000/minio/health/live" >/dev/null 2>&1
    print_result $? "Internal MinIO HTTP (http://minio:9000)"

    # Test Reverb Socket Inside
    docker exec "$APP_CONTAINER" curl -s -o /dev/null "http://app-socket:18080" >/dev/null 2>&1
    # Curl ke socket HTTP akan berhasil resolving walau 404, we just check if command ran
    print_result $? "Internal Reverb Port (http://app-socket:18080)"
fi

echo -e "\n${CYAN}=========================================================${NC}"
echo -e "${GREEN}Test selesai.${NC}"

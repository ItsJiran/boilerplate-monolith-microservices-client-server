#!/bin/bash

# --- 1. Load .env di Root ---
# Pastikan kita mencari file .env relatif terhadap root project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
ENV_FILE="$ROOT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "❌ Error: File .env tidak ditemukan di $ENV_FILE"
    exit 1
fi

ENV_FILE="$ROOT_DIR/.env.devops"

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "❌ Error: File .env.devops tidak ditemukan di $ENV_FILE"
    exit 1
fi

# --- KONFIGURASI ---
# Ubah domain di bawah ini sesuai keinginan Anda
APP_DOMAIN="${APP_DOMAIN}"
API_URL="${API_URL}"
S3_URL="${S3_URL}"
S3_CONSOLE_URL="${S3_CONSOLE_URL}"
GRAFANA_URL="${GRAFANA_URL}"
PHPMYADMIN_URL="${PHPMYADMIN_URL}"
IP="127.0.0.1"
HOSTS_FILE="/etc/hosts"

# --- WARNA OUTPUT ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🌐 Setup Local Domain: $APP_DOMAIN"

# 1. Cek apakah user menjalankannya sebagai Root/Sudo
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}🔑 Membutuhkan hak akses Administrator. Masukkan password jika diminta:${NC}"
    exec sudo "$0" "$@"
fi

# 2. Cek apakah domain sudah ada di /etc/hosts
if grep -q "[[:space:]]$APP_DOMAIN" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$APP_DOMAIN' sudah ada di $HOSTS_FILE."
else
    # 3. Tambahkan domain jika belum ada
    echo -e "${GREEN}[ADD]${NC} Menambahkan $APP_DOMAIN ke $HOSTS_FILE..."
    
    # Menambahkan baris baru dan entry host
    echo "" >> "$HOSTS_FILE"
    echo "$IP $APP_DOMAIN" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$APP_DOMAIN"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi

echo "🌐 Setup Local Domain: $API_URL"

# 2. Cek apakah domain sudah ada di /etc/hosts
if grep -q "[[:space:]]$API_URL" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$API_URL' sudah ada di $HOSTS_FILE."
else
    # 3. Tambahkan domain jika belum ada
    echo -e "${GREEN}[ADD]${NC} Menambahkan $API_URL ke $HOSTS_FILE..."
    
    # Menambahkan baris baru dan entry host
    echo "" >> "$HOSTS_FILE"
    echo "$IP $API_URL" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$API_URL"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi

echo "🌐 Setup Local Domain: $S3_URL"

# 2. Cek apakah domain sudah ada di /etc/hosts
if grep -q "[[:space:]]$S3_URL" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$S3_URL' sudah ada di $HOSTS_FILE."
else
    # 3. Tambahkan domain jika belum ada
    echo -e "${GREEN}[ADD]${NC} Menambahkan $S3_URL ke $HOSTS_FILE..."
    
    # Menambahkan baris baru dan entry host
    echo "" >> "$HOSTS_FILE"
    echo "$IP $S3_URL" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$S3_URL"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi

echo "🌐 Setup Local Domain: $S3_CONSOLE_URL"

# 2. Cek apakah domain sudah ada di /etc/hosts
if grep -q "[[:space:]]$S3_CONSOLE_URL" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$S3_CONSOLE_URL' sudah ada di $HOSTS_FILE."
else
    # 3. Tambahkan domain jika belum ada
    echo -e "${GREEN}[ADD]${NC} Menambahkan $S3_CONSOLE_URL ke $HOSTS_FILE..."
    
    # Menambahkan baris baru dan entry host
    echo "" >> "$HOSTS_FILE"
    echo "$IP $S3_CONSOLE_URL" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$S3_CONSOLE_URL"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi


echo "🌐 Setup Local Domain: $GRAFANA_URL"

# 2. Cek apakah domain sudah ada di /etc/hosts
if grep -q "[[:space:]]$GRAFANA_URL" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$GRAFANA_URL' sudah ada di $HOSTS_FILE."
else
    # 3. Tambahkan domain jika belum ada
    echo -e "${GREEN}[ADD]${NC} Menambahkan $GRAFANA_URL ke $HOSTS_FILE..."
    
    # Menambahkan baris baru dan entry host
    echo "" >> "$HOSTS_FILE"
    echo "$IP $GRAFANA_URL" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$GRAFANA_URL"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi


# 2. Cek apakah domain sudah ada di /etc/hosts
if grep -q "[[:space:]]$PHPMYADMIN_URL" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$PHPMYADMIN_URL' sudah ada di $HOSTS_FILE."
else
    # 3. Tambahkan domain jika belum ada
    echo -e "${GREEN}[ADD]${NC} Menambahkan $PHPMYADMIN_URL ke $HOSTS_FILE..."
    
    # Menambahkan baris baru dan entry host
    echo "" >> "$HOSTS_FILE"
    echo "$IP $PHPMYADMIN_URL" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$PHPMYADMIN_URL"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi

echo "🌐 Setup Local Domain: $HMR_URL"

if grep -q "[[:space:]]$HMR_URL" "$HOSTS_FILE"; then
    echo -e "${YELLOW}[SKIP]${NC} Domain '$HMR_URL' sudah ada di $HOSTS_FILE."
else
    echo -e "${GREEN}[ADD]${NC} Menambahkan $HMR_URL ke $HOSTS_FILE..."
    
    echo "" >> "$HOSTS_FILE"
    echo "$IP $HMR_URL" >> "$HOSTS_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Domain berhasil ditambahkan!"
        echo "👉 Sekarang Anda bisa akses: http://$HMR_URL"
    else
        echo -e "${RED}[FAIL]${NC} Gagal menulis ke $HOSTS_FILE"
    fi
fi

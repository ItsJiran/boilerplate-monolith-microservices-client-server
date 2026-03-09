#!/bin/bash

# --- Cek apakah user menjalankannya sebagai Root/Sudo ---
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[1;33m🔑 Membutuhkan hak akses Administrator. Masukkan password jika diminta:\033[0m"
    exec sudo "$0" "$@"
fi

# --- 1. Load Variable dari .env ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Load env files using safe pattern (consistent with other scripts)
set -a
[ -f "$ROOT_DIR/.env" ] && source "$ROOT_DIR/.env"
[ -f "$ROOT_DIR/.env.backend" ] && source "$ROOT_DIR/.env.backend"
[ -f "$ROOT_DIR/.env.devops" ] && source "$ROOT_DIR/.env.devops"
set +a

dump_env_var() {
    local key="$1"
    local entry
    entry="$(grep -nE "^${key}=" "$ROOT_DIR/.env" | head -n1)"

    if [ -n "$entry" ]; then
        echo "  ${entry}"
    else
        echo "  ${key} not defined in .env"
    fi
}

# Cek apakah variable penting ada
if [ -z "$APP_DOMAIN" ]; then
    echo "❌ Error: Variable APP_DOMAIN belum diisi di .env"
    exit 1
fi

echo "ℹ️  Values loaded from .env:"
dump_env_var "SSL_CERT_PATH"
dump_env_var "SSL_KEY_PATH"

# --- 2. Konfigurasi Path ---
TEMPLATE_FILE="$ROOT_DIR/infra/nginx/default.host.vps.template"
TARGET_FILE="/etc/nginx/sites-available/$APP_DOMAIN"
SYMLINK_FILE="/etc/nginx/sites-enabled/$APP_DOMAIN"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Template file tidak ditemukan di $TEMPLATE_FILE"
    exit 1
fi

echo "⚙️  Sedang men-generate config Nginx untuk: $APP_DOMAIN..."

# --- 3. Generate Config (Magic Happens Here) ---
# Kita gunakan 'sed' untuk mengganti placeholder dengan value dari .env
# Outputnya langsung ditulis ke /etc/nginx/...
sudo cp "$TEMPLATE_FILE" temp_nginx.conf

escape_replacement() {
    printf '%s\n' "$1" | sed -e 's/[&/|]/\\&/g'
}

apply_replace() {
    local placeholder="$1"
    local value
    value="$(escape_replacement "$2")"
    sudo sed -i "s|{{${placeholder}}}|$value|g" temp_nginx.conf
}

apply_replace "APP_DOMAIN" "$APP_DOMAIN"
apply_replace "API_URL" "$API_URL"
apply_replace "S3_URL" "$S3_URL"
apply_replace "S3_CONSOLE_URL" "$S3_CONSOLE_URL"
apply_replace "PHPMYADMIN_URL" "$PHPMYADMIN_URL"
apply_replace "GRAFANA_URL" "$GRAFANA_URL"
apply_replace "GRAFANA_PORT" "$GRAFANA_PORT"
apply_replace "LOAD_BALANCER_PORT" "$LOAD_BALANCER_PORT"
apply_replace "LOAD_BALANCER_HMR_PORT" "$LOAD_BALANCER_HMR_PORT"
apply_replace "SSL_CERT_PATH" "$SSL_CERT_PATH"
apply_replace "SSL_KEY_PATH" "$SSL_KEY_PATH"
apply_replace "REVERB_URL" "$REVERB_URL"
apply_replace "HMR_URL" "$HMR_URL"

# Pindahkan file yang sudah jadi ke target
sudo mv temp_nginx.conf "$TARGET_FILE"

# Permissions
sudo chmod 755 "$TARGET_FILE"
sudo chown ${USER}:${USER} "$TARGET_FILE"

echo "📋 Config berhasil dibuat di: $TARGET_FILE"

# --- 4. Symlink & Restart ---
if [ ! -f "$SYMLINK_FILE" ]; then
    echo "🔗 Membuat Symlink..."
    sudo ln -s "$TARGET_FILE" "$SYMLINK_FILE"
    sudo chmod 755 $TARGET_FILE
    sudo chown ${USER}:${USER} "$TARGET_FILE"
fi

# Ensure 
sudo restorecon -Rv /etc/nginx/ 2>/dev/null || true

echo "tesss config..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Config Valid! Reloading Nginx..."
    sudo systemctl reload nginx
    echo "🎉 Selesai! Website https://$APP_DOMAIN siap diakses."
else
    echo "❌ Config Nginx Error. Cek file config manual."
fi

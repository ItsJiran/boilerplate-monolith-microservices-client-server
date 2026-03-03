#!/usr/bin/env bash
set -euo pipefail

# --- Setup path & env ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ File .env tidak ditemukan di $ENV_FILE" >&2
  exit 1
fi

set -a; . "$ENV_FILE"; set +a

if [[ -z "${APP_URL:-}" ]]; then
  echo '❌ APP_URL harus ada di .env' >&2
  exit 1
fi

# --- Konfigurasi Step CA ---
STEP_CA_PORT="${STEP_CA_PORT:-9000}"
STEP_CA_PROVISIONER="${STEP_CA_PROVISIONER:-admin}"
STEP_CA_PASSWORD="${STEP_CA_PASSWORD:-changeme}"
CONTAINER_NAME="${APP_SLUG:-app-boilerplate}-step-ca"
CA_URL="${STEP_CA_URL:-https://localhost:${STEP_CA_PORT}}"

# --- Penamaan file ---
SAFE_APP_NAME="${APP_NAME:-$APP_URL}"
SAFE_APP_NAME="${SAFE_APP_NAME// /-}"
SAFE_APP_NAME="${SAFE_APP_NAME,,}"

CSR_LOCAL="$ROOT_DIR/gen-${SAFE_APP_NAME}.csr"
KEY_LOCAL="$ROOT_DIR/gen-${SAFE_APP_NAME}-key.pem"
CERT_LOCAL="$ROOT_DIR/gen-${SAFE_APP_NAME}.crt"
ROOT_CA_FILE="$ROOT_DIR/step-ca-public-root.pem"

echo "=========================================================="
echo "          MEMBUAT SSL CERTIFICATE SECARA LOKAL            "
echo "=========================================================="

# 1. Pastikan container CA menyala
if ! docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
  echo "❌ Container '$CONTAINER_NAME' tidak berjalan. Silahkan nyalakan Step CA." >&2
  exit 1
fi

# ==========================================================
# Pastikan tidak ada file lama yang terkunci oleh root
# hal ini terjadi jika script sebelumnya dijalankan via sudo
# ==========================================================
for file in "$KEY_LOCAL" "$CSR_LOCAL" "$CERT_LOCAL" "$ROOT_CA_FILE"; do
    if [ -f "$file" ] && [ ! -w "$file" ]; then
        echo "⚠️  Menghapus file lama yang terkunci oleh root: $file"
        sudo rm -f "$file"
    fi
done

echo ""
echo "🔐 1. Mengunduh Public Root CA dari Step CA..."
# Download root public key (step-ca-public-root.pem)
curl -s -k "${CA_URL}/roots.pem" > "$ROOT_CA_FILE"

if [[ ! -s "$ROOT_CA_FILE" ]]; then
  echo "❌ Gagal mengunduh Root CA dari ${CA_URL}/roots.pem" >&2
  exit 1
fi

echo ""
echo "🔐 2. Membuat Server CSR & Private Key lokal (gen-${SAFE_APP_NAME})..."
# Kumpulkan semua URL dari .env sebagai SAN
SANS=()
for VAR in API_URL REVERB_URL S3_URL S3_CONSOLE_URL; do
  VAL="${!VAR:-}"
  if [[ -n "$VAL" ]]; then
    SANS+=("--san" "$VAL")
  fi
done
SANS+=("--san" "*.$APP_URL")
SANS+=("--san" "localhost")
SANS+=("--san" "127.0.0.1")

step-cli certificate create "$APP_URL" "$CSR_LOCAL" "$KEY_LOCAL" \
  --csr --insecure --no-password --force "${SANS[@]}"

echo ""
echo "🔐 3. Signing Server CSR via HTTP ke Step CA..."
echo "$STEP_CA_PASSWORD" | step-cli ca sign "$CSR_LOCAL" "$CERT_LOCAL" \
  --ca-url "$CA_URL" --root "$ROOT_CA_FILE" \
  --provisioner "$STEP_CA_PROVISIONER" \
  --provisioner-password-file /dev/stdin --force

# --- Mengkonfigurasi Nginx SSL ---
SSL_DIR="/etc/nginx/ssl"
CERT_FILE="$SSL_DIR/${SAFE_APP_NAME}.pem"
KEY_FILE="$SSL_DIR/${SAFE_APP_NAME}-key.pem"

echo ""
echo "🔐 4. Mengkonfigurasi Nginx SSL (Membutuhkan akses Sudo)..."
sudo mkdir -p "$SSL_DIR"
sudo cp "$CERT_LOCAL" "$CERT_FILE"
sudo cp "$KEY_LOCAL" "$KEY_FILE"
sudo chown nginx:nginx "$CERT_FILE" "$KEY_FILE" || true
sudo chmod 640 "$CERT_FILE" "$KEY_FILE"

# --- Update .env ---
update_env_var() {
  local key="$1" value="$2"
  if grep -qE "^${key}=" "$ENV_FILE"; then
    sudo sed -i -E "s#^${key}=.*#${key}=${value}#" "$ENV_FILE"
  else
    echo "${key}=${value}" | sudo tee -a "$ENV_FILE" >/dev/null
  fi
}

update_env_var "SSL_CERT_PATH" "$CERT_FILE"
update_env_var "SSL_KEY_PATH" "$KEY_FILE"
update_env_var "NODE_EXTRA_CA_CERTS" "$ROOT_CA_FILE"

echo ""
echo "🔐 7. Menyalin file sertifikat ke direktori build kontainer (app-server & app-clients)..."
for BUILD_CTX_DIR in "$ROOT_DIR/app-server" "$ROOT_DIR/app-clients"; do
  if [[ -d "$BUILD_CTX_DIR" ]]; then
    cp "$ROOT_CA_FILE" "$BUILD_CTX_DIR/step-ca-public-root.pem"
    cp "$CERT_LOCAL" "$BUILD_CTX_DIR/gen-${SAFE_APP_NAME}.crt"
    echo "✅ Disalin ke: $BUILD_CTX_DIR/"
  fi
done

echo ""
echo "✅ BERHASIL! Script Selesai Dijalankan."
echo "   - Root Public CA  : $ROOT_CA_FILE"
echo "   - Server Cert     : $CERT_LOCAL"
echo "   - Nginx Cert      : $CERT_FILE"

#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# run.dev.ssl.ca.sh
# Download Root CA dari container Step CA dan install ke:
#   - Root project (gen-*.pem)
#   - System trust store (update-ca-certificates / update-ca-trust)
#   - Chrome / Chromium (NSS DB di ~/.pki/nssdb)
#   - Firefox (semua profile yang ditemukan)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "File .env tidak ditemukan di $ENV_FILE" >&2
  exit 1
fi

set -a; . "$ENV_FILE"; set +a

# --- Konfigurasi ---
CONTAINER_NAME="${APP_SLUG:-app-boilerplate}-step-ca"
CA_NAME="${STEP_CA_NAME:-App Boilerplate CA}"

SAFE_APP_NAME="${APP_NAME:-${APP_URL:-app}}"
SAFE_APP_NAME="${SAFE_APP_NAME// /-}"
SAFE_APP_NAME="${SAFE_APP_NAME,,}"

# Root CA disimpan di root project
ROOT_CA_LOCAL="$ROOT_DIR/gen-${SAFE_APP_NAME}-rootCA.pem"

# =============================================================================
# 1. Cek container Step CA berjalan
# =============================================================================
if ! docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
  echo "❌ Container '$CONTAINER_NAME' tidak berjalan. Jalankan Step CA terlebih dahulu." >&2
  exit 1
fi

# =============================================================================
# 2. Download Root CA dari container
# =============================================================================
echo "📥 Mengunduh Root CA dari container '$CONTAINER_NAME'..."
docker exec "$CONTAINER_NAME" cat /home/step/certs/root_ca.crt > "$ROOT_CA_LOCAL"
echo "✅ Root CA tersimpan ke: $ROOT_CA_LOCAL"

# =============================================================================
# 3. Install ke System Trust Store (butuh sudo)
# =============================================================================
echo ""
echo "🔧 Menginstall Root CA ke system trust store..."

if command update-ca-certificates -v &>/dev/null; then
  # Debian / Ubuntu
  sudo cp "$ROOT_CA_LOCAL" /usr/local/share/ca-certificates/${APP_SLUG:-app-boilerplate}-step-ca.pem
  sudo cp "$ROOT_CA_LOCAL" /etc/ssl/certs/${APP_SLUG:-app-boilerplate}-step-ca.pem
  sudo update-ca-certificates
  echo "✅ System trust store (Debian/Ubuntu) diperbarui."
elif command update-ca-trust -v &>/dev/null; then
  # RHEL / Fedora / Arch
  sudo cp "$ROOT_CA_LOCAL" /etc/pki/ca-trust/source/anchors/${APP_SLUG:-app-boilerplate}-step-ca.pem
  sudo update-ca-trust extract
  echo "✅ System trust store (RHEL/Fedora/Arch) diperbarui."
else
  echo "⚠️  Tidak ditemukan update-ca-certificates atau update-ca-trust."
  echo "   Install secara manual: salin $ROOT_CA_LOCAL ke direktori CA sistem."
fi

# =============================================================================
# 4. Install ke Chrome / Chromium via NSS DB
# =============================================================================
echo ""
echo "🔧 Menginstall Root CA ke Chrome/Chromium (NSS DB)..."

if command -v certutil &>/dev/null; then
  NSS_DB="$HOME/.pki/nssdb"
  if [[ ! -d "$NSS_DB" ]]; then
    echo "   Membuat NSS DB baru di $NSS_DB..."
    mkdir -p "$NSS_DB"
    certutil -N --empty-password -d "sql:$NSS_DB"
  fi

  # Hapus dulu jika sudah ada (hindari duplikasi)
  certutil -D -n "$CA_NAME" -d "sql:$NSS_DB" 2>/dev/null || true
  certutil -A -n "$CA_NAME" -t "CT,," -i "$ROOT_CA_LOCAL" -d "sql:$NSS_DB"
  echo "✅ Root CA diinstall ke Chrome/Chromium NSS DB: $NSS_DB"
else
  echo "⚠️  certutil tidak ditemukan. Lewati instalasi Chrome/Chromium."
  echo "   Install dengan: sudo apt install libnss3-tools"
fi

# =============================================================================
# 5. Install ke semua profil Firefox
# =============================================================================
echo ""
echo "🔧 Menginstall Root CA ke Firefox profiles..."

if command -v certutil &>/dev/null; then
  FIREFOX_PROFILE_DIRS=(
    "$HOME/.mozilla/firefox"
    "$HOME/snap/firefox/common/.mozilla/firefox"
  )

  FOUND_PROFILE=false
  for BASE_DIR in "${FIREFOX_PROFILE_DIRS[@]}"; do
    if [[ ! -d "$BASE_DIR" ]]; then
      continue
    fi

    while IFS= read -r -d '' PROFILE_DIR; do
      if [[ -f "$PROFILE_DIR/cert9.db" || -f "$PROFILE_DIR/cert8.db" ]]; then
        certutil -D -n "$CA_NAME" -d "sql:$PROFILE_DIR" 2>/dev/null || true
        certutil -A -n "$CA_NAME" -t "CT,," -i "$ROOT_CA_LOCAL" -d "sql:$PROFILE_DIR" \
          && echo "✅ Diinstall ke Firefox profile: $(basename "$PROFILE_DIR")" \
          || echo "⚠️  Gagal install ke: $PROFILE_DIR"
        FOUND_PROFILE=true
      fi
    done < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  done

  if [[ "$FOUND_PROFILE" == false ]]; then
    echo "   Tidak ditemukan profil Firefox yang aktif."
  fi
else
  echo "⚠️  certutil tidak ditemukan. Lewati instalasi Firefox."
fi

# =============================================================================
# Selesai
# =============================================================================
# =============================================================================
# 6. Copy rootCA ke build context app-server & app-clients (untuk Docker build)
# =============================================================================
echo ""
echo "📋 Menyalin Root CA ke direktori build context Docker..."

DEV_CA_FILENAME="dev-rootCA.pem"

for BUILD_CTX_DIR in "$ROOT_DIR/app-server" "$ROOT_DIR/app-clients"; do
  if [[ -d "$BUILD_CTX_DIR" ]]; then
    cp "$ROOT_CA_LOCAL" "$BUILD_CTX_DIR/$DEV_CA_FILENAME"
    echo "✅ Disalin ke: $BUILD_CTX_DIR/$DEV_CA_FILENAME"
  fi
done

# =============================================================================
# Selesai
# =============================================================================
echo ""
echo "✅ Selesai!"
echo "📍 Root CA lokal  : $ROOT_CA_LOCAL"
echo "📍 Docker contexts: app-server/$DEV_CA_FILENAME, app-clients/$DEV_CA_FILENAME"
echo "⚠️  Restart browser agar perubahan berlaku."

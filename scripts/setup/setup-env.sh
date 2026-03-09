#!/bin/bash

# --- Definisi Warna (Agar output cantik) ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🛠️  Memulai Setup Environment Variables..."
echo "----------------------------------------"

# --- Cek Flag Override ---
OVERRIDE=0
if [[ "${1:-}" == "--force" ]]; then
    OVERRIDE=1
fi

# --- Fungsi Reusable untuk Copy File ---
copy_env() {
    SRC=$1
    DEST=$2

    # 1. Cek apakah file tujuan sudah ada dan tidak di-override?
    if [ -f "$DEST" ] && [ "$OVERRIDE" -eq 0 ]; then
        echo -e "${YELLOW}[SKIP]${NC} $DEST sudah ada. Tidak ditimpa."
    
    # 2. Cek apakah file contoh (example) ada?
    elif [ -f "$SRC" ]; then
        if [ -f "$DEST" ] && [ "$OVERRIDE" -eq 1 ]; then
             echo -e "${YELLOW}[OVERRIDE]${NC} Menimpa $DEST dengan $SRC..."
        fi
        cp "$SRC" "$DEST"
        echo -e "${GREEN}[OK]${NC}   Berhasil membuat $DEST (dari $SRC)"
    
    # 2. Cek apakah file contoh (example) ada?
    elif [ -f "$SRC" ]; then
        cp "$SRC" "$DEST"
        echo -e "${GREEN}[OK]${NC}   Berhasil membuat $DEST (dari $SRC)"
    
    # 3. Error jika file contoh tidak ditemukan
    else
        echo -e "${RED}[ERROR]${NC} File sumber $SRC tidak ditemukan!"
    fi
}

# --- EKSEKUSI ---

# 1. Setup .env Utama
copy_env ".env.example" ".env"
copy_env ".env.example.backend" ".env.backend"
copy_env ".env.example.devops" ".env.devops"

# 3. Setup .env Frontend (Opsional: sesuaikan path jika ada di dalam folder)
# copy_env "frontend/.env.example" "frontend/.env"

echo "----------------------------------------"
echo -e "✅ Setup selesai!"
echo -e "👉 Silakan edit file ${YELLOW}.env${NC} dan ${YELLOW}.env.backend${NC} sesuai kebutuhan."
echo -e "👉 Lalu jalankan: ${GREEN}./dev.sh${NC} (atau docker compose up)"
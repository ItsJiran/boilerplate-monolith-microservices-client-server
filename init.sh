#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =========================================================
# BANNER
# =========================================================
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║        APP BOILERPLATE - INITIALIZATION MANAGER        ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# =========================================================
# HELPER FUNCTIONS
# =========================================================
wait_for_container() {
    local container_name=$1
    local max_attempts=30
    local attempt=1

    echo -ne "${BLUE}Menunggu container ${container_name} siap...${NC}"
    while ! docker inspect --format '{{.State.Running}}' "$container_name" 2>/dev/null | grep -q true; do
        if [ $attempt -ge $max_attempts ]; then
            echo -e "\n${RED}✗ Timeout menunggu $container_name.${NC}"
            return 1
        fi
        echo -ne "."
        sleep 1
        ((attempt++))
    done
    echo -e " ${GREEN}Siap!${NC}"
    return 0
}

configure_env() {
    local key=$1
    local value=$2
    local file=$3

    if [ -f "$file" ]; then
        if grep -qE "^${key}=" "$file"; then
            sed -i -E "s#^${key}=.*#${key}=\"${value}\"#" "$file"
        else
            echo "${key}=\"${value}\"" >> "$file"
        fi
    fi
}

# =========================================================
# FLOW: DEVELOPMENT INSTALLATION
# =========================================================
flow_dev_install() {
    echo -e "\n${YELLOW}=== 🛠️  FRESH INSTALLATION (DEVELOPMENT) ===${NC}"
    
    # 1. Pre-flight Check
    SETUP_ENV_FLAGS=""
    if [ -f ".env" ]; then
        echo -ne "${RED}⚠️  File .env sudah ada! Apakah Anda ingin MELANJUTKAN dan MEMUTAKHIRKAN file yang ada? (y/N): ${NC}"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Dibatalkan."
            return
        fi
        SETUP_ENV_FLAGS="--force"
    fi

    # 2. Interactive Input
    read -p "Masukkan Nama Project (contoh: Citra App): " input_app_name
    read -p "Masukkan Slug Project (contoh: citra-app): " input_app_slug
    read -p "Masukkan Local Domain (contoh: citra.test): " input_app_domain

    APP_NAME=${input_app_name:-"My App"}
    APP_SLUG=${input_app_slug:-"myapp"}
    APP_DOMAIN=${input_app_domain:-"myapp.test"}

    echo -e "\n${BLUE}[1/5] Menyiapkan Environment Files...${NC}"
    ./scripts/setup/setup-env.sh $SETUP_ENV_FLAGS
    
    echo -e "${BLUE}>> Mengonfigurasi .env dengan data input Anda...${NC}"
    # Replace variables in .env
    configure_env "APP_NAME" "$APP_NAME" ".env"
    configure_env "APP_SLUG" "$APP_SLUG" ".env"
    configure_env "APP_NETWORK" "$APP_SLUG" ".env"
    configure_env "APP_DOMAIN" "$APP_DOMAIN" ".env"
    configure_env "APP_URL" "https://${APP_DOMAIN}" ".env"
    configure_env "API_URL" "api.${APP_DOMAIN}" ".env"
    configure_env "REVERB_URL" "reverb.${APP_DOMAIN}" ".env"
    configure_env "HMR_URL" "hmr.${APP_DOMAIN}" ".env"
    configure_env "VITE_HMR_URL" "hmr.${APP_DOMAIN}" ".env"
    configure_env "S3_URL" "s3.${APP_DOMAIN}" ".env"
    configure_env "S3_CONSOLE_URL" "minio.${APP_DOMAIN}" ".env"
    configure_env "VITE_REVERB_HOST" "reverb.${APP_DOMAIN}" ".env"
    
    # Generate random DB Password if empty or default
    DB_PASS=$(openssl rand -hex 12)
    configure_env "DB_PASSWORD" "$DB_PASS" ".env.backend"
    
    echo -e "\n${BLUE}>> Memuat (Load) Environment Variables...${NC}"
    set -a
    [ -f ".env" ] && source .env
    [ -f ".env.backend" ] && source .env.backend
    [ -f ".env.devops" ] && source .env.devops
    set +a
    
    echo -e "\n${BLUE}[2/5] Menyiapkan Konfigurasi Host & Monitoring...${NC}"
    ./scripts/setup/setup-monitoring-config.sh
    ./scripts/setup/setup-hosts.sh

    echo -e "\n${BLUE}[3/5] Setup SSL Lokal (Step CA)...${NC}"
    docker compose -f infra/docker-compose.step-ca.yml up -d
    wait_for_container "step-ca"
    sleep 3 # Extra buffer time for CA API to be ready
    ./scripts/run/run.dev.ssl.sh
    
    echo -e "\n${BLUE}[4/5] Memulai Layanan Docker (App Stack & Monitoring)...${NC}"
    docker compose up -d
    docker compose -f infra/docker-compose.devops.yml up -d
    docker compose -f infra/docker-compose.devops.exporter.yml up -d
    
    # Nginx Host Setup usually comes after services are known, but can be done anytime.
    ./scripts/setup/setup-nginx-host.sh

    echo -e "\n${BLUE}[5/5] Setup Laravel (Key, Migrate, Seed)...${NC}"
    wait_for_container "${APP_SLUG}-server"
    sleep 5 # Wait for PHP FPM / Octane to be ready
    
    docker compose exec server php artisan key:generate
    docker compose exec server php artisan storage:link
    
    echo -ne "${YELLOW}Apakah Anda ingin menjalankan DB Migration & Seed data dummy? (Y/n): ${NC}"
    read -r run_migrate
    if [[ ! "$run_migrate" =~ ^[Nn]$ ]]; then
        docker compose exec server php artisan migrate --seed
    fi

    # Finishing
    echo -e "\n${GREEN}🎉 FRESH INSTALLATION (DEVELOPMENT) SELESAI!${NC}"
    echo "========================================================"
    echo -e "Aplikasi Utama    : ${CYAN}https://${APP_DOMAIN}${NC}"
    echo -e "MinIO Console     : ${CYAN}https://minio.${APP_DOMAIN}${NC}"
    echo -e "Grafana Monitoring: ${CYAN}https://monitoring.${APP_DOMAIN}${NC}"
    echo -e "phpMyAdmin        : ${CYAN}https://pma.${APP_DOMAIN}${NC}"
    echo "========================================================"
    echo "Ketik ./run.sh untuk manajemen contaniner sehari-hari."
    echo "Ketik ./scripts/run/test.services.sh untuk mencoba kesehatan koneksi."
    echo ""
    read -p "Tekan Enter untuk kembali ke Menu Utama..."
}

# =========================================================
# FLOW: PRODUCTION INSTALLATION (STUB)
# =========================================================
flow_prod_install() {
    echo -e "\n${RED}=== 🚀 FRESH INSTALLATION (PRODUCTION) ===${NC}"
    echo "Flow Production biasanya membutuhkan Domain Publik Valid untuk Let's Encrypt."
    echo "Perbedaan dengan Dev adalah:"
    echo "1. Tidak menjalankan Step CA (Local SSL)."
    echo "2. Menggunakan certbot/letsencrypt untuk binding Nginx."
    echo "3. APP_DEBUG di-set false, environment di-set production."
    echo "4. Menggunakan Docker Image statis murni tanpa mounting local volume untuk kode."
    echo ""
    echo -e "${YELLOW}>> Modul ini sedang dalam pengembangan / bisa disesuaikan lebih lanjut!${NC}"
    read -p "Tekan Enter untuk kembali..."
}

status_check() {
    echo -e "\n${CYAN}=== 📊 STATUS LAYANAN RUNNING ===${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -v "step-ca"
    echo ""
    read -p "Tekan Enter untuk kembali..."
}

# =========================================================
# MAIN MENU LOOP
# =========================================================
while true; do
    show_banner
    echo -e "Pilih Menu Inisialisasi:"
    echo -e "  ${GREEN}[1] 🛠️  Fresh Install (Development)${NC} -> Setup Local SSL, Env, Docker Up, Migrate"
    echo -e "  ${RED}[2] 🚀 Fresh Install (Production) ${NC} -> Produksi dengan Let's Encrypt (WIP)"
    echo -e "  ${YELLOW}[3] 🧪 Jalankan Integration Tests ${NC} -> Cek koneksi antar layanan"
    echo -e "  ${BLUE}[4] 📊 Lihat Status Port & Service${NC} -> Tampilkan port mapping saat ini"
    echo -e "  [0] Keluar"
    echo -e "-------------------------------------------------------"
    read -p "Pilih menu [0-4]: " menu_choice

    case $menu_choice in
        1) flow_dev_install ;;
        2) flow_prod_install ;;
        3) 
            if [ -f "./scripts/run/test.services.sh" ]; then
                ./scripts/run/test.services.sh
                read -p "Tekan Enter untuk kembali..."
            else
                echo -e "${RED}Script test.services.sh tidak ditemukan!${NC}"
                sleep 2
            fi
            ;;
        4) status_check ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid.${NC}"; sleep 1 ;;
    esac
done

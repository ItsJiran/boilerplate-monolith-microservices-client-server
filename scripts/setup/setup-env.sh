#!/bin/bash

# --- Definisi Warna (Agar output cantik) ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🛠️  Memulai Setup Environment Variables..."
echo "----------------------------------------"

# --- Cek Flag Override & Environment ---
OVERRIDE=0
TARGET_ENV="local"

for arg in "$@"; do
    case $arg in
        --force)
            OVERRIDE=1
            shift
            ;;
        --env=*)
            TARGET_ENV="${arg#*=}"
            shift
            ;;
    esac
done

export TARGET_ENV

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

# --- 2. Sync dengan config.json (Local Environment) ---
echo "🔄 Syncing .env files with config.json ($TARGET_ENV)..."

if [ -f "config.json" ]; then
    php -r '
        $configFile = "config.json";
        $targetEnv = getenv("TARGET_ENV") ?: "local";
        // Daftar file env yang ingin di-update
        $envFiles = [".env", ".env.backend", ".env.devops"];

        if (!file_exists($configFile)) {
            exit(0);
        }

        $jsonContent = file_get_contents($configFile);
        $config = json_decode($jsonContent, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            echo "Error parsing config.json: " . json_last_error_msg() . "\n";
            exit(1);
        }

        $envConfig = $config[$targetEnv] ?? [];
        if (empty($envConfig)) {
            echo "No config found for environment: $targetEnv in config.json\n";
            exit(0);
        }

        foreach ($envFiles as $envFile) {
            if (!file_exists($envFile)) {
                continue;
            }
            
            echo "   Processing $envFile...\n";
            
            $envContent = file_get_contents($envFile);
            $lines = explode("\n", $envContent);
            $newLines = [];
            $keysUpdated = [];

            // 1. Update existing keys in .env
            foreach ($lines as $line) {
                $trimmed = trim($line);
                
                // Skip comments and empty lines
                if (empty($trimmed) || str_starts_with($trimmed, "#")) {
                    $newLines[] = $line;
                    continue;
                }

                // Split by first "="
                $parts = explode("=", $line, 2);
                $key = trim($parts[0]);
                
                // Check if key exists in env config
                if (array_key_exists($key, $envConfig)) {
                    $val = $envConfig[$key];
                    
                    // Convert booleans to string representation for .env
                    if (is_bool($val)) {
                        $val = $val ? "true" : "false";
                    }
                    
                    // Construct new line
                    $newLines[] = "$key=$val";
                    
                    // Mark key as updated
                    $keysUpdated[$key] = true;
                } else {
                    // Keep original line
                    $newLines[] = $line;
                }
            }

            // Write back to .env
            file_put_contents($envFile, implode("\n", $newLines));
            echo "     -> Updated " . count($keysUpdated) . " keys.\n";
        }
    '
    echo -e "${GREEN}[OK]${NC}   Passed: All .env files synced with config.json"
else
    echo -e "${YELLOW}[SKIP]${NC} config.json not found."
fi

echo "----------------------------------------"
echo -e "✅ Setup selesai!"
echo -e "👉 Silakan edit file ${YELLOW}.env${NC} dan ${YELLOW}.env.backend${NC} sesuai kebutuhan."
echo -e "👉 Lalu jalankan: ${GREEN}./dev.sh${NC} (atau docker compose up)"

# 3. Setup .env Frontend (Opsional: sesuaikan path jika ada di dalam folder)
# copy_env "frontend/.env.example" "frontend/.env"
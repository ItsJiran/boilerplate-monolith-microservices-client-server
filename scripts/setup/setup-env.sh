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
SET_OVERRIDES=()

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
        --set=*)
            SET_OVERRIDES+=("${arg#*=}")
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
    
    # 3. Error jika file contoh tidak ditemukan
    else
        echo -e "${RED}[ERROR]${NC} File sumber $SRC tidak ditemukan!"
    fi
}

upsert_env_key() {
    FILE=$1
    KEY=$2
    VALUE=$3

    ESCAPED_VALUE=$(printf '%s' "$VALUE" | sed 's/[&|]/\\&/g')

    if grep -qE "^${KEY}=" "$FILE"; then
        sed -i "s|^${KEY}=.*|${KEY}=${ESCAPED_VALUE}|g" "$FILE"
    else
        echo "${KEY}=${VALUE}" >> "$FILE"
    fi
}

normalize_domain_value() {
    local value="$1"
    value="${value#http://}"
    value="${value#https://}"
    value="${value#//}"
    value="${value%/}"
    echo "$value"
}

normalize_scheme_value() {
    local value="$1"
    value="${value#http://}"
    value="${value#https://}"
    value="${value#//}"
    value="${value%://}"
    value="${value%/}"
    [ -z "$value" ] && value="https"
    echo "$value"
}

apply_argument_overrides() {
    if [ ${#SET_OVERRIDES[@]} -eq 0 ]; then
        return
    fi

    echo "🔧 Applying argument overrides..."

    if [ ! -f ".env" ]; then
        echo -e "${RED}[ERROR]${NC} .env not found, cannot apply overrides safely."
        return
    fi

    # Update key di file yang memang sudah punya key tersebut.
    # Jika key belum ada di semua file env, tambahkan hanya ke .env.
    for pair in "${SET_OVERRIDES[@]}"; do
        KEY="${pair%%=*}"
        VALUE="${pair#*=}"

        if [ -z "$KEY" ] || [ "$KEY" = "$pair" ]; then
            echo -e "${YELLOW}[WARN]${NC} Invalid --set format: $pair (use --set=KEY=VALUE)"
            continue
        fi

        if [[ "$KEY" == *_DOMAIN ]] || [[ "$KEY" == *_EXTRA_HOST ]]; then
            VALUE="$(normalize_domain_value "$VALUE")"
        elif [ "$KEY" = "APP_SCHEME" ]; then
            VALUE="$(normalize_scheme_value "$VALUE")"
        fi

        KEY_FOUND=0
        for envFile in .env .env.backend .env.devops; do
            if [ ! -f "$envFile" ]; then
                continue
            fi

            if grep -qE "^${KEY}=" "$envFile"; then
                upsert_env_key "$envFile" "$KEY" "$VALUE"
                KEY_FOUND=1
            fi
        done

        if [ "$KEY_FOUND" -eq 0 ]; then
            upsert_env_key ".env" "$KEY" "$VALUE"
            echo "   -> $KEY ditambahkan ke .env (tidak ditemukan di file env lain)."
        fi
    done

    for envFile in .env .env.backend .env.devops; do
        if [ ! -f "$envFile" ]; then
            continue
        fi

        echo "   Processing $envFile..."
        UPDATED=0
        for pair in "${SET_OVERRIDES[@]}"; do
            KEY="${pair%%=*}"
            if [ -n "$KEY" ] && [ "$KEY" != "$pair" ] && grep -qE "^${KEY}=" "$envFile"; then
                UPDATED=$((UPDATED + 1))
            fi
        done

        APP_SCHEME_VALUE=$(grep -E '^APP_SCHEME=' "$envFile" | head -n 1 | cut -d'=' -f2-)
        APP_SCHEME_VALUE="$(normalize_scheme_value "$APP_SCHEME_VALUE")"

        DERIVATIONS=(
            "APP_DOMAIN:APP_URL"
            "API_DOMAIN:API_URL"
            "REVERB_DOMAIN:REVERB_URL"
            "S3_DOMAIN:S3_URL"
            "S3_CONSOLE_DOMAIN:S3_CONSOLE_URL"
            "PMA_DOMAIN:PMA_ABSOLUTE_URI"
        )

        for derivation in "${DERIVATIONS[@]}"; do
            DOMAIN_KEY="${derivation%%:*}"
            URL_KEY="${derivation##*:}"

            DOMAIN_OVERRIDE=0
            URL_OVERRIDE=0

            for pair in "${SET_OVERRIDES[@]}"; do
                OVERRIDE_KEY="${pair%%=*}"
                if [ "$OVERRIDE_KEY" = "$DOMAIN_KEY" ] || [ "$OVERRIDE_KEY" = "APP_SCHEME" ]; then
                    DOMAIN_OVERRIDE=1
                fi
                if [ "$OVERRIDE_KEY" = "$URL_KEY" ]; then
                    URL_OVERRIDE=1
                fi
            done

            if [ "$DOMAIN_OVERRIDE" -eq 1 ] && [ "$URL_OVERRIDE" -eq 0 ]; then
                DOMAIN_VALUE=$(grep -E "^${DOMAIN_KEY}=" "$envFile" | head -n 1 | cut -d'=' -f2-)
                DOMAIN_VALUE="$(normalize_domain_value "$DOMAIN_VALUE")"

                if grep -qE "^${URL_KEY}=" "$envFile"; then
                    upsert_env_key "$envFile" "$URL_KEY" "${APP_SCHEME_VALUE}://${DOMAIN_VALUE}"
                elif [ "$envFile" = ".env" ]; then
                    upsert_env_key "$envFile" "$URL_KEY" "${APP_SCHEME_VALUE}://${DOMAIN_VALUE}"
                fi
            fi
        done

        echo "     -> Applied $UPDATED override(s)."
    done
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

        $normalizeDomain = static function ($value) {
            if (!is_string($value)) {
                return $value;
            }

            $value = preg_replace("#^https?://#i", "", $value);
            $value = ltrim($value, "/");
            $value = rtrim($value, "/");
            return $value;
        };

        $normalizeScheme = static function ($value) {
            if (!is_string($value) || $value === "") {
                return "https";
            }

            $value = preg_replace("#^https?://#i", "", $value);
            $value = trim($value, "/:");
            return $value === "" ? "https" : $value;
        };

        // Normalize all domain-like keys from config to host-only form.
        foreach ($envConfig as $cfgKey => $cfgVal) {
            if (!is_string($cfgKey)) {
                continue;
            }

            if ($cfgKey === "APP_SCHEME") {
                $envConfig[$cfgKey] = $normalizeScheme($cfgVal);
                continue;
            }

            if (str_ends_with($cfgKey, "_DOMAIN") || str_ends_with($cfgKey, "_EXTRA_HOST")) {
                $envConfig[$cfgKey] = $normalizeDomain($cfgVal);
            }
        }

        // --- Auto-Derive URLs from Domains ---
        $appScheme = $envConfig["APP_SCHEME"] ?? "https";
        
        $domainMap = [
            "APP_DOMAIN"        => "APP_URL",
            "API_DOMAIN"        => "API_URL",
            "REVERB_DOMAIN"     => "REVERB_URL",
            "S3_DOMAIN"         => "S3_URL",
            "S3_CONSOLE_DOMAIN" => "S3_CONSOLE_URL",
            "PMA_DOMAIN"        => "PMA_ABSOLUTE_URI",
        ];

        foreach ($domainMap as $domainKey => $urlKey) {
            if (isset($envConfig[$domainKey]) && !isset($envConfig[$urlKey])) {
                $domain = $normalizeDomain($envConfig[$domainKey]);
                $envConfig[$urlKey] = "{$appScheme}://{$domain}";
            }
        }
        // -------------------------------------

        // Only sync real env keys (uppercase and underscore), skip metadata like __comment.
        $isSyncableKey = static function ($key) {
            return is_string($key) && preg_match("/^[A-Z][A-Z0-9_]*$/", $key) === 1;
        };

        foreach ($envFiles as $envFile) {
            if (!file_exists($envFile)) {
                continue;
            }
            
            echo "   Processing $envFile...\n";
            
            $envContent = file_get_contents($envFile);
            $lines = explode("\n", $envContent);
            $newLines = [];
            $keysUpdated = [];
            $existingKeys = [];

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
                $existingKeys[$key] = true;

                if (!$isSyncableKey($key)) {
                    $newLines[] = $line;
                    continue;
                }
                
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

            // 2. Append missing keys from config.json
            //    Only append ke .env agar key baru tidak tersebar ke semua env file.
            $keysAppended = 0;
            if ($envFile === ".env") {
                foreach ($envConfig as $cfgKey => $cfgVal) {
                    if (!$isSyncableKey($cfgKey) || isset($existingKeys[$cfgKey])) {
                        continue;
                    }

                    if (is_bool($cfgVal)) {
                        $cfgVal = $cfgVal ? "true" : "false";
                    }

                    $newLines[] = "$cfgKey=$cfgVal";
                    $keysAppended++;
                }
            }

            // Write back to .env
            file_put_contents($envFile, implode("\n", $newLines));
            echo "     -> Updated " . count($keysUpdated) . " keys, appended " . $keysAppended . " keys.\n";
        }
    '
    echo -e "${GREEN}[OK]${NC}   Passed: All .env files synced with config.json"
else
    echo -e "${YELLOW}[SKIP]${NC} config.json not found."
fi

# --- 3. Optional override dari argument --set=KEY=VALUE ---
apply_argument_overrides

echo "----------------------------------------"
echo -e "✅ Setup selesai!"
echo -e "👉 Silakan edit file ${YELLOW}.env${NC} dan ${YELLOW}.env.backend${NC} sesuai kebutuhan."
echo -e "👉 Lalu jalankan: ${GREEN}./dev.sh${NC} (atau docker compose up)"

# 3. Setup .env Frontend (Opsional: sesuaikan path jika ada di dalam folder)
# copy_env "frontend/.env.example" "frontend/.env"
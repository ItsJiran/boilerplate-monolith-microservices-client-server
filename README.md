# App Boilerplate — Monolith Full-Stack Architecture

> Laravel 12 + React (Inertia.js) + Docker — Production-grade boilerplate with integrated monitoring, SSL, real-time capabilities, and S3-compatible object storage.
>
> Developed by **Akterma Technology [AT]** — ItsJiran | `2026`

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Laravel 12, PHP 8.2+, FrankenPHP, Laravel Octane |
| Frontend | React (JSX), Inertia.js, Vite, Tailwind CSS |
| Real-time | Laravel Reverb (WebSocket) |
| Auth | Laravel Sanctum + Breeze |
| Database | MariaDB |
| Cache / Queue | Redis |
| Object Storage | MinIO (S3-compatible) |
| Monitoring | Grafana + Prometheus + Loki + Promtail |
| Load Balancer | Nginx |
| Container Mgmt | Portainer |
| SSL Dev | Step CA (self-signed) |
| SSL Production | Let's Encrypt |

---

## Directory Structure

```
.
├── app/                         # Laravel Application
│   ├── app/
│   │   ├── Http/Controllers/    # Controllers (thin layer)
│   │   ├── Services/            # Business logic per domain
│   │   │   ├── AccessControl/
│   │   │   ├── Admin/
│   │   │   ├── Dashboard/
│   │   │   ├── Notification/
│   │   │   ├── Profile/
│   │   │   └── Shared/
│   │   ├── DTO/                 # Data Transfer Objects
│   │   ├── Models/              # Eloquent Models
│   │   ├── Events/ + Listeners/ # Event-driven
│   │   ├── Jobs/                # Async queue jobs
│   │   └── Rules/               # Custom validation rules
│   └── resources/js/
│       ├── Pages/               # Inertia page components
│       ├── Components/ui/       # Atomic Design (atoms/molecules/organisms)
│       ├── Hooks/               # Custom React hooks
│       ├── Stores/              # Zustand state stores
│       └── Lib/                 # utils, enums, authRoles, routes
├── infra/                       # Docker Infrastructure
│   ├── docker-compose.devops.yml
│   ├── docker-compose.devops.exporter.yml
│   ├── docker-compose.portainer.yml
│   └── docker-compose.step-ca.yml
├── scripts/
│   ├── setup/                   # One-time setup scripts
│   └── run/                     # Operational run scripts
├── docker-compose.yml           # Main app stack (Development)
├── docker-compose.prod.yml      # Main app stack (Production Artifacts)
├── setup.sh                     # Entry point: setup scripts
└── run.sh                       # Entry point: run scripts
```

---

## Environment Files

The project uses 3 separate env files located in the project root:

| File | Content |
|---|---|
| `.env` | Main Config: APP_URL, ports, APP_SLUG, SSL, network |
| `.env.backend` | Laravel Config: DB, Redis, Mail, S3, Sanctum, Reverb |
| `.env.devops` | Monitoring Config: Grafana, Prometheus, Loki, resource limits |

Copy from example files:
```bash
cp .env.example .env
cp .env.example.backend .env.backend
cp .env.example.devops .env.devops
```
Or run `./setup.sh` → select `setup-env.sh`.

> See `infra/ENV-FILE-CONFIG.md` for a complete explanation of each variable.

---

## Docker Stack

### Main App (`docker-compose.yml`)

| Service | Function |
|---|---|
| `mariadb` | Main Database |
| `db-init` | One-shot service: creates database & user on first run |
| `redis` | Cache + Queue broker |
| `server` | Laravel app (FrankenPHP/Octane) |
| `server-worker` | `php artisan queue:work` — async job processor |
| `server-socket` | `php artisan reverb:start` — WebSocket server |
| `server-cron` | `php artisan schedule:work` — cron scheduler |
| `load_balancer` | Nginx, exposes ports to host |
| `minio` | S3-compatible object storage |
| `createbuckets` | One-shot: auto-create MinIO buckets |
| `phpmyadmin` | DB management UI |

### Monitoring (`infra/docker-compose.devops.yml`)

| Service | Function |
|---|---|
| `grafana` | Visualization Dashboard |
| `prometheus` | Metrics Collector |
| `loki` | Log Aggregation System |
| `promtail` | Log Shipping Agent |
| `node_exporter` | Host Metrics Exporter |

---

## Deployment Strategy (Enterprise Grade)

This project uses a **Continuous Delivery (CD)** strategy with a strict **"No Source Code on Server"** rule.

1.  **Build (CI)**: GitHub Actions builds a Docker Image from the code (`app/`), and pushes it to GitHub Container Registry (GHCR).
2.  **Deploy (CD)**: Developer runs a manual workflow ("Trigger Deploy") which instructs the server to pull the image from GHCR.
3.  **Server State**: The server does **NOT** contain the `app/` source code. It only holds configuration files (`.env`, `docker-compose.prod.yml`) and scripts. The application runs using the immutable image.

See [DEPLOYMENT.md](DEPLOYMENT.md) for full details.

| `prometheus` | Metrics collector |
| `loki` | Log aggregator |

### Exporters (`infra/docker-compose.devops.exporter.yml`)

| Service | Fungsi |
|---|---|
| `node_exporter` | Metrics CPU/RAM/disk host |
| `redis-exporter` | Metrics Redis |
| `mariadb-exporter` | Metrics MariaDB |
| `nginx-exporter` | Metrics Nginx |
| `cadvisor` | Metrics per container Docker |
| `promtail` | Log shipper → Loki |

### Tools

| Compose File | Service | Fungsi |
|---|---|---|
| `docker-compose.portainer.yml` | `portainer` | UI manajemen container |
| `docker-compose.step-ca.yml` | `step-ca` | CA server untuk SSL development |

---

## Workflow: Setup Pertama Kali

Jalankan semua langkah berikut secara berurutan.

### 1. Setup Environment

```bash
./setup.sh
# Pilih: setup-env.sh
# Atau pilih A untuk run semua setup scripts sekaligus
```

Akan meng-copy `.env.example` → `.env`, `.env.backend`, `.env.devops`.
Edit ketiga file tersebut sesuai kebutuhan (minimal: `APP_URL`, `DB_PASSWORD`, `APP_SLUG`).

### 2. Setup Local Hosts

```bash
sudo ./setup.sh
# Pilih: setup-hosts.sh
```

Menambahkan semua domain dari `.env` (`APP_URL`, `API_URL`, `S3_URL`, `S3_CONSOLE_URL`, `GRAFANA_URL`, `PHPMYADMIN_URL`) ke `/etc/hosts` → `127.0.0.1`.

### 3. Setup Nginx Virtual Host di Host Machine

```bash
sudo ./setup.sh
# Pilih: setup-nginx-host.sh
```

Membuat konfigurasi Nginx di `/etc/nginx/sites-available/` dan symlink ke `sites-enabled/` agar domain lokal diroute ke port load balancer.

### 4. Setup SSL Development

```bash
# 4a. Jalankan Step CA server
./run.sh
# Pilih: run.step-ca.sh

# 4b. Generate SSL certificate untuk domain
./run.sh
# Pilih: run.dev.ssl.sh

# 4c. Install Root CA ke system dan browser
./run.sh
# Pilih: run.dev.ssl.ca.sh
# → Install ke: system trust store (apt/rpm/arch), Chrome/Chromium (NSS DB), semua Firefox profile

# 4d. Verifikasi SSL
./run.sh
# Pilih: run.dev.ssl.verify.sh
```

> **Production**: Gunakan Let's Encrypt. Lihat `infra/LETSENCRYPT.md`.

### 5. Setup Monitoring Config

```bash
./setup.sh
# Pilih: setup-monitoring-config.sh
```

Generate `prometheus.yml` dan `promtail.config.yml` dari variabel `.env.devops`.
Gunakan `infra/monitoring/prometheus.example.yml` sebagai referensi endpoint exporter.

---

## Workflow: Menjalankan Aplikasi

### Jalankan Main App

```bash
./run.sh
# Pilih: run.app.sh
```

**Penting untuk Development (Vite/Node):**
Jika Anda menjalankan `npm install` atau `npm run dev` langsung di Host atau dalam container dan mendapat *permission error*, pastikan ownership/permissions folder sudah sesuai dengan user web server (`www-data`):
```bash
sudo chown -R www-data:www-data app/
sudo chmod -R 775 app/
# atau jika di komputer lokal Linux, Anda bisa menambahkan user Anda ke grup www-data:
# sudo usermod -aG www-data $USER
```

Script interaktif dengan **checkbox selector** — pilih service yang ingin dioperasikan. Operasi yang tersedia:

| Operasi | Keterangan |
|---|---|
| `up` | Jalankan service |
| `restart` | Restart service |
| `rebuild` | Rebuild image lalu up |
| `force-recreate` | Force recreate container |
| `reload` | Zero-downtime config reload (Nginx: `nginx -s reload`) |
| `down` | Matikan dan hapus container |
| `stop` | Stop tanpa remove container |
| `volume` | Manage / recreate volume |

### Jalankan Monitoring

```bash
# Step 1: Exporters
./run.sh
# Pilih: run.devops.exporter.sh
# Pilih service: node_exporter, redis-exporter, mariadb-exporter, nginx-exporter, cadvisor, promtail

# Step 2: Monitoring stack
./run.sh
# Pilih: run.devops.sh
# Pilih service: prometheus, loki, grafana
```

### Jalankan Portainer

```bash
./run.sh
# Pilih: run.portainer.sh
```

---

## Akses Layanan

> Sesuaikan dengan nilai `APP_URL` dan domain lain di `.env`.

| Layanan | URL Default |
|---|---|
| Aplikasi | `https://myapp.test` |
| MinIO Console | `https://s3-console.myapp.test` |
| phpMyAdmin | `https://pma.myapp.test` |
| Grafana | `https://monitoring.myapp.test` |
| Portainer | `https://localhost:9443` |
| Step CA | `https://localhost:9000` |
| Prometheus | `http://localhost:9090` |

---

## Fitur Aplikasi Bawaan

| Fitur | Keterangan |
|---|---|
| Auth Lengkap | Login, Register, Password Reset, Email Verify, Confirm Password |
| RBAC | Role `superadmin`, `admin`, `user` via middleware `EnsureRole` |
| Real-time Notifications | WebSocket via Reverb, mark read / read-all |
| File Upload | Upload ke MinIO/S3 via `useS3Upload` hook |
| Profile Management | Edit info, ganti password, hapus akun |
| Dashboard | Charts, stat cards, filter periode |
| Excel Export | via Maatwebsite Excel |
| Queue Worker | Async job processing via Redis |
| Scheduler | Cron tasks via `schedule:work` |

---

## SSL Certificate Strategy

| Env | Metode | Script |
|---|---|---|
| Development | Step CA (self-signed, trusted lokal) | `run.step-ca.sh` → `run.dev.ssl.sh` → `run.dev.ssl.ca.sh` |
| Production | Let's Encrypt (trusted publik) | Lihat `infra/LETSENCRYPT.md` |

File SSL yang di-generate disimpan di root project dengan prefix `gen-`:
- `gen-<app-name>.crt` — certificate
- `gen-<app-name>.key` — private key
- `gen-<app-name>.csr` — certificate signing request
- `gen-<app-name>-rootCA.pem` — root CA certificate

---

## Quick Commands Cheatsheet

```bash
# === SETUP (jalankan sekali) ===
./setup.sh                           # Menu interaktif setup scripts
# pilih A untuk run semua sekaligus

# === RUN APP ===
./run.sh                             # Menu interaktif run scripts

# === DOCKER MANUAL ===
docker compose up -d                 # Jalankan semua service main app
docker compose down                  # Matikan semua service
docker compose logs -f server        # Lihat log Laravel

# === MONITORING MANUAL ===
docker compose -f infra/docker-compose.devops.yml up -d
docker compose -f infra/docker-compose.devops.exporter.yml up -d

# === STEP CA MANUAL ===
docker compose -f infra/docker-compose.step-ca.yml up -d
docker logs -f step-ca

# === ARTISAN ===
docker exec -it ${APP_SLUG}-server php artisan migrate
docker exec -it ${APP_SLUG}-server php artisan db:seed
docker exec -it ${APP_SLUG}-server php artisan queue:restart
docker exec -it ${APP_SLUG}-server php artisan tinker
```

---

## Notes

- Semua service memiliki resource limit CPU/Memory via `deploy.resources.limits` — set di `.env.devops`
- Log rotation: max `5MB × 2 file` per container (json-file driver)
- Docker network bersifat `external` — dibuat manual atau otomatis oleh run script
- Variable `APP_SLUG` digunakan sebagai prefix nama container, volume, dan network
- Setup scripts bisa dijalankan individual atau semua sekaligus (`./setup.sh` → `A`)
- Run scripts memiliki checkbox interaktif: pilih service spesifik tanpa edit compose file

---

> Further reading:
> - `infra/STEP-CA.md` — SSL development dengan Step CA
> - `infra/LETSENCRYPT.md` — SSL production dengan Let's Encrypt
> - `infra/ENV-FILE-CONFIG.md` — Panduan lengkap environment variables
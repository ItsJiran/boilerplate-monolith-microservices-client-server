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

### Exporters (`infra/docker-compose.devops.exporter.yml`)

| Service | Function |
|---|---|
| `node_exporter` | Host CPU/RAM/Disk metrics |
| `redis-exporter` | Redis metrics |
| `mariadb-exporter` | MariaDB metrics |
| `nginx-exporter` | Nginx metrics |
| `cadvisor` | Docker container metrics |
| `promtail` | Log shipper → Loki |

### Tools

| Compose File | Service | Function |
|---|---|---|
| `docker-compose.portainer.yml` | `portainer` | Container Management UI |
| `docker-compose.step-ca.yml` | `step-ca` | CA server for SSL development |

---

## Workflow: First-Time Setup

Run the following steps in sequence.

### 1. Setup Environment

```bash
./setup.sh
# Select: setup-env.sh
# Or select 'A' to run all setup scripts at once
```

This will copy `.env.example` → `.env`, `.env.backend`, `.env.devops`.
Edit these files as needed (minimally: `APP_URL`, `DB_PASSWORD`, `APP_SLUG`).

### 2. Setup Local Hosts

```bash
sudo ./setup.sh
# Select: setup-hosts.sh
```

Adds all domains from `.env` (`APP_URL`, `API_URL`, `S3_URL`, `S3_CONSOLE_URL`, `GRAFANA_URL`, `PHPMYADMIN_URL`) to `/etc/hosts` → `127.0.0.1`.

### 3. Setup Nginx Virtual Host on Host Machine

```bash
sudo ./setup.sh
# Select: setup-nginx-host.sh
```

Creates Nginx configuration in `/etc/nginx/sites-available/` and symlinks it to `/etc/nginx/sites-enabled/` so local domains are routed to the load balancer port.

### 4. Setup SSL Development

```bash
# 4a. Run Step CA server
./run.sh
# Select: run.step-ca.sh

# 4b. Generate SSL certificate for domains
./run.sh
# Select: run.dev.ssl.sh

# 4c. Install Root CA to system and browsers
./run.sh
# Select: run.dev.ssl.ca.sh
# → Installs to: system trust store (apt/rpm/arch), Chrome/Chromium (NSS DB), all Firefox profiles

# 4d. Verify SSL
./run.sh
# Select: run.dev.ssl.verify.sh
```

> **Production**: Use Let's Encrypt. See `infra/LETSENCRYPT.md`.

### 5. Setup Monitoring Config

```bash
./setup.sh
# Select: setup-monitoring-config.sh
```

Generates `prometheus.yml` and `promtail.config.yml` from `.env.devops` variables.
Uses `infra/monitoring/prometheus.example.yml` as a reference for exporter endpoints.

---

## Workflow: Running the Application

### Run Main App

```bash
./run.sh
# Select: run.app.sh
```

**Important for Development (Vite/Node):**
If you run `npm install` or `npm run dev` directly on the Host or inside a container and encounter a *permission error*, ensure folder ownership/permissions match the web server user (`www-data`):
```bash
sudo chown -R www-data:www-data app/
sudo chmod -R 775 app/
# or if on local Linux, add your user to www-data group:
# sudo usermod -aG www-data $USER
```

Interactive script with **checkbox selector** — select specific services to operate. Available operations:

| Operation | Description |
|---|---|
| `up` | Start service |
| `restart` | Restart service |
| `rebuild` | Rebuild image then up |
| `force-recreate` | Force recreate container |
| `reload` | Zero-downtime config reload (Nginx: `nginx -s reload`) |
| `down` | Stop and remove container |
| `stop` | Stop without removing container |
| `volume` | Manage / recreate volume |

### Run Monitoring

```bash
# Step 1: Exporters
./run.sh
# Select: run.devops.exporter.sh
# Select services: node_exporter, redis-exporter, mariadb-exporter, nginx-exporter, cadvisor, promtail

# Step 2: Monitoring stack
./run.sh
# Select: run.devops.sh
# Select services: prometheus, loki, grafana
```

### Run Portainer

```bash
./run.sh
# Select: run.portainer.sh
```

---

## Access Services

> Adjust according to `APP_URL` and other domains in `.env`.

| Service | Default URL |
|---|---|
| Application | `https://myapp.test` |
| MinIO Console | `https://s3-console.myapp.test` |
| phpMyAdmin | `https://pma.myapp.test` |
| Grafana | `https://monitoring.myapp.test` |
| Portainer | `https://localhost:9443` |
| Step CA | `https://localhost:9000` |
| Prometheus | `http://localhost:9090` |

---

## Built-in App Features

| Feature | Description |
|---|---|
| Full Auth | Login, Register, Password Reset, Email Verify, Confirm Password |
| RBAC | Roles `superadmin`, `admin`, `user` via middleware `EnsureRole` |
| Real-time Notifications | WebSocket via Reverb, mark read / read-all |
| File Upload | Upload to MinIO/S3 via `useS3Upload` hook |
| Profile Management | Edit info, change password, delete account |
| Dashboard | Charts, stat cards, period filtering |
| Excel Export | via Maatwebsite Excel |
| Queue Worker | Async job processing via Redis |
| Scheduler | Cron tasks via `schedule:work` |

---

## SSL Certificate Strategy

| Env | Method | Script |
|---|---|---|
| Development | Step CA (self-signed, locally trusted) | `run.step-ca.sh` → `run.dev.ssl.sh` → `run.dev.ssl.ca.sh` |
| Production | Let's Encrypt (publicly trusted) | See `infra/LETSENCRYPT.md` |

Generated SSL files are stored in the project root with prefix `gen-`:
- `gen-<app-name>.crt` — certificate
- `gen-<app-name>.key` — private key
- `gen-<app-name>.csr` — certificate signing request
- `gen-<app-name>-rootCA.pem` — root CA certificate

---

## Quick Commands Cheatsheet

```bash
# === SETUP (run once) ===
./setup.sh                           # Interactive setup scripts menu
# select A to run all at once

# === RUN APP ===
./run.sh                             # Interactive run scripts menu

# === DOCKER MANUAL ===
docker compose up -d                 # Start all main app services
docker compose down                  # Stop all services
docker compose logs -f server        # View Laravel logs

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

- All services have CPU/Memory resource limits via `deploy.resources.limits` — set in `.env.devops`
- Log rotation: max `5MB × 2 file` per container (json-file driver)
- Docker networks are `external` — created manually or automatically by run scripts
- The `APP_SLUG` variable is used as a prefix for container names, volumes, and networks
- Setup scripts can be run individually or all at once (`./setup.sh` → `A`)
- Run scripts feature interactive checkboxes: select specific services without editing compose files

---

> Further reading:
> - `infra/STEP-CA.md` — SSL development with Step CA
> - `infra/LETSENCRYPT.md` — SSL production with Let's Encrypt
> - `infra/ENV-FILE-CONFIG.md` — Complete guide to environment variables
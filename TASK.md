# Migration to Microservices Architecture (Client-Server Split)

**Objective**: Refactor the current Monolith structure into a Microservices-ready architecture by separating Server (Backend) and Client (Frontend) applications into distinct directories.

**Target Structure**:
```
.
├── clients/
│   └── app-client/          # Turbo Monorepo (React / React Native)
├── servers/
│   └── app-server/          # Current Laravel Application
├── infra/                   # Shared Infrastructure (Docker, Nginx, Monitoring)
├── scripts/                 # Shared Scripts
└── ...
```

---

## Phase 1: Structure Reorganization & Cleanup
- [ ] **Create Root Directories**
    - Create `servers/` directory.
    - Create `clients/` directory.
- [ ] **Migrate Backend**
    - Move existing `app/` directory to `servers/app-server/`.
    - Ensure all hidden files (like `.env.example`, etc.) are moved correctly.
- [ ] **Initialize Frontend Structure**
    - Create `clients/app-client/` directory.
    - *Note:* The user intends to use a Turbo Monorepo (React/React Native) here.
    - (Future Task) Initialize Turbo Repo in `clients/app-client/`.

## Phase 2: Configuration & Docker Updates
- [ ] **Update Docker Compose (`docker-compose.yml`)**
    - Update build context for `server`, `server-worker`, `server-socket`, `server-cron` from `app/` to `servers/app-server/`.
    - Update volume mappings: `./app:/var/www/html` to `./servers/app-server:/var/www/html`.
- [ ] **Update Production Docker Compose (`docker-compose.prod.yml`)**
    - Update build context (if applicable) or verify image paths remains valid.
    - Update any bind mounts used for configuration.
- [ ] **Update Infrastructure Config (`infra/`)**
    - Check `infra/nginx/` templates if they reference local paths.
    - Check any monitoring configs referencing source code paths.

## Phase 3: Script Updates
- [ ] **Update Root Scripts**
    - `setup.sh`: Update paths to `.env` files and helper scripts.
    - `run.sh`: Update paths to docker compose files and service contexts.
- [ ] **Update Helper Scripts (`scripts/`)**
    - Update `scripts/setup/setup-env.sh` to look for `.env.example` in `servers/app-server/` or root (decide on env strategy).
    - Update `scripts/run/*.sh` to use correct working directories if they `cd` into `app/`.
    - Update `scripts/deploy/*.sh` to build from `servers/app-server/`.

## Phase 4: Environment Management
- [ ] **Environment Variables Strategy**
    - Decide if `.env` files stay in root or move to `servers/app-server/`.
    - *Recommendation*: Keep `.env` (infrastructure) in root, and specific backend envs in `servers/app-server/.env` OR symlink them.
    - For now, ensure scripts copy root `.env` to `servers/app-server/.env` during setup.

## Phase 5: Client-Side Initialization (Placeholder)
- [ ] **Setup `clients/app-client`**
    - Initialize basic Turbo Repo structure.
    - Create `apps/web` (React) and `apps/mobile` (React Native) placeholders.
    - Configure `pnpm-workspace.yaml`.

## Phase 6: Documentation
- [ ] **Update `README.md`**
    - Document the new directory structure.
    - Update "Getting Started" commands.
    - Explain the separaion of concerns (Servers vs Clients).

# CI/CD Configuration & Secrets Guide

This document explains the Environment Variables and Secrets configuration required for the GitHub Actions workflows (`test`, `build-push`, `deploy-prod`) to run smoothly.

---

## 1. Registry & Image Configuration (Automatic)

This part *DOES NOT NEED* manual configuration. The `build-push.yml` and `deploy-prod.yml` workflows are already configured to use **GitHub Container Registry (GHCR)** automatically.

*   **Registry Host**: `ghcr.io`
*   **Image Name**: `ghcr.io/<username>/<repository>` (Automatically retrieved from your repo name)
*   **Authentication**: Uses the built-in `GITHUB_TOKEN` from GitHub Actions.

> **Note**: If you want to use Docker Hub, you need to modify the `.github/workflows/build-push.yml` workflow file and add the `DOCKERHUB_USERNAME` & `DOCKERHUB_TOKEN` secrets.

---

## 2. Repository Secrets (Required)

Sensitive values such as passwords, IP Addresses, and Keys **MUST** be stored in GitHub Secrets, not inside the code files.

### How to Add a Secret
1.  Open your GitHub Repository.
2.  Go to **Settings** > **Secrets and variables** > **Actions**.
3.  Click **New repository secret**.
4.  Enter the `Name` and `Secret` according to the table below.

### List of Required Secrets

#### A. Production Server Connection
Used by the `deploy-prod.yml` workflow to SSH into the VPS.

| Secret Name | Example Value | Description |
| :--- | :--- | :--- |
| `PROD_SERVER_IP` | `103.150.10.12` | Public IP Address of the Production VPS |
| `PROD_SERVER_USER` | `root` or `ubuntu` | SSH Username (User must have Docker access) |
| `PROD_SERVER_PORT` | `22` | SSH Port (Default 22) |
| `PROD_SSH_KEY` | `-----BEGIN OPENSSH...` | SSH Private Key (Content of your local `.pem` or `id_rsa` file) |

#### B. Application Configuration (Laravel)
Injected into the `.env` file on the server during deployment.

| Secret Name | Example Value | Description |
| :--- | :--- | :--- |
| `PROD_APP_KEY` | `base64:AbCdEfGh...` | App Key (Generate via `php artisan key:generate` locally) |
| `PROD_APP_URL` | `https://myapp.com` | Public domain of the application |
| `PROD_REVERB_APP_ID` | `1001` | Reverb Application ID (Free/Random) |
| `PROD_REVERB_APP_KEY` | `my-reverb-key` | Random String for Reverb Key |
| `PROD_REVERB_APP_SECRET` | `my-reverb-secret` | Random String for Reverb Secret |

#### C. Database & Services Credentials
Passwords for supporting services.

| Secret Name | Example Value | Description |
| :--- | :--- | :--- |
| `PROD_DB_ROOT_PASSWORD`| `SuperSecretRoot!` | MariaDB Root Password |
| `PROD_DB_PASSWORD` | `AppSecretDB!` | Application Database User Password |
| `PROD_REDIS_PASSWORD` | `RedisSecure123` | Redis Password |
| `PROD_GRAFANA_ADMIN_PASSWORD` | `GrafanaAdmin123` | Grafana Dashboard Login Password |

#### D. External Storage (S3 / MinIO / AWS)
Credentials for object storage.

| Secret Name | Example Value | Description |
| :--- | :--- | :--- |
| `PROD_AWS_ACCESS_KEY_ID` | `AKIAIOSFODNN7EXAMPLE` | Access Key (MinIO User / AWS IAM) |
| `PROD_AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI...` | Secret Key (MinIO User / AWS IAM) |

#### E. Volume Names (Data Persistence)
Docker volume names to ensure data is not lost when containers are removed/redeployed.

| Secret Name | Example Value | Description |
| :--- | :--- | :--- |
| `PROD_MARIADB_VOLUME_NAME` | `prod-myapp-db-data` | Database Volume Name |
| `PROD_REDIS_VOLUME_NAME` | `prod-myapp-redis-data` | Redis Volume Name |
| `PROD_MINIO_VOLUME_NAME` | `prod-myapp-minio-data` | MinIO Volume Name |

---

## 3. Pre-Release Checklist

Before performing your first deployment:

1.  [ ] Ensure the VPS is ready (Docker & Docker Compose installed).
2.  [ ] Ensure the SSH Public Key derived from `PROD_SSH_KEY` is in `~/.ssh/authorized_keys` on the VPS.
3.  [ ] All Secrets listed above have been created in the GitHub Repo.
4.  [ ] **Push Code** to `master` branch. (Ensure test workflow is green ✅).
5.  [ ] **Create Release Tag** (e.g., `v1.0.0`). (Ensure build workflow is green ✅).
6.  [ ] Run the Manual Workflow **"Deploy to Production"** with input tag `v1.0.0`.

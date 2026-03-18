# Deployment Strategy: Enterprise Grade

This document explains the deployment strategy used in this project.

**This project implements the CONTINUOUS DELIVERY (CD) methodology.**

> **Definition of Continuous Delivery:**
> Valid code is automatically built and tested, then saved as an artifact (Docker Image) ready for release at any time. However, deployment to the production environment requires **manual action (Approval)** from a developer or release manager.

This differs from *Continuous Deployment* where every code change is automatically deployed to production without brakes.

## Continuous Delivery vs Continuous Deployment

### 1. Continuous Deployment (Not Recommended for Monolith)
As soon as code is merged or tagged, GitHub automatically builds the image **AND** directly restarts the production server.
*   **Risk**: If an error occurs during the build process or the SSH connection drops midway, the production server could go down during peak hours.

### 2. Continuous Delivery (Our Strategy - Highly Secure)
GitHub is only responsible for building the image and storing it in the container registry (GHCR). The application is always ready to be released, but **when** that release happens is entirely up to the developer or business team.

---

## 3 Key Advantages of This Approach

### 1. Absolute Time Control (Zero Downtime Anxiety)
The process of building a Docker Image (downloading Composer vendors, compiling NPM assets) can take 5-10 minutes. If this is combined with deployment, you'll be anxious waiting.
By separating them, the image is ready in GHCR since the afternoon. When you want to deploy at 2 AM, the process takes only seconds (because the server only needs to `docker pull` and restart the container).

### 2. Approval Gate
You can use the built image to test it first on the Staging server. If QA (Quality Assurance) or the client says "Okay, safe!", only then do you press the Deploy to Production button using the exact same image version.

### 3. Easy Rollback
Since the deployment process invokes a manual workflow, if version `v1.2.0` turns out to contain an error in production, you simply re-run the manual deployment workflow and input `v1.1.0`.
**Boom!** Your server reverts to the stable version in seconds.

---

## Configuration Strategy: Hybrid (Static + Dynamic)

We use a "Hybrid" approach to manage configuration, ensuring both convenience and security.

### 1. Static Config (`config.json`)
Non-sensitive configurations (e.g., App Name, Timezone, Public Ports, Docker Network names) are stored in `config.json` in the repository.
*   **Role**: Provides default values for all environments.
*   **Sync**: The `setup-env.sh` script automatically reads this file and populates the `.env` files.

### 2. Dynamic Secrets (CI/CD Injection)
Sensitive data (e.g., Database Passwords, API Keys, Production Secrets) **ARE NOT** stored in `config.json`.
*   **Role**: Overwrites specific values in `.env` files during deployment.
*   **Mechanism**:
    1.  GitHub Actions holds these secrets (Settings > Secrets).
    2.  The Deployment Workflow passes these secrets as **arguments** to the deploy script.
    3.  `deploy.sh` runs `setup-env.sh` to generate the base configuration.
    4.  `deploy.sh` then **injects** these secrets directly into the generated `.env` files.

### Deployment Flow (Step-by-Step)

1.  **Artifact Transfer**:
    *   CI/CD copies the latest strictly necessary files to the server: `scripts/`, `infra/`, `docker-compose.yml`, `config.json`, and `.env.example`.
    *   *Note: Source code (`servers/app-server/`) is NOT copied to the server.*
2.  **Env Generation & Injection**:
    *   CI/CD runs `./deploy.sh`.
    *   `deploy.sh` calls `./scripts/setup/setup-env.sh` to load defaults from `config.json`.
    *   `deploy.sh` parses its arguments and injects **Dynamic Secrets** into the `.env` files.
3.  **Container Launch**:
    *   Server pulls the Docker Image (Artifact) from GHCR.
    *   Server restarts containers using the generated `.env` files.

---

## Testing & Quality Assurance (Automated)

We implement a rigorous testing strategy to ensure stability before deployment.

### 1. Feature Tests (CI Pipeline)
Every time a commit is pushed to the `master` branch or a Pull Request is opened, GitHub Actions automatically runs the **Feature Tests**.

*   **Type**: Ephemeral Testing Environment.
*   **Process**:
    1.  GitHub Actions spins up a fresh `mariadb`, `redis`, and `app` container.
    2.  It creates a dedicated testing database.
    3.  It executes the `test.sh` script (which runs `php artisan test`).
    4.  If tests fail, the pipeline fails, preventing potential bad code from being tagged for release.

### 2. Local Testing (Developer Guide)
Before pushing code, developers are encouraged to run the full suite locally.
Since our app requires SSL and specific host setups, follow these steps:

1.  **Setup Environment**: Ensure `.env` files are synced (`./setup.sh` -> `setup-env`).
2.  **Run Server & CA**: Start the Step CA server implies you have running `docker-compose.step-ca.yml`.
3.  **Run Dev SSL**: Generate certificates for local domains (`myapp.test`).
4.  **Run Dev SSL Verify**: Ensure certificates are trusted by your browser/OS.
5.  **Setup Host**: Add `127.0.0.1 myapp.test api.myapp.test ...` to your `/etc/hosts`.
6.  **Run Whole App**: `./run.sh` -> "Run All App".
7.  **Execute Tests**:
    ```bash
    ./test.sh
    ```

> **Note**: It is important for the container environment to have the main VPS Nginx (Load Balancer) configuration mimicked locally if you are testing domain-specific routing.

---

## Important Rule: No Source Code on Server

To ensure security and consistency (**Immutable Infrastructure**), we enforce a strict rule:

> **The application source code (`app/` folder) MUST NOT exist on the Production Server.**

The server only needs:
1.  **Orchestration Files**: `docker-compose.yml` (and/or `docker-compose.prod.yml`).
2.  **Configuration**: `.env` files (generated by CI/CD).
3.  **Scripts**: `scripts/` folder for operational tasks.

**Why?**
*   **Security**: If the server is compromised, the attacker cannot modify the source code to inject backdoors because the code is locked inside the read-only Docker Image.
*   **Consistency**: Eliminates "it works on my machine" issues. What runs on the server is exactly the byte-for-byte image built by GitHub Actions.

---

## Implementation in GitHub Actions

To realize this strategy, we use **TWO** separate workflow files:

### Workflow 1: Build & Push (Automatic)
This workflow only cares about creating the image and "wrapping the code".

*   **Trigger**: `on: push: tags: ['v*.*.*']`
*   **Task**: Build Docker Image → Push to GHCR with that version tag → Done. (Does not touch the production server at all).

### Workflow 2: Deploy to Production (Manual)
In this workflow, we use the `workflow_dispatch` feature with input parameters.

```yaml
name: 🚀 Manual Deploy to Production

on:
  workflow_dispatch:
    inputs:
      version_tag:
        description: 'Docker Image Tag to deploy (e.g., v1.2.0)'
        required: true
        type: string

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Execute Deploy on Server
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.PROD_SERVER_IP }}
          username: ${{ secrets.PROD_SERVER_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          # Sends the manually typed version to the server
          script: |
            cd /path/to/project
            ./deploy.sh ${{ github.event.inputs.version_tag }}
```

### Result
When you want to deploy:
1.  Go to the **Actions** tab in GitHub.
2.  Click the **"Manual Deploy to Production"** workflow.
3.  GitHub will show a small text box. Type `v1.2.0`.
4.  Click **Run**.

By separating this, CI/CD responsibilities become very clean. **CI** is responsible for "Wrapping Code", and **CD** is responsible for "Shipping Code" when you are ready.

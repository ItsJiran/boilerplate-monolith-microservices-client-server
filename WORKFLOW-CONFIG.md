# Configuration & Deployment Workflow

Dokumen ini menjelaskan strategi manajemen konfigurasi project `Monolith Laravel` ini. Kita memisahkan antara **Static Configuration** (URL, Domain) dan **Dynamic Secrets** (Password, Keys).

## 1. Filosofi Config

Kita menggunakan pendekatan **Hybrid Configuration**:

1.  **`config.json`**: Menyimpan konfigurasi *non-sensitive* yang spesifik per environment (Local, Staging, Production). Ini seperti URL, Domain, dan Debug Mode.
2.  **`.env.example`**: Template dasar `.env` yang digunakan developer local.
3.  **CI/CD Secrets**: Menyimpan *credentials* sensitif (DB Password, API Keys) yang akan disuntikkan (injected) saat deployment.

---

## 2. Struktur `config.json`

File ini menjadi "Single Source of Truth" untuk alamat-alamat server di setiap environment.

```json
{
  "local": {
    "APP_URL": "https://myapp.test",
    "APP_DEBUG": true
    // ...
  },
  "staging": {
    "APP_URL": "https://staging.myapp.com",
    "APP_DEBUG": true
    // ...
  },
  "production": {
    "APP_URL": "https://myapp.com",
    "APP_DEBUG": false
    // ...
  }
}
```

---

## 3. Workflow Development (Local)

Di laptop developer, alurnya tetap sederhana menggunakan script yang sudah disediakan.

1.  **Clone Repo**.
2.  Run `bash setup.sh`.
    *   Script ini akan meng-copy `.env.example` -> `.env`.
    *   *Future Improvement:* Script Setup bisa dimodifikasi untuk membaca `config.json` bagian `"local"` dan otomatis mengisi variabel di `.env`.
3.  Developer mengubah value di `.env` jika perlu kustomisasi lokal.

---

## 4. Workflow Production (CI/CD)

Saat deployment (via GitHub Actions / GitLab CI), kita menggunakan pendekatan **"Infrastructure as Code"** untuk konfigurasi.

> **⚠️ PENTING: NO DIRECT SERVER ACCESS**
> Developer **DILARANG KERAS** mengubah file `.env` langsung di server production (SSH).
> Hal ini mencegah **Configuration Drift** (perbedaan config antara kode dan server yang tidak terdeteksi).
> Semua perubahan config harus melalui Git (edit `config.json` atau secrets) -> CI/CD Pipeline -> Deploy.

### Alur Automation (CI/CD)

Pipeline CI/CD bertugas merakit file `.env` yang "fresh" setiap kali deploy, meniban konfigurasi lama untuk memastikan konsistensi:

1.  **Checkout Code**.
2.  **Base Setup (Structure)**:
    Jalankan `setup-env.sh` untuk membuat file `.env` dasar dari `.env.example`. Ini penting agar struktur variabel baru di code (misal fitur baru butuh `API_KEY_BARU`) otomatis terbuat di production.
3.  **Config Sync (Static Values)**:
    Pipeline membaca `config.json` -> key `production` (atau `staging`). Script automasi akan meniban value default `.env.example` dengan value production dari JSON (misal: Memory Limit, URL, Debug mode = false).
4.  **Secret Injection (Dynamic Secrets)**:
    Pipeline mengambil secrets dari **Repository Settings (GitHub Secrets)** dan meniban variable sensitif yang bersifat rahasia.
    *   *Contoh:* `DB_PASSWORD`, `APP_KEY`, `AWS_SECRET_ACCESS_KEY`.

### Contoh Implementasi (Gambaran Script CI)

```yaml
# GitHub Actions Example Step (Conceptual)
- name: 🚀 Setup Production Environment Variables
  run: |
    # 1. Setup Base Environment (.env, .env.backend, .env.devops)
    # Gunakan --force untuk memastikan kita meniban file lama jika ada (Fresh Config)
    bash scripts/setup/setup-env.sh --force
    
    # 2. Apply Static Config from config.json (Production Profile)
    # (Kita asumsikan ada tool/script untuk sync config ke env target)
    php scripts/utils/sync-config.php --env=production
    
    # 3. Inject Secrets (Dynamic Override)
    # Menggunakan sed/envsubst untuk mengganti value placeholder dengan Real Secret
    # Penting: Secret DI-INJECT saat runtime pipeline, tidak pernah di-commit!
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${{ secrets.PROD_DB_PASSWORD }}|g" .env
    sed -i "s|APP_KEY=.*|APP_KEY=${{ secrets.PROD_APP_KEY }}|g" .env
```

---

## 5. Ringkasan Variable Strategy

| Variable Type | Contoh | Sumber di Local | Sumber di Prod |
| :--- | :--- | :--- | :--- |
| **Connectivity** | `APP_URL`, `S3_URL` | `config.json` (local) / `.env` | `config.json` (production) |
| **Logic** | `APP_DEBUG`, `APP_ENV` | `.env` | `config.json` (production) |
| **Secrets** | `DB_PASSWORD`, `APP_KEY` | `.env` (isi manual/default) | **CI/CD Repository Secrets** |
| **Infrastructure** | `MYSQL_ROOT_PASSWORD` | `.env` | **CI/CD Repository Secrets** |

Dengan metode ini:
1.  Kita tidak perlu hardcode URL production di `.env.example`.
2.  Kita tidak perlu takut password bocor karena password production ada di GitHub Secrets, bukan di file code.

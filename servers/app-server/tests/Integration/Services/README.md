# Integration Testing (Services)

This directory contains integration tests that interact with **REAL** services (Redis, MinIO, Reverb) running in Docker. Only the Database is mocked (SQLite In-Memory).

## Prerequisites

Ensure your Docker stack is running:
```bash
./run.app.sh
# Select option 1 (Up All)
```

## Running Tests

### Method A: From Inside Docker (Recommended)
This is the most reliable method as it shares the internal network.

1. Enter the app container:
   ```bash
   docker compose exec app bash
   ```
2. Run the tests using the Docker-specific config:
   ```bash
   php artisan test --configuration=phpunit-integration-docker.xml
   ```

### Method B: From Host Machine
Make sure you have exposed the ports in `docker-compose.yml` (MinIO: 19000, Reverb: 18080, Redis: 6380).

1. Run dependencies installation (if not already done via docker):
   ```bash
   composer install
   ```
2. Run tests using the Host-specific config:
   ```bash
   php artisan test --configuration=phpunit-integration.xml
   ```

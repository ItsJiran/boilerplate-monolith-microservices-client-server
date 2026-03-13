#!/bin/bash

# =========================================================
# FEATURE TESTING SCRIPT (Runs inside Docker)
# =========================================================
# This script executes the Laravel Feature Tests.
# It can be run locally or within a CI/CD pipeline (e.g., GitHub Actions).
# 
# Usage: ./test.sh [arguments for php artisan test]
# Example: ./test.sh --filter UserTest
# =========================================================

# --- TTY Detection ---
# Docker requires '-it' for interactive terminals, but this fails in CI environments.
if [ -t 1 ]; then
    TTY_FLAG="-it"
else
    TTY_FLAG="-T" # No TTY allocation for CI/Scripts
fi

echo "🧪 Running Tests in Docker Container..."

# We target the 'app' container which usually has the full dev stack.
# We ensure we use the 'phpunit-integration-docker.xml' configuration
# if available, or fallback to default if not specified.
# However, usually just running `php artisan test` is enough if env is set correctly.

docker compose exec $TTY_FLAG app php artisan test "$@"


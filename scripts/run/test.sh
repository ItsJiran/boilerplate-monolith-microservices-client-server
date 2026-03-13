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

docker compose exec -it app php artisan test "$@"


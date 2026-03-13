#!/bin/bash

# Jalankan command php artisan test di dalam container 'app'
# "$@" akan meneruskan argument tambahan (misal: --filter, path file test, dll)

docker compose exec -it app php artisan test "$@"

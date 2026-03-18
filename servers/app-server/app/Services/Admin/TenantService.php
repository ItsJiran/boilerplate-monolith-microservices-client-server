<?php

namespace App\Services\Admin;

use App\DTO\Admin\CreateTenantDto;
use App\DTO\Admin\UpdateTenantDto;
use App\Models\Tenant;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Cache;

class TenantService
{
    /**
     * Get tenant query scoped by user permissions.
     */
    public function getTenantQuery(User $user): Builder
    {
        if ($user->hasRole('superadmin')) {
            return Tenant::query();
        }

        $adminRoles = $user->roles()
            ->withPivot('tenant_id')
            ->where('slug', 'admin')
            ->get();

        if ($adminRoles->contains(fn ($role) => is_null($role->pivot?->tenant_id))) {
            return Tenant::query();
        }

        $tenantIds = $adminRoles
            ->pluck('pivot.tenant_id')
            ->filter()
            ->unique()
            ->values()
            ->all();

        if (empty($tenantIds)) {
            return Tenant::query()->whereRaw('0 = 1');
        }

        return Tenant::whereKey($tenantIds);
    }

    /**
     * Get paginated tenants.
     */
    public function getPaginatedTenants(User $user, int $perPage = 15): LengthAwarePaginator
    {
        $tenantQuery = $this->getTenantQuery($user);

        return $tenantQuery
            ->orderBy('name')
            ->paginate($perPage)
            ->through(fn (Tenant $tenant) => [
                'id' => $tenant->id,
                'name' => $tenant->name,
                'slug' => $tenant->slug,
                'profile_path' => $tenant->profile_path,
                'created_at' => $tenant->created_at?->toDateTimeString(),
            ]);
    }

    /**
     * Get tenant statistics.
     */
    public function getTenantStats(User $user): array
    {
        $tenantQuery = $this->getTenantQuery($user);

        return [
            'withProfileCount' => (clone $tenantQuery)
                ->whereNotNull('profile_path')
                ->count(),
        ];
    }

    /**
     * Create a new tenant.
     */
    public function createTenant(CreateTenantDto $dto): Tenant
    {
        $tenant = Tenant::create($dto->toArray());
        Cache::tags(['user_roles'])->flush();

        return $tenant;
    }

    /**
     * Update a tenant.
     */
    public function updateTenant(Tenant $tenant, UpdateTenantDto $dto): Tenant
    {
        $tenant->update($dto->toArray());
        Cache::tags(['user_roles'])->flush();

        return $tenant;
    }

    /**
     * Delete a tenant.
     */
    public function deleteTenant(Tenant $tenant): void
    {
        $tenant->delete();
        Cache::tags(['user_roles'])->flush();
    }

    /**
     * Get tenant options for dropdown/select filtered by allowed tenant IDs.
     */
    public function getTenantOptions(?array $allowedTenantIds): array
    {
        if ($allowedTenantIds === []) {
            return [];
        }

        $query = Tenant::query()->orderBy('name');

        if (!is_null($allowedTenantIds)) {
            $query->whereIn('id', $allowedTenantIds);
        }

        return $query
            ->get()
            ->map(fn (Tenant $tenant) => [
                'id' => $tenant->id,
                'name' => $tenant->name,
            ])
            ->all();
    }
}

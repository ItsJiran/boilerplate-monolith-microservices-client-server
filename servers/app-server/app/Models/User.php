<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Cache;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Role;
use App\Models\Tenant;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'profile_path',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class , 'user_roles')
            ->withPivot('assigned_at')
            ->withTimestamps();
    }

    public function cachedRoles(): array
    {
        $cacheKey = "rbac:user:{$this->id}:roles";

        return Cache::tags(['rbac', 'user_roles'])->remember($cacheKey, now()->addMinutes(15), function () {
            $roles = $this->roles()
                ->get()
                ->map(fn(Role $role) => [
            'id' => $role->id,
            'name' => $role->name,
            'slug' => $role->slug,
            'description' => $role->description,
            ]);

            $roleKeys = [];
            foreach ($roles as $role) {
                $roleKeys[$role['slug']] = true;
            }

            return [
                'roles' => $roles,
                'role_keys' => $roleKeys,
            ];
        });
    }

    /**
     * Helpers for checking assigned roles using the cached payload.
     */
    public function hasRole(string|array $slugs): bool
    {
        $required = Arr::wrap($slugs);

        if ($required === []) {
            return false;
        }

        $roleKeys = $this->cachedRoles()['role_keys'] ?? [];

        foreach ($required as $slug) {
            if (isset($roleKeys[$slug])) {
                return true;
            }
        }

        return false;
    }

    public function flushRoleCache(): void
    {
        Cache::forget("rbac:user:{$this->id}:roles");
    }
}
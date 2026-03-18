<?php

use Illuminate\Support\Facades\Broadcast;

// User Private Channel
Broadcast::channel('user.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

// Tenant channel (accessible by any user with a role in the tenant, including global)
Broadcast::channel('tenant.{tenantId}', function ($user, $tenantId) {
    try {
        $roles = $user->cachedRoles();
        $tenants = $roles['tenants'] ?? [];

        // Check specific tenant OR global access
        if (isset($tenants[$tenantId]) || isset($tenants['global'])) {
            return true;
        }

        return false;
    } catch (\Throwable $e) {
        \Illuminate\Support\Facades\Log::error("Tenant channel auth error: " . $e->getMessage());
        return false;
    }
});

// Tenant Role channel (dynamic role parameter)
Broadcast::channel('tenant.{tenantId}.role.{role}', function ($user, $tenantId, $role) {
    try {
        $roles = $user->cachedRoles();
        $lookup = $roles['lookup'] ?? [];

        $hasRoleInTenant = isset($lookup["{$user->id}:{$role}:{$tenantId}"]);
        $hasGlobalRole = isset($lookup["{$user->id}:{$role}:global"]);
        $isSuperAdmin = isset($lookup["{$user->id}:superadmin:global"]);

        return $hasRoleInTenant || $hasGlobalRole || $isSuperAdmin;
    } catch (\Throwable $e) {
        \Illuminate\Support\Facades\Log::error("Tenant role channel auth error: " . $e->getMessage());
        return false;
    }
});

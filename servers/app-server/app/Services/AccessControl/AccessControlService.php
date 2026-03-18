<?php

namespace App\Services\AccessControl;

use App\Models\User;

class AccessControlService
{
    public function hasAdminRole(User $user): bool
    {
        return $user->hasRole(['superadmin', 'admin']);
    }

    public function isSuperAdmin(User $user): bool
    {
        return $user->hasRole('superadmin');
    }
}
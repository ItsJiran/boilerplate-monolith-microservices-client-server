<?php

namespace Modules\System\Services\AccessControl;

use Modules\System\Models\SystemUser;

class AccessControlService
{
    public function hasAdminRole(SystemUser $user): bool
    {
        return $user->hasRole(['superadmin', 'admin']);
    }

    public function isSuperAdmin(SystemUser $user): bool
    {
        return $user->hasRole('superadmin');
    }
}
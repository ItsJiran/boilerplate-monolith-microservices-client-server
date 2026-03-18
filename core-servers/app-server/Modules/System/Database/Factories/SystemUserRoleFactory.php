<?php

namespace Modules\System\Database\Factories;

use Modules\System\Models\SystemRole;
use Modules\System\Models\Tenant;
use Modules\System\Models\SystemUser;
use Modules\System\Models\SystemUserRole;
use Illuminate\Database\Eloquent\Factories\Factory;

class SystemUserRoleFactory extends Factory
{
    protected $model = SystemUserRole::class;

    public function definition(): array
    {
        return [
            'user_id' => SystemUser::factory(),
            'role_id' => SystemRole::factory(),
            'tenant_id' => Tenant::factory(),
            'assigned_at' => now(),
        ];
    }
}

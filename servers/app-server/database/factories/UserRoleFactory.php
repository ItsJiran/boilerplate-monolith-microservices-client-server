<?php

namespace Database\Factories;

use App\Models\Role;
use App\Models\Tenant;
use App\Models\User;
use App\Models\UserRole;
use Illuminate\Database\Eloquent\Factories\Factory;

class UserRoleFactory extends Factory
{
    protected $model = UserRole::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'role_id' => Role::factory(),
            'tenant_id' => Tenant::factory(),
            'assigned_at' => now(),
        ];
    }
}

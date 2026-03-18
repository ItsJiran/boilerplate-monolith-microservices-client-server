<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            [
                'name' => 'Super Admin',
                'slug' => 'superadmin',
                'description' => 'Full access to every tenant and system configuration.',
            ],
            [
                'name' => 'Admin',
                'slug' => 'admin',
                'description' => 'Tenant-level operator that can manage marketing activities.',
            ],
            [
                'name' => 'Marketing',
                'slug' => 'marketing',
                'description' => 'Tenant-level operator that can manage marketing activities.',
            ],
        ];

        foreach ($roles as $role) {
            Role::updateOrCreate(
                ['slug' => $role['slug']],
                $role,
            );
        }
    }
}

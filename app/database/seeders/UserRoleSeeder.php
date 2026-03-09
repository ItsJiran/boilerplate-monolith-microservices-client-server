<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use App\Models\UserRole;
use Illuminate\Database\Seeder;

class UserRoleSeeder extends Seeder
{
    public function run(): void
    {
        $domain = $this->resolveDomain();

        $assignments = [
            "superadmin@{$domain}" => 'superadmin',
            "admin@{$domain}" => 'admin',
        ];

        foreach ($assignments as $email => $roleSlug) {
            $user = User::where('email', $email)->first();
            $role = Role::where('slug', $roleSlug)->first();

            if (!$user || !$role) {
                continue;
            }

            UserRole::updateOrCreate(
            [
                'user_id' => $user->id,
                'role_id' => $role->id,
            ],
            [
                'assigned_at' => now(),
            ],
            );
        }
    }

    private function resolveDomain(): string
    {
        $appUrl = env('APP_URL', 'http://localhost');
        $host = parse_url($appUrl, PHP_URL_HOST);

        if (!$host) {
            $host = \Illuminate\Support\Str::of($appUrl)
                ->after('://')
                ->before('/')
                ->before(':')
                ->toString();
        }

        $domain = $host
            ?\Illuminate\Support\Str::of($host)->lower()->replace('www.', '')->toString()
            : 'example.com';

        return $domain;
    }
}
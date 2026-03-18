<?php

namespace Modules\System\Database\Seeders;

use Modules\System\Models\SystemRole;
use Modules\System\Models\SystemUser;
use Modules\System\Models\SystemUserRole;
use Illuminate\Database\Seeder;

class SystemUserRoleSeeder extends Seeder
{
    public function run(): void
    {
        $domain = $this->resolveDomain();

        $assignments = [
            "superadmin@{$domain}" => 'superadmin',
            "admin@{$domain}" => 'admin',
        ];

        foreach ($assignments as $email => $roleSlug) {
            $user = SystemUser::where('email', $email)->first();
            $role = SystemRole::where('slug', $roleSlug)->first();

            if (!$user || !$role) {
                continue;
            }

            SystemUserRole::updateOrCreate(
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
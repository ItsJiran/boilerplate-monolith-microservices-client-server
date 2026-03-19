<?php

namespace Modules\System\Database\Seeders;

use Modules\System\Models\SystemUser;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SystemUserSeeder extends Seeder
{
    public function run(): void
    {
        $appUrl = env('SERVICE_SERVER_URL', 'http://localhost');
        $host = parse_url($appUrl, PHP_URL_HOST)
            ?: Str::of($appUrl)
                ->after('://')
                ->before('/')
                ->before(':')
                ->toString();

        $domain = $host ? Str::of($host)->lower()->replace('www.', '')->toString() : 'example.com';

        $users = [
            [
                'name' => 'Super Admin',
                'username' => 'superadmin',
                'email' => "superadmin@{$domain}",
                'profile_path' => '/avatars/superadmin.png',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Admin',
                'username' => 'admin',
                'email' => "admin@{$domain}",
                'profile_path' => '/avatars/admin.png',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ],
        ];

        foreach ($users as $attributes) {
            SystemUser::updateOrCreate(
                ['email' => $attributes['email']],
                $attributes,
            );
        }
    }
}

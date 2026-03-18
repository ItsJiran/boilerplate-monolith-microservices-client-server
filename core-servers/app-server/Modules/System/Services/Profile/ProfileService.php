<?php

namespace Modules\System\Services\Profile;

use Modules\System\DTO\Profile\UpdateProfileDto;
use Modules\System\Models\SystemUser;
use Illuminate\Support\Facades\Auth;

class ProfileService
{
    /**
     * Get profile data for editing.
     */
    public function getProfileData(SystemUser $user): array
    {
        return [
            'mustVerifyEmail' => $user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail,
            'status' => session('status'),
        ];
    }

    /**
     * Update user profile.
     */
    public function updateProfile(UpdateProfileDto $dto): SystemUser
    {
        $user = $dto->user;
        $user->fill($dto->toArray());

        if ($user->isDirty('email')) {
            $user->email_verified_at = null;
        }

        $user->save();

        return $user;
    }

    /**
     * Delete user account.
     */
    public function deleteAccount(SystemUser $user): void
    {
        Auth::logout();
        $user->delete();
    }
}

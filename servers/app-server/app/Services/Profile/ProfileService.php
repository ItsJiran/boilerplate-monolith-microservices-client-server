<?php

namespace App\Services\Profile;

use App\DTO\Profile\UpdateProfileDto;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class ProfileService
{
    /**
     * Get profile data for editing.
     */
    public function getProfileData(User $user): array
    {
        return [
            'mustVerifyEmail' => $user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail,
            'status' => session('status'),
        ];
    }

    /**
     * Update user profile.
     */
    public function updateProfile(UpdateProfileDto $dto): User
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
    public function deleteAccount(User $user): void
    {
        Auth::logout();
        $user->delete();
    }
}

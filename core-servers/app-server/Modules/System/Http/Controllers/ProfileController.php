<?php

namespace Modules\System\Http\Controllers;

use Modules\System\DTO\Profile\UpdateProfileDto;
use Modules\System\Http\Requests\ProfileUpdateRequest;
use Modules\System\Services\Profile\ProfileService;
use Modules\System\Services\Shared\AppResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function __construct(
        protected ProfileService $profileService
    ) {}

    /**
     * Display the user's profile form.
     */
    public function edit(Request $request)
    {
        $data = $this->profileService->getProfileData($request->user());

        return AppResponse::success(
            data: $data,
            view: 'Profile/Edit'
        );
    }

    /**
     * Update the user's profile information.
     */
    public function update(ProfileUpdateRequest $request)
    {
        $dto = UpdateProfileDto::fromRequest($request);
        $this->profileService->updateProfile($dto);

        return AppResponse::success(
            message: 'Profile updated successfully.',
            route: 'profile.edit'
        );
    }

    /**
     * Delete the user's account.
     */
    public function destroy(Request $request)
    {
        $request->validate([
            'password' => ['required', 'current_password'],
        ]);

        $this->profileService->deleteAccount($request->user());

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        // Use direct redirect since we're logging out
        return redirect('/');
    }
}

<?php

namespace Modules\System\DTO\Profile;

use Modules\System\Http\Requests\ProfileUpdateRequest;
use Modules\System\Models\SystemUser;

readonly class UpdateProfileDto
{
    public function __construct(
        public SystemUser $user,
        public string $name,
        public string $email,
    ) {}

    public static function fromRequest(ProfileUpdateRequest $request): self
    {
        $validated = $request->validated();

        return new self(
            user: $request->user(),
            name: $validated['name'],
            email: $validated['email'],
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'email' => $this->email,
        ];
    }
}

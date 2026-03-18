<?php

namespace App\DTO\Profile;

use App\Http\Requests\ProfileUpdateRequest;
use App\Models\User;

readonly class UpdateProfileDto
{
    public function __construct(
        public User $user,
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

<?php

namespace App\DTO\Admin;

use Illuminate\Http\Request;

readonly class CreateTenantDto
{
    public function __construct(
        public string $name,
        public string $slug,
        public ?string $profile_path = null,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validated();

        return new self(
            name: $validated['name'],
            slug: $validated['slug'],
            profile_path: $validated['profile_path'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'slug' => $this->slug,
            'profile_path' => $this->profile_path,
        ];
    }
}

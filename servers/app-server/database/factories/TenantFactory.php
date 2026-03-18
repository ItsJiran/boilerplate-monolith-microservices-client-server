<?php

namespace Database\Factories;

use App\Models\Tenant;
use Illuminate\Database\Eloquent\Factories\Factory;
use Database\Factories\Concerns\WithFixedLengthSlug;

class TenantFactory extends Factory
{
    use WithFixedLengthSlug;

    protected $model = Tenant::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->company,
            'slug' => $this->uniqueSlug(255),
            'profile_path' => null,
        ];
    }
}

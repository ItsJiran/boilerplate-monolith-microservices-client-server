<?php

namespace Database\Factories;

use App\Models\Role;
use Database\Factories\Concerns\WithFixedLengthSlug;
use Illuminate\Database\Eloquent\Factories\Factory;

class RoleFactory extends Factory
{
    use WithFixedLengthSlug;

    protected $model = Role::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->jobTitle,
            'slug' => $this->uniqueSlug(255),
        ];
    }
}

<?php

namespace Modules\System\Database\Factories;

use Modules\System\Models\SystemRole;
use Modules\System\Database\Factories\Concerns\WithFixedLengthSlug;
use Illuminate\Database\Eloquent\Factories\Factory;

class SystemRoleFactory extends Factory
{
    use WithFixedLengthSlug;

    protected $model = SystemRole::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->jobTitle,
            'slug' => $this->uniqueSlug(255),
        ];
    }
}

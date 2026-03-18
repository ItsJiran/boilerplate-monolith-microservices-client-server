<?php

namespace Modules\System\Database\Factories\Concerns;

use Illuminate\Support\Str;

trait WithFixedLengthSlug
{
    /**
     * Generate a unique fixed-length slug.
     *
     * @param int $length
     * @return string
     */
    protected function uniqueSlug(int $length = 255): string
    {
        // Generate a random alphanumeric string of exact length
        return $this->faker->unique()->regexify('[a-zA-Z0-9]{' . $length . '}');
    }

    /**
     * Generate a unique slug with a prefix, ensuring total length.
     *
     * @param string $prefix
     * @param int $totalLength
     * @return string
     */
    protected function uniqueSlugWithPrefix(string $prefix, int $totalLength = 255): string
    {
        $randomLength = max(1, $totalLength - strlen($prefix));
        return $prefix . $this->faker->unique()->regexify('[a-zA-Z0-9]{' . $randomLength . '}');
    }
}

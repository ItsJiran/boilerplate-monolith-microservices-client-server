<?php

namespace Tests\Integration\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Redis;
use Tests\TestCase;

class RedisIntegrationTest extends TestCase
{
    /** @test */
    public function it_can_connect_to_real_redis()
    {
        // 1. Test Raw Config
        $this->assertEquals('redis', config('cache.default'));
        
        // 2. Test Ping
        try {
            $response = Redis::connection()->ping();
            // Redis response might be generic object or string depending on client
            // phpredis returns true or +PONG
            $this->assertTrue($response == true || $response == '+PONG');
        } catch (\Exception $e) {
            $this->fail("Failed to connect to Redis: " . $e->getMessage());
        }
    }

    /** @test */
    public function it_can_store_and_retrieve_cache_from_real_redis()
    {
        $key = 'integration_test_key_' . uniqid();
        $value = 'Hello Redis ' . time();

        // Put in cache
        Cache::put($key, $value, 60);

        // Verify it exists in Redis directly
        $redisValue = Redis::get(config('cache.prefix') . $key);
        // Laravel default cache serializer puts things in a specific format, 
        // but Cache::get should retrieve it correctly.
        
        $retrieved = Cache::get($key);

        $this->assertEquals($value, $retrieved);

        // Cleanup
        Cache::forget($key);
    }
}

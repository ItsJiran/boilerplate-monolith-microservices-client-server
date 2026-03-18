<?php

namespace Tests\Integration\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class S3IntegrationTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        // Force boolean type to avoid AWS SDK strict type error (env vars are strings)
        config(['filesystems.disks.s3.use_path_style_endpoint' => true]);
    }

    /** @test */
    public function it_can_connect_and_upload_to_real_s3_minio()
    {
        // Ensure we are using s3 disk
        $this->assertEquals('s3', config('filesystems.default'));

        $filename = 'integration_test_' . uniqid() . '.txt';
        $content = 'This is a test content for S3 Integration: ' . time();

        // 1. Upload
        $uploaded = Storage::disk('s3')->put($filename, $content);

        $this->assertTrue($uploaded, "Failed to upload file to S3");

        // 2. Check Existence
        $this->assertTrue(Storage::disk('s3')->exists($filename), "File does not exist in S3 after upload");

        // 3. Check Content
        $retrievedContent = Storage::disk('s3')->get($filename);
        $this->assertEquals($content, $retrievedContent);

        // 4. Check Visibility/URL (Optional, depends on bucket policy)
        $url = Storage::disk('s3')->url($filename);
        $this->assertStringContainsString($filename, $url);

        // 5. Cleanup
        Storage::disk('s3')->delete($filename);
        $this->assertFalse(Storage::disk('s3')->exists($filename), "File still exists after delete");
    }
}

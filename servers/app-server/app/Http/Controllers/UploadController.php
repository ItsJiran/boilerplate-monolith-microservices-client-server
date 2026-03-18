<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;

class UploadController extends Controller
{
    public function create()
    {
        return Inertia::render('UploadTest');
    }

    /**
     * Accept an image upload and push it to the configured S3 (MinIO) disk.
     */
    public function store(Request $request)
    {
        $request->validate([
            'image' => ['required', 'image', 'max:5120'],
        ]);

        $disk = Storage::disk('s3');
        $path = $disk->putFile('uploads/tests', $request->file('image'), 'public');
        $url = $disk->url($path);

        return back()->with('upload', [
            'path' => $path,
            'url' => $url,
        ]);
    }
}

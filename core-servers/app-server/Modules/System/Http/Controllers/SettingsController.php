<?php

namespace Modules\System\Http\Controllers;

use Modules\System\Services\Shared\AppResponse;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function index(Request $request)
    {
        return AppResponse::success(
            data: [
                'mustVerifyEmail' => $request->user() instanceof MustVerifyEmail,
                'status' => session('status'),
            ],
            view: 'Settings'
        );
    }
}

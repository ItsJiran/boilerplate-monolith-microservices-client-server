<?php

namespace App\Http\Controllers;

use App\DTO\Dashboard\DashboardFilterDto;
use App\Services\Dashboard\DashboardService;
use App\Services\Shared\AppResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function __construct(
        protected DashboardService $dashboardService,
    ) {}

    public function index(Request $request)
    {
        try {
            $user = Auth::user();
            $dto = DashboardFilterDto::fromRequest($request);
            $dashboardData = $this->dashboardService->getDashboardData($dto, $user);

            return AppResponse::success(
                data: $dashboardData,
                view: 'Dashboard'
            );
        } catch (\Exception $e) {
            return AppResponse::error(
                message: 'Failed to load dashboard data',
                details: $e->getMessage()
            );
        }
    }
}

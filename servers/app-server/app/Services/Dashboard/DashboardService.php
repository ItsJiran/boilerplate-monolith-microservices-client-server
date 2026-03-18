<?php

namespace App\Services\Dashboard;

use App\DTO\Dashboard\DashboardFilterDto;
use App\Models\User;
use App\Services\AccessControl\AccessControlService;

class DashboardService
{
    public function __construct(
        protected AccessControlService $accessControlService,
        )
    {
    }

    public function getDashboardData(DashboardFilterDto $dto, User $user): array
    {
        // Add your boilerplate dashboard queries here
        return [
            'period' => $dto->period,
            'startDate' => $dto->resolvedStartDate->toDateString(),
            'endDate' => $dto->resolvedEndDate->toDateString(),
            'stageTypeData' => [],
            'stageTypeUniqueData' => [],
            'tenantActivityData' => [],
            'activeActivities' => [],
            'activeActivitiesPagination' => [
                'current_page' => 1,
                'last_page' => 1,
                'per_page' => 15,
                'total' => 0,
                'from' => 1,
                'to' => 0,
            ],
            'page' => 1,
        ];
    }
}
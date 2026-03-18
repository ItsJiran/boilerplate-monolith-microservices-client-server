<?php

namespace App\DTO\Dashboard;

use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

readonly class DashboardFilterDto
{
    public function __construct(
        public ?int $tenantId,
        public string $period,
        public ?string $startDate,
        public ?string $endDate,
        public Carbon $resolvedStartDate,
        public Carbon $resolvedEndDate
    ) {}

    public static function fromRequest(Request $request): self
    {
        $period = self::normalizePeriod($request->input('period', 'month'));
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');

        [$resolvedStartDate, $resolvedEndDate] = self::resolveDateRange($period, $startDate, $endDate);

        return new self(
            tenantId: $request->input('tenant_id') ? (int) $request->input('tenant_id') : null,
            period: $period,
            startDate: $startDate,
            endDate: $endDate,
            resolvedStartDate: $resolvedStartDate,
            resolvedEndDate: $resolvedEndDate
        );
    }

    private static function normalizePeriod(string $period): string
    {
        $allowed = ['week', 'month', 'year', 'custom'];
        return in_array($period, $allowed, true) ? $period : 'month';
    }

    private static function resolveDateRange(string $period, ?string $startDate, ?string $endDate): array
    {
        $now = Carbon::now();

        if (!empty($startDate) && !empty($endDate)) {
            return [
                Carbon::parse($startDate)->startOfDay(),
                Carbon::parse($endDate)->endOfDay(),
            ];
        }

        return match ($period) {
            'week' => [$now->copy()->startOfWeek(), $now->copy()->endOfWeek()],
            'year' => [$now->copy()->startOfYear(), $now->copy()->endOfYear()],
            default => [$now->copy()->startOfMonth(), $now->copy()->endOfMonth()],
        };
    }
}

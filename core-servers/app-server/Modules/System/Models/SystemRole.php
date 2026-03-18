<?php

namespace Modules\System\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class SystemRole extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'slug',
        'description',
    ];

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(SystemUser::class, 'system_user_roles')
            ->withPivot('assigned_at')
            ->withTimestamps();
    }

    public function userRoles(): HasMany
    {
        return $this->hasMany(SystemUserRole::class);
    }
}

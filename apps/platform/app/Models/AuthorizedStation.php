<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Autorisation pour une entreprise d'utiliser une station donnée.
 *
 * @property int $id
 * @property int $enterprise_organization_id
 * @property int $station_organization_id
 * @property int|null $authorized_by
 */
class AuthorizedStation extends Model
{
    protected $fillable = [
        'enterprise_organization_id', 'station_organization_id', 'authorized_by',
    ];

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function enterprise(): BelongsTo
    {
        return $this->belongsTo(Organization::class, 'enterprise_organization_id');
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function station(): BelongsTo
    {
        return $this->belongsTo(Organization::class, 'station_organization_id');
    }

    public static function isAuthorized(int $enterpriseId, int $stationId): bool
    {
        return self::query()
            ->where('enterprise_organization_id', $enterpriseId)
            ->where('station_organization_id', $stationId)
            ->exists();
    }
}

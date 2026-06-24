<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Payment
 */
class PaymentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reference' => $this->reference,
            'short_code' => $this->short_code,
            'status' => $this->status->value,
            'via' => $this->via->value,
            'fuel_type' => $this->fuel_type->value,
            'amount' => $this->amount,
            'failure_reason' => $this->failure_reason,
            'station_organization_id' => $this->station_organization_id,
            'pump_id' => $this->pump_id,
            'expires_at' => $this->expires_at->toIso8601String(),
            'confirmed_at' => $this->confirmed_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}

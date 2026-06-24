<?php

namespace Database\Factories;

use App\Domain\Operations\RefundStatus;
use App\Models\Payment;
use App\Models\RefundRequest;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RefundRequest>
 */
class RefundRequestFactory extends Factory
{
    protected $model = RefundRequest::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $payment = Payment::factory()->paid()->create();

        return [
            'payment_id' => $payment->id,
            'station_organization_id' => $payment->station_organization_id,
            'status' => RefundStatus::Pending,
            'reason' => 'Erreur de montant',
        ];
    }
}

<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Domain\Organizations\OrganizationCode;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Crée une session de paiement (paiement « pending ») valable 5 minutes après
 * vérification de l'éligibilité. Aucun débit n'a lieu à cette étape.
 */
final class CreatePaymentSession
{
    public const int TTL_SECONDS = 300;

    public function __construct(private readonly CheckPaymentEligibility $eligibility) {}

    public function handle(User $driver, ScanContext $context, FuelType $fuel, Money $amount, ?Carbon $now = null): Payment
    {
        $now ??= Carbon::now();

        $this->eligibility->assertContext($driver, $context, $fuel);

        $account = FuelAccount::query()->where('organization_id', $driver->organization_id)->first();
        $budget = DriverBudget::query()->where('user_id', $driver->id)->first();
        $this->eligibility->assertFunds($account, $budget, $amount);

        return DB::transaction(fn (): Payment => Payment::query()->create([
            'reference' => $this->uniqueReference(),
            'short_code' => $this->uniqueShortCode(),
            'organization_id' => $driver->organization_id,
            'driver_id' => $driver->id,
            'station_organization_id' => $context->station->id,
            'pump_id' => $context->pump->id,
            'work_session_id' => $context->workSession?->id,
            'pompiste_id' => $context->pompisteId,
            'via' => $context->via,
            'fuel_type' => $fuel,
            'amount' => $amount->amount,
            'status' => PaymentStatus::Pending,
            'expires_at' => $now->copy()->addSeconds(self::TTL_SECONDS),
        ]));
    }

    private function uniqueReference(): string
    {
        do {
            $reference = 'FUSY-'.strtoupper(Str::random(8));
        } while (Payment::query()->where('reference', $reference)->exists());

        return $reference;
    }

    private function uniqueShortCode(): string
    {
        $alphabet = OrganizationCode::ALPHABET;

        do {
            $code = '';
            for ($i = 0; $i < 6; $i++) {
                $code .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
        } while (Payment::query()->where('short_code', $code)->exists());

        return $code;
    }
}

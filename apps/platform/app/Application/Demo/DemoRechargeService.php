<?php

declare(strict_types=1);

namespace App\Application\Demo;

use App\Application\FuelAccounts\CreditFuelAccount;
use App\Domain\Demo\DemoProvider;
use App\Domain\Demo\DemoRechargeStatus;
use App\Domain\Shared\DomainException;
use App\Domain\Shared\Money;
use App\Models\DemoRecharge;
use App\Models\FuelAccount;
use App\Models\Organization;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Simulation de recharge Orange Money / MTN MoMo / USSD à des fins de démonstration.
 * Strictement réservée aux organisations démo : aucun impact possible sur un solde
 * réel ou un reversement réel.
 */
final class DemoRechargeService
{
    public function __construct(private readonly CreditFuelAccount $credit) {}

    public function initiate(Organization $organization, DemoProvider $provider, Money $amount, ?string $phone = null): DemoRecharge
    {
        $this->assertDemo($organization);

        if ($amount->isZero()) {
            throw new DomainException('Le montant de la recharge démo doit être positif.');
        }

        return DemoRecharge::query()->create([
            'organization_id' => $organization->id,
            'provider' => $provider,
            'amount' => $amount->amount,
            'status' => DemoRechargeStatus::Pending,
            'reference' => 'DEMO-'.strtoupper(Str::random(8)),
            'phone' => $phone,
        ]);
    }

    /**
     * Fait évoluer une recharge démo vers un état final. Un succès crédite le solde
     * fictif de l'organisation démo via le ledger (référence demo_recharge).
     */
    public function settle(DemoRecharge $recharge, DemoRechargeStatus $outcome): DemoRecharge
    {
        if ($outcome === DemoRechargeStatus::Pending) {
            throw new DomainException('Un règlement démo doit aboutir à un état final.');
        }

        return DB::transaction(function () use ($recharge, $outcome): DemoRecharge {
            /** @var DemoRecharge $locked */
            $locked = DemoRecharge::query()->whereKey($recharge->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->status !== DemoRechargeStatus::Pending) {
                throw new DomainException('Cette recharge démo est déjà réglée.');
            }

            $organization = Organization::query()->findOrFail($locked->organization_id);
            $this->assertDemo($organization);

            if ($outcome === DemoRechargeStatus::Successful) {
                $account = FuelAccount::query()->firstOrCreate(['organization_id' => $organization->id], ['balance' => 0]);
                $this->credit->handle(
                    $account,
                    Money::fromInt($locked->amount),
                    description: 'Recharge démo '.$locked->provider->label(),
                    referenceType: 'demo_recharge',
                    referenceId: $locked->id,
                );
            }

            $locked->forceFill([
                'status' => $outcome,
                'settled_at' => Carbon::now(),
            ])->save();

            return $locked;
        });
    }

    private function assertDemo(Organization $organization): void
    {
        if (! $organization->is_demo) {
            throw new DomainException('Les recharges simulées sont réservées aux organisations démo.');
        }
    }
}

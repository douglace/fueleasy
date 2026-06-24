<?php

declare(strict_types=1);

namespace Tests\Feature\FuelAccounts;

use App\Application\FuelAccounts\CreditFuelAccount;
use App\Domain\FuelAccounts\LedgerEntryType;
use App\Domain\Shared\Money;
use App\Models\FuelAccount;
use App\Models\LedgerEntry;
use Illuminate\Foundation\Testing\RefreshDatabase;
use InvalidArgumentException;
use Tests\TestCase;

class CreditFuelAccountTest extends TestCase
{
    use RefreshDatabase;

    public function test_credit_increases_balance_and_records_a_ledger_entry(): void
    {
        $account = FuelAccount::factory()->withBalance(100_000)->create();

        $entry = app(CreditFuelAccount::class)->handle($account, Money::fromInt(250_000), description: 'Dépôt initial');

        $this->assertSame(350_000, $account->fresh()->balance);
        $this->assertSame(LedgerEntryType::Credit, $entry->entry_type);
        $this->assertSame(250_000, $entry->amount);
        $this->assertSame(350_000, $entry->balance_after);
        $this->assertSame('manual_credit', $entry->reference_type);
        $this->assertDatabaseHas('audit_logs', ['action' => 'fuel_account.credited']);
    }

    public function test_credit_rejects_zero_amount(): void
    {
        $account = FuelAccount::factory()->create();

        $this->expectException(InvalidArgumentException::class);

        app(CreditFuelAccount::class)->handle($account, Money::zero());
    }

    public function test_two_successive_credits_chain_the_balance_after(): void
    {
        $account = FuelAccount::factory()->create();
        $service = app(CreditFuelAccount::class);

        $service->handle($account, Money::fromInt(10_000));
        $service->handle($account, Money::fromInt(5_000));

        $balances = LedgerEntry::query()->orderBy('id')->pluck('balance_after')->all();
        $this->assertSame([10_000, 15_000], $balances);
        $this->assertSame(15_000, $account->fresh()->balance);
    }
}

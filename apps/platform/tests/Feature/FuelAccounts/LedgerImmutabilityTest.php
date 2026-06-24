<?php

declare(strict_types=1);

namespace Tests\Feature\FuelAccounts;

use App\Domain\FuelAccounts\LedgerEntryType;
use App\Models\FuelAccount;
use App\Models\LedgerEntry;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class LedgerImmutabilityTest extends TestCase
{
    use RefreshDatabase;

    private function makeEntry(): LedgerEntry
    {
        $account = FuelAccount::factory()->withBalance(10_000)->create();

        return LedgerEntry::query()->create([
            'fuel_account_id' => $account->id,
            'organization_id' => $account->organization_id,
            'entry_type' => LedgerEntryType::Credit,
            'amount' => 10_000,
            'balance_after' => 10_000,
            'reference_type' => 'manual_credit',
        ]);
    }

    public function test_a_ledger_entry_cannot_be_updated(): void
    {
        $entry = $this->makeEntry();

        $this->expectException(QueryException::class);

        DB::table('ledger_entries')->where('id', $entry->id)->update(['amount' => 1]);
    }

    public function test_a_ledger_entry_cannot_be_deleted(): void
    {
        $entry = $this->makeEntry();

        $this->expectException(QueryException::class);

        DB::table('ledger_entries')->where('id', $entry->id)->delete();
    }

    public function test_amount_must_be_positive(): void
    {
        $account = FuelAccount::factory()->create();

        $this->expectException(QueryException::class);

        LedgerEntry::query()->create([
            'fuel_account_id' => $account->id,
            'organization_id' => $account->organization_id,
            'entry_type' => LedgerEntryType::Credit,
            'amount' => 0,
            'balance_after' => 0,
        ]);
    }
}

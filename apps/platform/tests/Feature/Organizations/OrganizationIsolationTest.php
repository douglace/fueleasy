<?php

declare(strict_types=1);

namespace Tests\Feature\Organizations;

use App\Application\Organizations\OrganizationCodeGenerator;
use App\Domain\Identity\Role;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrganizationIsolationTest extends TestCase
{
    use RefreshDatabase;

    public function test_organization_code_is_globally_unique(): void
    {
        Organization::factory()->create(['code' => 'ABC234']);

        $this->expectException(QueryException::class);

        Organization::factory()->create(['code' => 'ABC234']);
    }

    public function test_code_generator_produces_a_valid_unused_code(): void
    {
        $generator = app(OrganizationCodeGenerator::class);

        $code = $generator->generate();

        $this->assertSame(6, strlen($code->value));
        $this->assertFalse(Organization::query()->where('code', $code->value)->exists());
    }

    public function test_same_phone_can_exist_in_different_organizations(): void
    {
        $enterpriseA = Organization::factory()->enterprise()->create();
        $enterpriseB = Organization::factory()->enterprise()->create();

        User::factory()->driver($enterpriseA)->create(['phone' => '+237699112233', 'matricule' => null]);
        $second = User::factory()->driver($enterpriseB)->create(['phone' => '+237699112233', 'matricule' => null]);

        $this->assertDatabaseCount('users', 2);
        $this->assertSame($enterpriseB->id, $second->organization_id);
    }

    public function test_same_phone_cannot_be_duplicated_within_one_organization(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();

        User::factory()->driver($enterprise)->create(['phone' => '+237699112233', 'matricule' => null]);

        $this->expectException(QueryException::class);

        User::factory()->driver($enterprise)->create(['phone' => '+237699112233', 'matricule' => null]);
    }

    public function test_fusy_admin_has_no_organization_and_others_belong_to_one(): void
    {
        $fusyAdmin = User::factory()->fusyAdmin()->create();
        $enterprise = Organization::factory()->enterprise()->create();
        $enterpriseAdmin = User::factory()->enterpriseAdmin($enterprise)->create();

        $this->assertTrue($fusyAdmin->isFusyAdmin());
        $this->assertNull($fusyAdmin->organization_id);

        $this->assertFalse($enterpriseAdmin->isFusyAdmin());
        $this->assertTrue($enterpriseAdmin->belongsToOrganization($enterprise->id));
        $this->assertFalse($enterpriseAdmin->belongsToOrganization($enterprise->id + 999));
        $this->assertSame(Role::EnterpriseAdmin, $enterpriseAdmin->role);
    }
}

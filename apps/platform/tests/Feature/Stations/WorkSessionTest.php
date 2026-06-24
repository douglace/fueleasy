<?php

declare(strict_types=1);

namespace Tests\Feature\Stations;

use App\Application\Stations\CloseWorkSession;
use App\Application\Stations\OpenWorkSession;
use App\Domain\Shared\DomainException;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\User;
use App\Models\WorkSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WorkSessionTest extends TestCase
{
    use RefreshDatabase;

    public function test_pompiste_can_open_a_session_on_a_pump_of_their_station(): void
    {
        $station = Organization::factory()->station()->create();
        $pompiste = User::factory()->pompiste($station)->create();
        $pump = Pump::factory()->create(['organization_id' => $station->id]);

        $session = app(OpenWorkSession::class)->handle($pompiste, $pump);

        $this->assertTrue($session->isOpen());
        $this->assertSame($pump->id, $session->pump_id);
        $this->assertDatabaseHas('audit_logs', ['action' => 'work_session.opened']);
    }

    public function test_a_pompiste_cannot_open_two_sessions_at_once(): void
    {
        $station = Organization::factory()->station()->create();
        $pompiste = User::factory()->pompiste($station)->create();
        $pump = Pump::factory()->create(['organization_id' => $station->id]);

        app(OpenWorkSession::class)->handle($pompiste, $pump);

        $this->expectException(DomainException::class);
        app(OpenWorkSession::class)->handle($pompiste, $pump);
    }

    public function test_opening_on_another_stations_pump_is_rejected(): void
    {
        $station = Organization::factory()->station()->create();
        $other = Organization::factory()->station()->create();
        $pompiste = User::factory()->pompiste($station)->create();
        $foreignPump = Pump::factory()->create(['organization_id' => $other->id]);

        $this->expectException(DomainException::class);
        app(OpenWorkSession::class)->handle($pompiste, $foreignPump);
    }

    public function test_closing_a_session_allows_opening_a_new_one(): void
    {
        $station = Organization::factory()->station()->create();
        $pompiste = User::factory()->pompiste($station)->create();
        $pump = Pump::factory()->create(['organization_id' => $station->id]);

        $first = app(OpenWorkSession::class)->handle($pompiste, $pump);
        app(CloseWorkSession::class)->handle($first);

        $second = app(OpenWorkSession::class)->handle($pompiste, $pump);

        $this->assertTrue($second->isOpen());
        $this->assertSame(2, WorkSession::query()->where('user_id', $pompiste->id)->count());
    }

    public function test_inactive_pump_cannot_host_a_session(): void
    {
        $station = Organization::factory()->station()->create();
        $pompiste = User::factory()->pompiste($station)->create();
        $pump = Pump::factory()->inactive()->create(['organization_id' => $station->id]);

        $this->expectException(DomainException::class);
        app(OpenWorkSession::class)->handle($pompiste, $pump);
    }
}

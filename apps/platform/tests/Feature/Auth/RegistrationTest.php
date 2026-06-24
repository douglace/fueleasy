<?php

namespace Tests\Feature\Auth;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_registration_route_does_not_exist(): void
    {
        $this->assertFalse(
            app('router')->has('register'),
            'L’inscription publique doit être désactivée : les comptes sont créés par Fusy ou un admin d’organisation.',
        );
    }

    public function test_public_registration_endpoint_returns_not_found(): void
    {
        $this->get('/register')->assertNotFound();
        $this->post('/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ])->assertNotFound();

        $this->assertGuest();
    }
}

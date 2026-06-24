<?php

declare(strict_types=1);

namespace Tests\Unit\Domain;

use App\Domain\Organizations\OrganizationCode;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class OrganizationCodeTest extends TestCase
{
    public function test_a_valid_code_has_six_alphanumeric_uppercase_characters(): void
    {
        $code = new OrganizationCode('ABC234');

        $this->assertSame('ABC234', $code->value);
        $this->assertSame('ABC234', (string) $code);
    }

    public function test_it_rejects_codes_that_are_not_six_characters(): void
    {
        $this->expectException(InvalidArgumentException::class);

        new OrganizationCode('ABC23');
    }

    public function test_it_rejects_ambiguous_characters(): void
    {
        foreach (['ABC2O3', 'ABC2I3', 'ABC203', 'ABC213'] as $ambiguous) {
            $this->assertFalse(OrganizationCode::isValid($ambiguous), "{$ambiguous} doit être rejeté");
        }
    }

    public function test_it_rejects_lowercase(): void
    {
        $this->assertFalse(OrganizationCode::isValid('abc234'));
    }

    public function test_random_codes_are_always_valid_and_avoid_ambiguous_characters(): void
    {
        for ($i = 0; $i < 200; $i++) {
            $code = OrganizationCode::random();

            $this->assertTrue(OrganizationCode::isValid($code->value));
            $this->assertSame(6, strlen($code->value));
            $this->assertDoesNotMatchRegularExpression('/[O0I1]/', $code->value);
        }
    }
}

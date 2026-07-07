<?php

declare(strict_types=1);

namespace Tests\Unit\Domain;

use App\Domain\Stations\PumpCode;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class PumpCodeTest extends TestCase
{
    public function test_accepts_a_valid_six_char_code(): void
    {
        $code = new PumpCode('K7M2XQ');
        $this->assertSame('K7M2XQ', (string) $code);
    }

    public function test_rejects_wrong_length_and_ambiguous_characters(): void
    {
        $this->assertFalse(PumpCode::isValid('ABC'));
        $this->assertFalse(PumpCode::isValid('ABCDEFG'));
        // O, 0, I et 1 sont exclus de l'alphabet (ambigus à la saisie).
        $this->assertFalse(PumpCode::isValid('ABCDE0'));
        $this->assertFalse(PumpCode::isValid('ABCDEO'));
        $this->assertFalse(PumpCode::isValid('ABCDEI'));
        $this->assertFalse(PumpCode::isValid('ABCDE1'));
        $this->assertFalse(PumpCode::isValid('abcdef'));
    }

    public function test_constructor_throws_on_invalid_value(): void
    {
        $this->expectException(InvalidArgumentException::class);
        new PumpCode('bad');
    }

    public function test_random_codes_are_valid_and_use_the_safe_alphabet(): void
    {
        for ($i = 0; $i < 50; $i++) {
            $code = PumpCode::random();
            $this->assertTrue(PumpCode::isValid($code->value));
            $this->assertSame(
                strlen($code->value),
                strspn($code->value, PumpCode::ALPHABET),
            );
        }
    }
}

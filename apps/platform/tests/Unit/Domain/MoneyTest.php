<?php

declare(strict_types=1);

namespace Tests\Unit\Domain;

use App\Domain\Shared\Money;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class MoneyTest extends TestCase
{
    public function test_it_rejects_negative_amounts(): void
    {
        $this->expectException(InvalidArgumentException::class);

        new Money(-1);
    }

    public function test_it_adds_and_subtracts(): void
    {
        $a = Money::fromInt(10_000);
        $b = Money::fromInt(2_500);

        $this->assertSame(12_500, $a->plus($b)->amount);
        $this->assertSame(7_500, $a->minus($b)->amount);
    }

    public function test_comparisons(): void
    {
        $a = Money::fromInt(10_000);
        $b = Money::fromInt(2_500);

        $this->assertTrue($a->isGreaterThan($b));
        $this->assertTrue($a->isGreaterThanOrEqualTo($a));
        $this->assertTrue($b->isLessThan($a));
        $this->assertTrue(Money::zero()->isZero());
        $this->assertTrue($a->equals(Money::fromInt(10_000)));
    }
}

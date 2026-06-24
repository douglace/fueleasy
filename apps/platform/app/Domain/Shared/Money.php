<?php

declare(strict_types=1);

namespace App\Domain\Shared;

use InvalidArgumentException;

/**
 * Montant monétaire en FCFA (XAF), exprimé en unités entières.
 *
 * Le franc CFA n'a pas de sous-unité : tous les montants sont des entiers >= 0.
 * Cette valeur est immuable.
 */
final readonly class Money
{
    public function __construct(public int $amount)
    {
        if ($amount < 0) {
            throw new InvalidArgumentException('Un montant ne peut pas être négatif.');
        }
    }

    public static function fromInt(int $amount): self
    {
        return new self($amount);
    }

    public static function zero(): self
    {
        return new self(0);
    }

    public function plus(self $other): self
    {
        return new self($this->amount + $other->amount);
    }

    public function minus(self $other): self
    {
        return new self($this->amount - $other->amount);
    }

    public function isZero(): bool
    {
        return $this->amount === 0;
    }

    public function isGreaterThan(self $other): bool
    {
        return $this->amount > $other->amount;
    }

    public function isGreaterThanOrEqualTo(self $other): bool
    {
        return $this->amount >= $other->amount;
    }

    public function isLessThan(self $other): bool
    {
        return $this->amount < $other->amount;
    }

    public function equals(self $other): bool
    {
        return $this->amount === $other->amount;
    }
}

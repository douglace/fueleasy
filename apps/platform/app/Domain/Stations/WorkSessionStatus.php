<?php

declare(strict_types=1);

namespace App\Domain\Stations;

enum WorkSessionStatus: string
{
    case Open = 'open';
    case Closed = 'closed';

    public function isOpen(): bool
    {
        return $this === self::Open;
    }
}

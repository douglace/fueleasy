<?php

declare(strict_types=1);

namespace App\Domain\Demo;

enum DemoProvider: string
{
    case OrangeMoney = 'orange_money';
    case MtnMomo = 'mtn_momo';
    case Ussd = 'ussd';

    public function label(): string
    {
        return match ($this) {
            self::OrangeMoney => 'Orange Money',
            self::MtnMomo => 'MTN MoMo',
            self::Ussd => 'USSD',
        };
    }
}

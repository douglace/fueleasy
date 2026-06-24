<?php

declare(strict_types=1);

namespace App\Domain\Demo;

enum DemoRechargeStatus: string
{
    case Pending = 'pending';
    case Successful = 'successful';
    case Failed = 'failed';
}

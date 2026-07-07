<?php

declare(strict_types=1);

namespace App\Domain\Payments;

enum QrType: string
{
    case Dynamic = 'dynamic'; // QR pompiste (parcours principal)
    case Fixed = 'fixed';     // QR fixe pompe (secours)
    case Code = 'code';       // Code pompe saisi manuellement (secours)
}

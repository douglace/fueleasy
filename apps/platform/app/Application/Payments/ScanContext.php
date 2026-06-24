<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Domain\Payments\QrType;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\WorkSession;

/**
 * Contexte résolu d'un scan de QR (avant saisie du montant).
 */
final readonly class ScanContext
{
    public function __construct(
        public QrType $via,
        public Organization $station,
        public Pump $pump,
        public ?WorkSession $workSession = null,
        public ?int $pompisteId = null,
    ) {}
}

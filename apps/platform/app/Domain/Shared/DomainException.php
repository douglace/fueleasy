<?php

declare(strict_types=1);

namespace App\Domain\Shared;

use RuntimeException;

/**
 * Erreur de règle métier (invariant violé). Distincte des erreurs techniques.
 */
class DomainException extends RuntimeException {}

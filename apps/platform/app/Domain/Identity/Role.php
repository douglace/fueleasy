<?php

declare(strict_types=1);

namespace App\Domain\Identity;

enum Role: string
{
    case FusyAdmin = 'fusy_admin';
    case EnterpriseAdmin = 'enterprise_admin';
    case StationAdmin = 'station_admin';
    case Driver = 'driver';
    case Pompiste = 'pompiste';

    /**
     * Admin Fusy : opérations globales, sans organisation propre.
     */
    public function isFusyAdmin(): bool
    {
        return $this === self::FusyAdmin;
    }

    /**
     * Rôle d'administration web (dashboard Inertia).
     */
    public function isWebAdmin(): bool
    {
        return in_array($this, [self::FusyAdmin, self::EnterpriseAdmin, self::StationAdmin], true);
    }

    /**
     * Rôle utilisateur mobile (authentification par PIN).
     */
    public function isMobile(): bool
    {
        return in_array($this, [self::Driver, self::Pompiste], true);
    }

    /**
     * Le rôle requiert-il un rattachement à une organisation ?
     */
    public function requiresOrganization(): bool
    {
        return $this !== self::FusyAdmin;
    }

    public function label(): string
    {
        return match ($this) {
            self::FusyAdmin => 'Admin Fusy',
            self::EnterpriseAdmin => 'Admin entreprise',
            self::StationAdmin => 'Admin station',
            self::Driver => 'Chauffeur',
            self::Pompiste => 'Pompiste',
        };
    }
}

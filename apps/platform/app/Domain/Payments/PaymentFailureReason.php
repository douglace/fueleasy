<?php

declare(strict_types=1);

namespace App\Domain\Payments;

enum PaymentFailureReason: string
{
    case QrInvalid = 'qr_invalid';
    case QrExpired = 'qr_expired';
    case QrRevoked = 'qr_revoked';
    case PumpCodeUnknown = 'pump_code_unknown';
    case OrganizationInactive = 'organization_inactive';
    case DriverInactive = 'driver_inactive';
    case StationInactive = 'station_inactive';
    case PumpInactive = 'pump_inactive';
    case FuelUnavailable = 'fuel_unavailable';
    case StationNotAuthorized = 'station_not_authorized';
    case BudgetInsufficient = 'budget_insufficient';
    case BalanceInsufficient = 'balance_insufficient';
    case SessionExpired = 'session_expired';
    case NoBudget = 'no_budget';
    case NoFuelAccount = 'no_fuel_account';
    case InvalidPin = 'invalid_pin';
    case PinLocked = 'pin_locked';

    public function message(): string
    {
        return match ($this) {
            self::QrInvalid => 'QR invalide.',
            self::QrExpired => 'QR expiré.',
            self::QrRevoked => 'QR fixe désactivé.',
            self::PumpCodeUnknown => 'Code pompe inconnu.',
            self::OrganizationInactive => 'Entreprise inactive.',
            self::DriverInactive => 'Chauffeur inactif.',
            self::StationInactive => 'Station inactive.',
            self::PumpInactive => 'Pompe inactive.',
            self::FuelUnavailable => 'Carburant indisponible sur cette pompe.',
            self::StationNotAuthorized => 'Station non autorisée pour cette entreprise.',
            self::BudgetInsufficient => 'Budget chauffeur insuffisant.',
            self::BalanceInsufficient => 'Solde entreprise insuffisant.',
            self::SessionExpired => 'Session de paiement expirée.',
            self::NoBudget => 'Aucun budget attribué au chauffeur.',
            self::NoFuelAccount => 'Aucun compte carburant pour l’entreprise.',
            self::InvalidPin => 'PIN incorrect.',
            self::PinLocked => 'Compte temporairement bloqué.',
        };
    }
}

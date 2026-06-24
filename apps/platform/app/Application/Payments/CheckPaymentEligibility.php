<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Domain\Identity\Role;
use App\Domain\Payments\PaymentException;
use App\Domain\Payments\PaymentFailureReason;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Models\AuthorizedStation;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\User;

/**
 * Contrôles d'éligibilité d'un paiement. Exécutés une fois avant création de la
 * session, puis répétés sous verrou dans la transaction de débit.
 */
final class CheckPaymentEligibility
{
    /**
     * Contrôles indépendants des soldes (statuts, carburant, autorisation station).
     */
    public function assertContext(User $driver, ScanContext $context, FuelType $fuel): void
    {
        if ($driver->role !== Role::Driver) {
            throw new PaymentException(PaymentFailureReason::DriverInactive);
        }

        if (! $driver->isActive()) {
            throw new PaymentException(PaymentFailureReason::DriverInactive);
        }

        $enterprise = $driver->organization;
        if ($enterprise === null || ! $enterprise->isActive()) {
            throw new PaymentException(PaymentFailureReason::OrganizationInactive);
        }

        if (! $context->station->isActive()) {
            throw new PaymentException(PaymentFailureReason::StationInactive);
        }

        if (! $context->pump->isActive()) {
            throw new PaymentException(PaymentFailureReason::PumpInactive);
        }

        if (! $context->pump->offersFuel($fuel)) {
            throw new PaymentException(PaymentFailureReason::FuelUnavailable);
        }

        if (! AuthorizedStation::isAuthorized($enterprise->id, $context->station->id)) {
            throw new PaymentException(PaymentFailureReason::StationNotAuthorized);
        }
    }

    /**
     * Contrôles de fonds : budget chauffeur et solde réel entreprise.
     */
    public function assertFunds(?FuelAccount $account, ?DriverBudget $budget, Money $amount): void
    {
        if ($account === null) {
            throw new PaymentException(PaymentFailureReason::NoFuelAccount);
        }

        if ($budget === null) {
            throw new PaymentException(PaymentFailureReason::NoBudget);
        }

        if ($budget->balanceMoney()->isLessThan($amount)) {
            throw new PaymentException(PaymentFailureReason::BudgetInsufficient);
        }

        if ($account->balanceMoney()->isLessThan($amount)) {
            throw new PaymentException(PaymentFailureReason::BalanceInsufficient);
        }
    }
}

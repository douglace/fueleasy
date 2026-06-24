<?php

use App\Jobs\ExpireStalePayments;
use App\Jobs\GenerateWeeklySettlements;
use App\Jobs\ResetDueDriverBudgets;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Expire les sessions de paiement en attente non finalisées sous 5 min.
Schedule::job(new ExpireStalePayments)->everyMinute();

// Réinitialise les budgets périodiques arrivés à échéance.
Schedule::job(new ResetDueDriverBudgets)->hourly();

// Génère les lots hebdomadaires de reversement (lundi matin).
Schedule::job(new GenerateWeeklySettlements)->weeklyOn(1, '02:00');

<?php

declare(strict_types=1);

namespace App\Support;

use App\Domain\Stations\FuelType;
use App\Models\Payment;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Carbon;

/**
 * Agrégats pour les graphiques des tableaux de bord (Recharts).
 * Regroupement effectué en PHP pour rester indépendant du SGBD.
 */
class DashboardCharts
{
    private const DAYS = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];

    /**
     * Volume des paiements (somme des montants) sur les 7 derniers jours.
     *
     * @param  Builder<Payment>  $paid  requête de paiements déjà filtrée (statut payé + périmètre)
     * @return list<array{l: string, v: int}>
     */
    public static function volume(Builder $paid, string $dateColumn = 'created_at'): array
    {
        $since = Carbon::now()->subDays(6)->startOfDay();

        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $d = Carbon::now()->subDays($i);
            $days[$d->format('Y-m-d')] = ['l' => self::DAYS[(int) $d->format('w')], 'v' => 0];
        }

        $rows = (clone $paid)->whereNotNull($dateColumn)
            ->where($dateColumn, '>=', $since)->get([$dateColumn, 'amount']);

        foreach ($rows as $row) {
            $key = Carbon::parse($row->{$dateColumn})->format('Y-m-d');
            if (isset($days[$key])) {
                $days[$key]['v'] += (int) $row->amount;
            }
        }

        return array_values($days);
    }

    /**
     * Répartition du volume par type de carburant.
     *
     * @param  Builder<Payment>  $paid
     * @return list<array{name: string, value: int, fuel: string}>
     */
    public static function fuelMix(Builder $paid): array
    {
        $sum = [];
        foreach ((clone $paid)->get(['fuel_type', 'amount']) as $row) {
            $fuel = $row->fuel_type->value;
            $sum[$fuel] = ($sum[$fuel] ?? 0) + (int) $row->amount;
        }

        $out = [];
        foreach ($sum as $fuel => $value) {
            $out[] = [
                'name' => FuelType::from($fuel)->label(),
                'value' => $value,
                'fuel' => $fuel,
            ];
        }

        return $out;
    }
}

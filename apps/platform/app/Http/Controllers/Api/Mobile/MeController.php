<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Mobile;

use App\Application\Identity\PinVerifier;
use App\Domain\Identity\Role;
use App\Http\Controllers\Controller;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class MeController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $payload = [
            'id' => $user->id,
            'name' => $user->name,
            'role' => $user->role->value,
            'organization_id' => $user->organization_id,
        ];

        if ($user->role === Role::Driver) {
            $budget = $this->budget($user);
            $payload['budget'] = $budget === null ? null : [
                'mode' => $budget->mode->value,
                'next_reset_at' => $budget->next_reset_at?->toIso8601String(),
                'masked' => true, // le solde n'est révélé qu'après saisie du PIN
            ];
            $payload['enterprise_status'] = $this->enterpriseStatus($user);
        }

        return response()->json($payload);
    }

    /**
     * Révèle le solde du budget après vérification du PIN (affichage 15 s côté app).
     */
    public function revealBudget(Request $request, PinVerifier $pinVerifier): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === Role::Driver, Response::HTTP_FORBIDDEN);

        $data = $request->validate(['pin' => ['required', 'string']]);

        if (! $pinVerifier->verify($user, $data['pin'])->isOk()) {
            return response()->json(['message' => 'PIN incorrect.'], 422);
        }

        $budget = $this->budget($user);
        if ($budget === null) {
            return response()->json(['balance' => null]);
        }

        return response()->json([
            'balance' => $budget->balance,
            'amount' => $budget->amount,
            'reveal_seconds' => 15,
        ]);
    }

    private function budget(User $user): ?DriverBudget
    {
        return DriverBudget::query()->where('user_id', $user->id)->first();
    }

    private function enterpriseStatus(User $user): string
    {
        $account = FuelAccount::query()->where('organization_id', $user->organization_id)->first();

        return ($account !== null && $account->balance > 0) ? 'operational' : 'recharge_needed';
    }
}

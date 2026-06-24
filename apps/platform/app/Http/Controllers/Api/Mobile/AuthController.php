<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Mobile;

use App\Application\Identity\ActivateAccount;
use App\Application\Identity\DeviceChange;
use App\Application\Identity\MobileLogin;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function activate(Request $request, ActivateAccount $activate): JsonResponse
    {
        $data = $request->validate([
            'organization_code' => ['required', 'string'],
            'identifier' => ['required', 'string'],
            'temporary_pin' => ['required', 'string'],
            'new_pin' => ['required', 'string', 'regex:/^\d{4}$/'],
            'device_id' => ['required', 'string'],
            'device_name' => ['nullable', 'string'],
        ]);

        $result = $activate->handle(
            $data['organization_code'],
            $data['identifier'],
            $data['temporary_pin'],
            $data['new_pin'],
            $data['device_id'],
            $data['device_name'] ?? null,
        );

        return $this->session($result['user'], $result['token'], 201);
    }

    public function login(Request $request, MobileLogin $login): JsonResponse
    {
        $data = $request->validate([
            'organization_code' => ['required', 'string'],
            'identifier' => ['required', 'string'],
            'pin' => ['required', 'string'],
            'device_id' => ['required', 'string'],
        ]);

        $result = $login->handle($data['organization_code'], $data['identifier'], $data['pin'], $data['device_id']);

        return $this->session($result['user'], $result['token']);
    }

    public function requestDeviceChange(Request $request, DeviceChange $deviceChange): JsonResponse
    {
        $data = $request->validate([
            'organization_code' => ['required', 'string'],
            'identifier' => ['required', 'string'],
            'pin' => ['required', 'string'],
            'device_id' => ['required', 'string'],
        ]);

        $deviceChange->request($data['organization_code'], $data['identifier'], $data['pin'], $data['device_id']);

        return response()->json(['message' => 'Code SMS envoyé.']);
    }

    public function confirmDeviceChange(Request $request, DeviceChange $deviceChange): JsonResponse
    {
        $data = $request->validate([
            'organization_code' => ['required', 'string'],
            'identifier' => ['required', 'string'],
            'sms_code' => ['required', 'string'],
            'device_id' => ['required', 'string'],
        ]);

        $result = $deviceChange->confirm($data['organization_code'], $data['identifier'], $data['sms_code'], $data['device_id']);

        return $this->session($result['user'], $result['token']);
    }

    private function session(User $user, string $token, int $status = 200): JsonResponse
    {
        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'role' => $user->role->value,
                'organization_id' => $user->organization_id,
            ],
        ], $status);
    }
}

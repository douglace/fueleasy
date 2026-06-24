<?php

declare(strict_types=1);

namespace App\Application\Notifications;

use App\Models\SmsMessage;

/**
 * Envoi de SMS simulé : les messages sont persistés dans une outbox (table
 * sms_messages) plutôt qu'envoyés à un opérateur réel. Sert aux confirmations
 * d'activation/changement d'appareil et aux alertes pompiste de secours.
 */
final class SmsSender
{
    /**
     * @param  array<string, mixed>  $payload
     */
    public function send(
        string $to,
        string $purpose,
        string $body,
        ?int $organizationId = null,
        ?int $userId = null,
        array $payload = [],
    ): SmsMessage {
        return SmsMessage::query()->create([
            'organization_id' => $organizationId,
            'user_id' => $userId,
            'to' => $to,
            'purpose' => $purpose,
            'body' => $body,
            'payload' => $payload === [] ? null : $payload,
        ]);
    }
}

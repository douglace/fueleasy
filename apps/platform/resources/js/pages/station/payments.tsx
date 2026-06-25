import { router } from '@inertiajs/react';
import { useState } from 'react';
import { Card, num, Page, Table } from '@/components/fusy';

interface PaymentRow {
    id: number;
    reference: string;
    short_code: string;
    amount: number;
    status: string;
    enterprise: string;
    fuel_type: string;
    confirmed_at: string | null;
}

export default function StationPayments({
    payments,
}: {
    payments: PaymentRow[];
}) {
    const [reasons, setReasons] = useState<Record<number, string>>({});

    return (
        <Page title="Paiements">
            <Card title={`${payments.length} paiement(s)`}>
                <Table
                    head={[
                        'Code',
                        'Entreprise',
                        'Carburant',
                        'Montant',
                        'Statut',
                        'Remboursement',
                    ]}
                >
                    {payments.map((p) => (
                        <tr key={p.id} className="border-t border-border">
                            <td className="p-2 font-mono">{p.short_code}</td>
                            <td className="p-2">{p.enterprise}</td>
                            <td className="p-2">{p.fuel_type}</td>
                            <td className="p-2">{num(p.amount)}</td>
                            <td className="p-2">{p.status}</td>
                            <td className="p-2">
                                {p.status === 'paid' && (
                                    <span className="flex items-center gap-1">
                                        <input
                                            className="w-28 rounded border border-border bg-background p-1 text-xs"
                                            placeholder="Motif"
                                            value={reasons[p.id] ?? ''}
                                            onChange={(e) =>
                                                setReasons({
                                                    ...reasons,
                                                    [p.id]: e.target.value,
                                                })
                                            }
                                        />
                                        <button
                                            onClick={() =>
                                                router.post(
                                                    `/station/payments/${p.id}/refund`,
                                                    {
                                                        reason:
                                                            reasons[p.id] ?? '',
                                                    },
                                                    { preserveScroll: true },
                                                )
                                            }
                                            className="text-red-600 underline"
                                        >
                                            Rembourser
                                        </button>
                                    </span>
                                )}
                            </td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

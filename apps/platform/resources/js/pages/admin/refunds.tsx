import { router } from '@inertiajs/react';
import { Card, num, Page, Table } from '@/components/fusy';

interface Refund {
    id: number;
    status: string;
    reason: string | null;
    payment_reference: string;
    amount: number;
    station: string;
}

interface Props {
    refunds: Refund[];
    pendingRefunds: number;
}

export default function AdminRefunds({ refunds, pendingRefunds }: Props) {
    const post = (url: string) =>
        router.post(url, {}, { preserveScroll: true });

    return (
        <Page title="Remboursements">
            <Card title={`${pendingRefunds} demande(s) en attente`}>
                <Table
                    head={[
                        'Paiement',
                        'Station',
                        'Montant',
                        'Motif',
                        'Statut',
                        'Action',
                    ]}
                >
                    {refunds.map((r) => (
                        <tr key={r.id} className="border-t border-border">
                            <td className="p-2 font-mono">
                                {r.payment_reference}
                            </td>
                            <td className="p-2">{r.station}</td>
                            <td className="p-2">{num(r.amount)}</td>
                            <td className="p-2">{r.reason ?? '—'}</td>
                            <td className="p-2">{r.status}</td>
                            <td className="p-2">
                                {r.status === 'pending' && (
                                    <span className="flex gap-2">
                                        <button
                                            onClick={() =>
                                                post(
                                                    `/admin/refunds/${r.id}/approve`,
                                                )
                                            }
                                            className="text-green-600 underline"
                                        >
                                            Approuver
                                        </button>
                                        <button
                                            onClick={() =>
                                                post(
                                                    `/admin/refunds/${r.id}/reject`,
                                                )
                                            }
                                            className="text-red-600 underline"
                                        >
                                            Refuser
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

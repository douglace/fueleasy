import { router } from '@inertiajs/react';
import { Card, num, Page, Table } from '@/components/fusy';

interface Batch {
    id: number;
    reference: string;
    station: string;
    gross_sales: number;
    refunds_deducted: number;
    net_amount: number;
    status: string;
    paid_at: string | null;
}

export default function AdminSettlements({ batches }: { batches: Batch[] }) {
    return (
        <Page title="Reversements">
            <Card
                title="Lots de reversement"
                actions={
                    <button
                        onClick={() =>
                            router.post(
                                '/admin/settlements/generate',
                                {},
                                { preserveScroll: true },
                            )
                        }
                        className="rounded bg-primary px-3 py-1.5 text-sm text-primary-foreground"
                    >
                        Générer les lots hebdomadaires
                    </button>
                }
            >
                <Table
                    head={[
                        'Référence',
                        'Station',
                        'Ventes',
                        'Remb. déduits',
                        'Net',
                        'Statut',
                        'Action',
                    ]}
                >
                    {batches.map((b) => (
                        <tr key={b.id} className="border-t border-border">
                            <td className="p-2 font-mono">{b.reference}</td>
                            <td className="p-2">{b.station}</td>
                            <td className="p-2">{num(b.gross_sales)}</td>
                            <td className="p-2">{num(b.refunds_deducted)}</td>
                            <td className="p-2 font-medium">
                                {num(b.net_amount)}
                            </td>
                            <td className="p-2">
                                {b.status}
                                {b.paid_at ? ` (${b.paid_at})` : ''}
                            </td>
                            <td className="p-2">
                                {b.status === 'open' && (
                                    <button
                                        onClick={() =>
                                            router.post(
                                                `/admin/settlements/${b.id}/paid`,
                                                {},
                                                { preserveScroll: true },
                                            )
                                        }
                                        className="text-primary underline"
                                    >
                                        Marquer payé
                                    </button>
                                )}
                            </td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

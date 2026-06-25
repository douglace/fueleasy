import { Card, fcfa, num, Page, Stat, Table } from '@/components/fusy';

interface Batch {
    id: number;
    reference: string;
    gross_sales: number;
    refunds_deducted: number;
    net_amount: number;
    status: string;
    paid_at: string | null;
}

interface Props {
    summary: { today_sales: number; pending_amount: number };
    batches: Batch[];
}

export default function StationSettlements({ summary, batches }: Props) {
    return (
        <Page title="Reversements">
            <div className="grid gap-4 md:grid-cols-2">
                <Stat
                    label="Ventes Fusy du jour"
                    value={fcfa(summary.today_sales)}
                />
                <Stat
                    label="En attente de reversement"
                    value={fcfa(summary.pending_amount)}
                />
            </div>

            <Card title="Lots de reversement">
                <p className="mb-3 text-sm text-muted-foreground">
                    Les lots sont générés par Fusy et marqués payés après
                    reversement réel hors plateforme.
                </p>
                <Table
                    head={[
                        'Référence',
                        'Ventes',
                        'Remb. déduits',
                        'Net',
                        'Statut',
                    ]}
                    empty="Aucun lot pour le moment."
                >
                    {batches.map((b) => (
                        <tr key={b.id} className="border-t border-border">
                            <td className="p-2 font-mono">{b.reference}</td>
                            <td className="p-2">{num(b.gross_sales)}</td>
                            <td className="p-2">{num(b.refunds_deducted)}</td>
                            <td className="p-2 font-medium">
                                {num(b.net_amount)}
                            </td>
                            <td className="p-2">
                                {b.status}
                                {b.paid_at ? ` (${b.paid_at})` : ''}
                            </td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

import { Card, fcfa, num, Page, Stat, Table } from '@/components/fusy';

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

interface Props {
    stats: {
        todaySales: number;
        pendingAmount: number;
        pumps: number;
        pompistes: number;
    };
    recentPayments: PaymentRow[];
}

export default function StationDashboard({ stats, recentPayments }: Props) {
    return (
        <Page title="Tableau de bord — Station">
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Stat
                    label="Ventes Fusy du jour"
                    value={fcfa(stats.todaySales)}
                />
                <Stat
                    label="En attente de reversement"
                    value={fcfa(stats.pendingAmount)}
                />
                <Stat label="Pompes" value={num(stats.pumps)} />
                <Stat label="Pompistes" value={num(stats.pompistes)} />
            </div>

            <Card title="Derniers paiements réglés">
                <Table
                    head={[
                        'Code',
                        'Entreprise',
                        'Carburant',
                        'Montant',
                        'Date',
                    ]}
                >
                    {recentPayments.map((p) => (
                        <tr key={p.id} className="border-t border-border">
                            <td className="p-2 font-mono">{p.short_code}</td>
                            <td className="p-2">{p.enterprise}</td>
                            <td className="p-2">{p.fuel_type}</td>
                            <td className="p-2">{num(p.amount)}</td>
                            <td className="p-2">{p.confirmed_at}</td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

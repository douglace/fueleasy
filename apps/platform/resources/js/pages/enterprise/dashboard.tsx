import { Card, fcfa, num, Page, Stat, Table } from '@/components/fusy';

interface Transaction {
    id: number;
    reference: string;
    amount: number;
    status: string;
    fuel_type: string;
    station: string;
    created_at: string | null;
}

interface Props {
    balance: number;
    stats: {
        drivers: number;
        authorizedStations: number;
        paidPayments: number;
        spentTotal: number;
    };
    recentTransactions: Transaction[];
}

export default function EnterpriseDashboard({
    balance,
    stats,
    recentTransactions,
}: Props) {
    return (
        <Page title="Tableau de bord — Entreprise">
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Stat label="Solde carburant" value={fcfa(balance)} />
                <Stat label="Chauffeurs" value={num(stats.drivers)} />
                <Stat
                    label="Stations autorisées"
                    value={num(stats.authorizedStations)}
                />
                <Stat label="Total dépensé" value={fcfa(stats.spentTotal)} />
            </div>

            <Card title="Dernières transactions">
                <Table
                    head={[
                        'Référence',
                        'Station',
                        'Carburant',
                        'Montant',
                        'Statut',
                    ]}
                >
                    {recentTransactions.map((t) => (
                        <tr key={t.id} className="border-t border-border">
                            <td className="p-2 font-mono">{t.reference}</td>
                            <td className="p-2">{t.station}</td>
                            <td className="p-2">{t.fuel_type}</td>
                            <td className="p-2">{num(t.amount)}</td>
                            <td className="p-2">{t.status}</td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

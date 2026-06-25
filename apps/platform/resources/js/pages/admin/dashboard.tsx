import { Card, fcfa, num, Page, Stat, Table } from '@/components/fusy';

interface PaymentRow {
    id: number;
    reference: string;
    amount: number;
    status: string;
    station: string;
    enterprise: string;
    created_at: string | null;
}

interface AuditRow {
    id: number;
    action: string;
    created_at: string | null;
}

interface Props {
    stats: {
        enterprises: number;
        stations: number;
        paidPayments: number;
        pendingRefunds: number;
        totalBalance: number;
    };
    recentPayments: PaymentRow[];
    audit: AuditRow[];
}

export default function AdminDashboard({
    stats,
    recentPayments,
    audit,
}: Props) {
    return (
        <Page title="Tableau de bord — Admin Fusy">
            <div className="grid gap-4 md:grid-cols-3 lg:grid-cols-5">
                <Stat label="Entreprises" value={num(stats.enterprises)} />
                <Stat label="Stations" value={num(stats.stations)} />
                <Stat
                    label="Paiements réglés"
                    value={num(stats.paidPayments)}
                />
                <Stat
                    label="Remb. en attente"
                    value={num(stats.pendingRefunds)}
                />
                <Stat
                    label="Soldes carburant"
                    value={fcfa(stats.totalBalance)}
                />
            </div>

            <Card title="Transactions récentes">
                <Table
                    head={[
                        'Référence',
                        'Entreprise',
                        'Station',
                        'Montant',
                        'Statut',
                    ]}
                >
                    {recentPayments.map((p) => (
                        <tr key={p.id} className="border-t border-border">
                            <td className="p-2 font-mono">{p.reference}</td>
                            <td className="p-2">{p.enterprise}</td>
                            <td className="p-2">{p.station}</td>
                            <td className="p-2">{num(p.amount)}</td>
                            <td className="p-2">{p.status}</td>
                        </tr>
                    ))}
                </Table>
            </Card>

            <Card title="Activité récente (audit)">
                <ul className="text-sm">
                    {audit.map((a) => (
                        <li key={a.id} className="border-t border-border py-1">
                            <span className="text-muted-foreground">
                                {a.created_at}
                            </span>{' '}
                            — {a.action}
                        </li>
                    ))}
                </ul>
            </Card>
        </Page>
    );
}

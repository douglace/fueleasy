import { Card, num, Page, Table } from '@/components/fusy';

interface Transaction {
    id: number;
    reference: string;
    amount: number;
    status: string;
    fuel_type: string;
    station: string;
    created_at: string | null;
}

export default function EnterpriseTransactions({
    transactions,
}: {
    transactions: Transaction[];
}) {
    return (
        <Page title="Transactions">
            <Card
                title={`${transactions.length} transaction(s)`}
                actions={
                    <a
                        href="/enterprise/export/transactions"
                        className="rounded border border-border px-3 py-1.5 text-sm"
                    >
                        Export CSV
                    </a>
                }
            >
                <Table
                    head={[
                        'Référence',
                        'Station',
                        'Carburant',
                        'Montant',
                        'Statut',
                        'Date',
                    ]}
                >
                    {transactions.map((t) => (
                        <tr key={t.id} className="border-t border-border">
                            <td className="p-2 font-mono">{t.reference}</td>
                            <td className="p-2">{t.station}</td>
                            <td className="p-2">{t.fuel_type}</td>
                            <td className="p-2">{num(t.amount)}</td>
                            <td className="p-2">{t.status}</td>
                            <td className="p-2">{t.created_at}</td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

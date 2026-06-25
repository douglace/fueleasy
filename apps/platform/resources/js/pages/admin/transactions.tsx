import { Card, num, Page, Table } from '@/components/fusy';

interface PaymentRow {
    id: number;
    reference: string;
    short_code: string;
    amount: number;
    status: string;
    fuel_type: string;
    station: string;
    enterprise: string;
    created_at: string | null;
}

export default function AdminTransactions({
    payments,
}: {
    payments: PaymentRow[];
}) {
    return (
        <Page title="Transactions">
            <Card title={`${payments.length} transaction(s)`}>
                <Table
                    head={[
                        'Référence',
                        'Code',
                        'Entreprise',
                        'Station',
                        'Carburant',
                        'Montant',
                        'Statut',
                        'Date',
                    ]}
                >
                    {payments.map((p) => (
                        <tr key={p.id} className="border-t border-border">
                            <td className="p-2 font-mono">{p.reference}</td>
                            <td className="p-2 font-mono">{p.short_code}</td>
                            <td className="p-2">{p.enterprise}</td>
                            <td className="p-2">{p.station}</td>
                            <td className="p-2">{p.fuel_type}</td>
                            <td className="p-2">{num(p.amount)}</td>
                            <td className="p-2">{p.status}</td>
                            <td className="p-2">{p.created_at}</td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

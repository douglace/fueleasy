import { useMemo, useState } from 'react';
import {
    Badge,
    Btn,
    Chip,
    FUEL,
    num,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Table,
} from '@/components/fusy';

interface Transaction {
    id: number;
    reference: string;
    amount: number;
    status: string;
    fuel_type: string;
    station: string;
    created_at: string | null;
}

type StatusFilter = 'all' | 'paid' | 'pending' | 'failed' | 'expired';

const STATUS_OPTIONS: { value: StatusFilter; label: string }[] = [
    { value: 'all', label: 'Tous' },
    { value: 'paid', label: 'Payés' },
    { value: 'pending', label: 'En attente' },
    { value: 'failed', label: 'Échecs' },
    { value: 'expired', label: 'Expirés' },
];

export default function EnterpriseTransactions({
    transactions,
}: {
    transactions: Transaction[];
}) {
    const [status, setStatus] = useState<StatusFilter>('all');
    const [search, setSearch] = useState('');

    const filtered = useMemo(() => {
        const q = search.trim().toLowerCase();

        return transactions.filter((t) => {
            if (status !== 'all' && t.status !== status) {
                return false;
            }

            if (q && !`${t.reference} ${t.station}`.toLowerCase().includes(q)) {
                return false;
            }

            return true;
        });
    }, [transactions, status, search]);

    return (
        <Page title="Transactions">
            <PageHead
                title="Transactions"
                sub="Historique des paiements carburant de vos chauffeurs."
                actions={
                    <Btn
                        variant="ghost"
                        icon="download"
                        onClick={() =>
                            (window.location.href =
                                '/enterprise/export/transactions')
                        }
                    >
                        Export CSV
                    </Btn>
                }
            />

            <div className="stack">
                <section className="card">
                    <div className="filters">
                        <Seg
                            value={status}
                            onChange={setStatus}
                            options={STATUS_OPTIONS}
                        />
                        <div className="ml-auto">
                            <SearchMini
                                value={search}
                                onChange={setSearch}
                                placeholder="Référence, station…"
                            />
                        </div>
                        <Chip>
                            <b>{filtered.length}</b>&nbsp;résultats
                        </Chip>
                    </div>
                    <Table
                        head={[
                            'Référence',
                            'Station',
                            'Carburant',
                            { label: 'Montant', num: true },
                            'Statut',
                            'Date',
                        ]}
                        empty="Aucune transaction ne correspond à ce filtre."
                    >
                        {filtered.map((t) => (
                            <tr key={t.id}>
                                <td className="ref">{t.reference}</td>
                                <td>{t.station}</td>
                                <td>
                                    <Chip icon="drop">
                                        {FUEL[t.fuel_type] ?? t.fuel_type}
                                    </Chip>
                                </td>
                                <td className="num t-amount">
                                    {num(t.amount)}
                                </td>
                                <td>
                                    <Badge domain="payment" value={t.status} />
                                </td>
                                <td className="tnum sub">
                                    {t.created_at ?? '—'}
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

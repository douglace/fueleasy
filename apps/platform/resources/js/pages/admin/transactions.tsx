import { useMemo, useState } from 'react';
import {
    Badge,
    Chip,
    FUEL,
    fcfa,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Table,
} from '@/components/fusy';

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

type StatusFilter =
    | 'all'
    | 'paid'
    | 'pending'
    | 'failed'
    | 'refunded'
    | 'expired';

export default function AdminTransactions({
    payments,
}: {
    payments: PaymentRow[];
}) {
    const [filter, setFilter] = useState<StatusFilter>('all');
    const [q, setQ] = useState('');

    const rows = useMemo(() => {
        const needle = q.trim().toLowerCase();

        return payments.filter((p) => {
            if (filter !== 'all' && p.status !== filter) {
                return false;
            }

            if (!needle) {
                return true;
            }

            return `${p.reference} ${p.short_code} ${p.enterprise} ${p.station}`
                .toLowerCase()
                .includes(needle);
        });
    }, [payments, filter, q]);

    return (
        <Page title="Transactions">
            <PageHead
                title="Transactions"
                sub="Tous les paiements à la pompe, tous espaces confondus."
            />

            <div className="stack">
                <section className="card">
                    <div className="card-h">
                        <h3>Paiements</h3>
                        <div className="actions">
                            <Seg
                                value={filter}
                                onChange={setFilter}
                                options={[
                                    { value: 'all', label: 'Tous' },
                                    { value: 'paid', label: 'Payés' },
                                    { value: 'pending', label: 'En attente' },
                                    { value: 'failed', label: 'Échecs' },
                                    { value: 'refunded', label: 'Remboursés' },
                                    { value: 'expired', label: 'Expirés' },
                                ]}
                            />
                            <SearchMini
                                value={q}
                                onChange={setQ}
                                placeholder="Référence, code, entreprise…"
                            />
                            <Chip>
                                <b>{rows.length}</b>&nbsp;résultats
                            </Chip>
                        </div>
                    </div>
                    <Table
                        head={[
                            'Référence',
                            'Code',
                            'Entreprise',
                            'Station',
                            'Carburant',
                            { label: 'Montant', num: true },
                            'Statut',
                            'Date',
                        ]}
                        empty="Aucune transaction ne correspond à ce filtre."
                    >
                        {rows.map((p) => (
                            <tr key={p.id}>
                                <td className="ref">{p.reference}</td>
                                <td>
                                    <span className="mono font-bold">
                                        {p.short_code}
                                    </span>
                                </td>
                                <td className="strong">{p.enterprise}</td>
                                <td>{p.station}</td>
                                <td>
                                    <Chip icon="drop">
                                        {FUEL[p.fuel_type] ?? p.fuel_type}
                                    </Chip>
                                </td>
                                <td className="num t-amount">
                                    {fcfa(p.amount)}
                                </td>
                                <td>
                                    <Badge domain="payment" value={p.status} />
                                </td>
                                <td className="tnum sub">
                                    {p.created_at ?? '—'}
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

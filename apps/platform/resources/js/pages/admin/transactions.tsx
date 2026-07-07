import { router } from '@inertiajs/react';
import { useState } from 'react';
import {
    Badge,
    Chip,
    FUEL,
    fcfa,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Select,
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

interface OrgRef {
    id: number;
    name: string;
}

interface Filters {
    status: string | null;
    enterprise_id: number | null;
    station_id: number | null;
    q: string | null;
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
    filters,
    enterprises,
    stations,
}: {
    payments: PaymentRow[];
    filters: Filters;
    enterprises: OrgRef[];
    stations: OrgRef[];
}) {
    const [q, setQ] = useState(filters.q ?? '');

    // Filtres appliqués côté serveur (sur toute la base, pas seulement les
    // 200 lignes affichées) : chaque changement recharge la page Inertia.
    const apply = (next: Partial<Filters>) => {
        const merged = { ...filters, q: q.trim() || null, ...next };
        router.get(
            '/admin/transactions',
            Object.fromEntries(
                Object.entries(merged).filter(([, v]) => v != null && v !== ''),
            ),
            { preserveState: true, preserveScroll: true },
        );
    };

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
                                value={
                                    (filters.status ?? 'all') as StatusFilter
                                }
                                onChange={(v) =>
                                    apply({ status: v === 'all' ? null : v })
                                }
                                options={[
                                    { value: 'all', label: 'Tous' },
                                    { value: 'paid', label: 'Payés' },
                                    { value: 'pending', label: 'En attente' },
                                    { value: 'failed', label: 'Échecs' },
                                    { value: 'refunded', label: 'Remboursés' },
                                    { value: 'expired', label: 'Expirés' },
                                ]}
                            />
                            <Select
                                value={filters.enterprise_id ?? ''}
                                onChange={(e) =>
                                    apply({
                                        enterprise_id: e.target.value
                                            ? Number(e.target.value)
                                            : null,
                                    })
                                }
                            >
                                <option value="">Toutes les entreprises</option>
                                {enterprises.map((o) => (
                                    <option key={o.id} value={o.id}>
                                        {o.name}
                                    </option>
                                ))}
                            </Select>
                            <Select
                                value={filters.station_id ?? ''}
                                onChange={(e) =>
                                    apply({
                                        station_id: e.target.value
                                            ? Number(e.target.value)
                                            : null,
                                    })
                                }
                            >
                                <option value="">Toutes les stations</option>
                                {stations.map((o) => (
                                    <option key={o.id} value={o.id}>
                                        {o.name}
                                    </option>
                                ))}
                            </Select>
                            <form
                                onSubmit={(e) => {
                                    e.preventDefault();
                                    apply({});
                                }}
                            >
                                <SearchMini
                                    value={q}
                                    onChange={setQ}
                                    placeholder="Référence, code court…"
                                />
                            </form>
                            <Chip>
                                <b>{payments.length}</b>&nbsp;résultats
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
                        {payments.map((p) => (
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

import { router } from '@inertiajs/react';
import { useState } from 'react';
import {
    Badge,
    fcfa,
    Kpi,
    num,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Table,
} from '@/components/fusy';
import { ConfirmButton } from '@/components/overlays';

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

type BatchFilter = 'all' | 'open' | 'paid';

export default function AdminSettlements({ batches }: { batches: Batch[] }) {
    const [filter, setFilter] = useState<BatchFilter>('all');
    const [q, setQ] = useState('');

    const openBatches = batches.filter((b) => b.status === 'open');
    const openSum = openBatches.reduce((a, b) => a + b.net_amount, 0);
    const paidSum = batches
        .filter((b) => b.status === 'paid')
        .reduce((a, b) => a + b.net_amount, 0);

    const needle = q.trim().toLowerCase();
    const rows = batches.filter((b) => {
        if (filter !== 'all' && b.status !== filter) {
            return false;
        }

        if (!needle) {
            return true;
        }

        return `${b.reference} ${b.station}`.toLowerCase().includes(needle);
    });

    return (
        <Page title="Reversements">
            <PageHead
                title="Reversements"
                sub="Générez les lots hebdomadaires puis marquez chaque lot payé une fois le virement émis vers la station."
                actions={
                    <ConfirmButton
                        icon="refund"
                        title="Générer les lots de la semaine ?"
                        description="Un lot sera créé par station à partir des paiements réglés non encore reversés."
                        confirmLabel="Générer"
                        onConfirm={() =>
                            router.post(
                                '/admin/settlements/generate',
                                {},
                                { preserveScroll: true },
                            )
                        }
                    >
                        Générer les lots
                    </ConfirmButton>
                }
            />

            <div className="stack">
                <div className="cols-3 grid">
                    <Kpi
                        icon="banknote"
                        label="Lots ouverts"
                        value={num(openBatches.length)}
                        foot="à reverser"
                    />
                    <Kpi
                        icon="wallet"
                        variant="hero"
                        label="Net à reverser"
                        value={num(openSum)}
                        unit="FCFA"
                        foot="total des lots ouverts"
                    />
                    <Kpi
                        icon="check"
                        variant="accent-green"
                        label="Déjà reversé"
                        value={num(paidSum)}
                        unit="FCFA"
                        foot="lots marqués payés"
                    />
                </div>

                <section className="card">
                    <div className="card-h">
                        <h3>Lots de reversement</h3>
                        <div className="actions">
                            <Seg
                                value={filter}
                                onChange={setFilter}
                                options={[
                                    { value: 'all', label: 'Tous' },
                                    { value: 'open', label: 'Ouverts' },
                                    { value: 'paid', label: 'Payés' },
                                ]}
                            />
                            <SearchMini
                                value={q}
                                onChange={setQ}
                                placeholder="Lot, station…"
                            />
                        </div>
                    </div>
                    <Table
                        head={[
                            'Lot',
                            'Station',
                            { label: 'Ventes brutes', num: true },
                            { label: 'Remb. déduits', num: true },
                            { label: 'Net à reverser', num: true },
                            'Statut',
                            'Payé le',
                            'Action',
                        ]}
                        empty="Aucun reversement pour ce filtre."
                    >
                        {rows.map((b) => (
                            <tr key={b.id}>
                                <td className="ref">{b.reference}</td>
                                <td className="strong">{b.station}</td>
                                <td className="num tnum">
                                    {num(b.gross_sales)}
                                </td>
                                <td
                                    className="num tnum"
                                    style={{
                                        color: b.refunds_deducted
                                            ? 'var(--destr)'
                                            : 'var(--muted)',
                                    }}
                                >
                                    {b.refunds_deducted
                                        ? `−${num(b.refunds_deducted)}`
                                        : '—'}
                                </td>
                                <td className="num t-amount">
                                    {fcfa(b.net_amount)}
                                </td>
                                <td>
                                    <Badge
                                        domain="settlement"
                                        value={b.status}
                                    />
                                </td>
                                <td className="tnum sub">{b.paid_at ?? '—'}</td>
                                <td>
                                    {b.status === 'open' ? (
                                        <div className="row-actions">
                                            <ConfirmButton
                                                size="sm"
                                                icon="banknote"
                                                title="Marquer le lot payé ?"
                                                description={`Confirmez le virement de ${fcfa(b.net_amount)} (net) vers ${b.station} · lot ${b.reference}.`}
                                                confirmLabel="Marquer payé"
                                                onConfirm={() =>
                                                    router.post(
                                                        `/admin/settlements/${b.id}/paid`,
                                                        {},
                                                        {
                                                            preserveScroll: true,
                                                        },
                                                    )
                                                }
                                            >
                                                Marquer payé
                                            </ConfirmButton>
                                        </div>
                                    ) : (
                                        <span className="sub">reversé</span>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

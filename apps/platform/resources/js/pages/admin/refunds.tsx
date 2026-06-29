import { router } from '@inertiajs/react';
import { useMemo, useState } from 'react';
import {
    Badge,
    fcfa,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Table,
} from '@/components/fusy';
import { ConfirmButton } from '@/components/overlays';

interface Refund {
    id: number;
    status: string;
    reason: string | null;
    payment_reference: string;
    amount: number;
    station: string;
}

interface Props {
    refunds: Refund[];
    pendingRefunds: number;
}

type RefundFilter = 'all' | 'pending' | 'approved' | 'rejected';

export default function AdminRefunds({ refunds, pendingRefunds }: Props) {
    const [filter, setFilter] = useState<RefundFilter>('all');
    const [q, setQ] = useState('');

    const rows = useMemo(() => {
        const needle = q.trim().toLowerCase();

        return refunds.filter((r) => {
            if (filter !== 'all' && r.status !== filter) {
                return false;
            }

            if (!needle) {
                return true;
            }

            return `${r.payment_reference} ${r.station}`
                .toLowerCase()
                .includes(needle);
        });
    }, [refunds, filter, q]);

    return (
        <Page title="Remboursements">
            <PageHead
                title="Remboursements"
                sub="Approuver un remboursement recrédite l'entreprise et rétablit le budget du chauffeur. Le refuser clôt la demande."
            />

            <div className="stack">
                <section className="card">
                    <div className="card-h">
                        <h3>{pendingRefunds} demande(s) en attente</h3>
                        <div className="actions">
                            <Seg
                                value={filter}
                                onChange={setFilter}
                                options={[
                                    { value: 'all', label: 'Tous' },
                                    { value: 'pending', label: 'En attente' },
                                    { value: 'approved', label: 'Approuvés' },
                                    { value: 'rejected', label: 'Refusés' },
                                ]}
                            />
                            <SearchMini
                                value={q}
                                onChange={setQ}
                                placeholder="Référence, station…"
                            />
                        </div>
                    </div>
                    <Table
                        head={[
                            'Réf. paiement',
                            'Station',
                            'Motif',
                            { label: 'Montant', num: true },
                            'Statut',
                            'Décision',
                        ]}
                        empty="Aucun remboursement pour ce filtre."
                    >
                        {rows.map((r) => (
                            <tr key={r.id}>
                                <td className="ref">{r.payment_reference}</td>
                                <td className="strong">{r.station}</td>
                                <td>
                                    {r.reason ?? (
                                        <span className="sub">
                                            — non précisé —
                                        </span>
                                    )}
                                </td>
                                <td className="num t-amount">
                                    {fcfa(r.amount)}
                                </td>
                                <td>
                                    <Badge domain="refund" value={r.status} />
                                </td>
                                <td>
                                    {r.status === 'pending' ? (
                                        <div className="row-actions">
                                            <ConfirmButton
                                                size="sm"
                                                variant="green"
                                                icon="check"
                                                title="Approuver le remboursement ?"
                                                description={`${fcfa(r.amount)} seront recrédités à l'entreprise rattachée à ${r.station} et au budget du chauffeur.`}
                                                confirmLabel="Approuver"
                                                onConfirm={() =>
                                                    router.post(
                                                        `/admin/refunds/${r.id}/approve`,
                                                        {},
                                                        {
                                                            preserveScroll: true,
                                                        },
                                                    )
                                                }
                                            >
                                                Approuver
                                            </ConfirmButton>
                                            <ConfirmButton
                                                size="sm"
                                                variant="danger"
                                                danger
                                                title="Refuser le remboursement ?"
                                                description={`La demande de ${fcfa(r.amount)} (${r.payment_reference}) sera close sans recréditer.`}
                                                confirmLabel="Refuser"
                                                onConfirm={() =>
                                                    router.post(
                                                        `/admin/refunds/${r.id}/reject`,
                                                        {},
                                                        {
                                                            preserveScroll: true,
                                                        },
                                                    )
                                                }
                                            >
                                                Refuser
                                            </ConfirmButton>
                                        </div>
                                    ) : (
                                        <span className="sub">traité</span>
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

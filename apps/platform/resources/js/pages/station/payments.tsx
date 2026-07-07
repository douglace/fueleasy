import { router } from '@inertiajs/react';
import { useMemo, useState } from 'react';
import {
    Badge,
    Btn,
    Chip,
    CopyCode,
    Field,
    FUEL,
    num,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Table,
    Textarea,
} from '@/components/fusy';
import { Modal } from '@/components/overlays';

interface PaymentRow {
    id: number;
    reference: string;
    short_code: string | null;
    amount: number;
    status: string;
    enterprise: string;
    fuel_type: string;
    confirmed_at: string | null;
}

type Filter = 'all' | 'paid' | 'pending' | 'refunded' | 'expired';

const FILTERS: { value: Filter; label: string }[] = [
    { value: 'all', label: 'Tous' },
    { value: 'paid', label: 'Payés' },
    { value: 'pending', label: 'En attente' },
    { value: 'refunded', label: 'Remboursés' },
    { value: 'expired', label: 'Expirés' },
];

const timeOf = (s: string | null) =>
    s
        ? new Date(s.replace(' ', 'T')).toLocaleString('fr-FR', {
              day: '2-digit',
              month: '2-digit',
              hour: '2-digit',
              minute: '2-digit',
          })
        : '—';

export default function StationPayments({
    payments,
}: {
    payments: PaymentRow[];
}) {
    const [filter, setFilter] = useState<Filter>('all');
    const [search, setSearch] = useState('');
    const [refundFor, setRefundFor] = useState<PaymentRow | null>(null);
    const [reason, setReason] = useState('');

    const filtered = useMemo(() => {
        const q = search.trim().toLowerCase();

        return payments.filter((p) => {
            if (filter !== 'all' && p.status !== filter) {
                return false;
            }

            if (!q) {
                return true;
            }

            return [p.reference, p.short_code, p.enterprise]
                .filter(Boolean)
                .some((v) => v!.toLowerCase().includes(q));
        });
    }, [payments, filter, search]);

    const openRefund = (p: PaymentRow) => {
        setReason('');
        setRefundFor(p);
    };

    return (
        <Page title="Paiements">
            <PageHead
                title="Paiements"
                sub="Tous les paiements confirmés à vos pompes. Le code court permet de retrouver un paiement avec un client."
            />

            <div className="stack">
                <section className="card">
                    <div className="filters">
                        <Seg
                            value={filter}
                            onChange={setFilter}
                            options={FILTERS}
                        />
                        <div style={{ marginLeft: 'auto' }}>
                            <SearchMini
                                value={search}
                                onChange={setSearch}
                                placeholder="Code court, référence, entreprise…"
                            />
                        </div>
                        <span className="chip">
                            <b>{filtered.length}</b>&nbsp;résultats
                        </span>
                    </div>
                    <Table
                        head={[
                            'Référence',
                            'Code court',
                            'Entreprise',
                            'Carburant',
                            { label: 'Montant', num: true },
                            'Statut',
                            'Confirmé',
                            '',
                        ]}
                        empty="Aucun paiement ne correspond à ce filtre."
                    >
                        {filtered.map((p) => (
                            <tr key={p.id}>
                                <td className="ref">{p.reference}</td>
                                <td>
                                    <CopyCode code={p.short_code} />
                                </td>
                                <td className="strong">{p.enterprise}</td>
                                <td>
                                    <Chip icon="drop">
                                        {FUEL[p.fuel_type] ?? p.fuel_type}
                                    </Chip>
                                </td>
                                <td className="num t-amount">
                                    {num(p.amount)}
                                </td>
                                <td>
                                    <Badge domain="payment" value={p.status} />
                                </td>
                                <td className="tnum sub">
                                    {timeOf(p.confirmed_at)}
                                </td>
                                <td>
                                    <div className="row-actions">
                                        {p.status === 'paid' ? (
                                            <Btn
                                                variant="ghost"
                                                size="sm"
                                                icon="refund"
                                                onClick={() => openRefund(p)}
                                            >
                                                Rembourser
                                            </Btn>
                                        ) : (
                                            <span className="muted">—</span>
                                        )}
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>

            <Modal
                open={refundFor !== null}
                onClose={() => setRefundFor(null)}
                icon="refund"
                title="Demander un remboursement"
                subtitle={
                    refundFor
                        ? `Paiement ${refundFor.reference} · ${num(refundFor.amount)} FCFA — ${refundFor.enterprise}.`
                        : undefined
                }
                confirmLabel="Envoyer la demande"
                onConfirm={() => {
                    if (!refundFor) {
                        return;
                    }

                    router.post(
                        `/station/payments/${refundFor.id}/refund`,
                        { reason },
                        { preserveScroll: true },
                    );
                }}
            >
                <Field
                    label="Motif du remboursement"
                    hint="Ex. erreur de montant, double facturation, carburant non délivré…"
                >
                    <Textarea
                        rows={3}
                        value={reason}
                        onChange={(e) => setReason(e.target.value)}
                    />
                </Field>
            </Modal>
        </Page>
    );
}

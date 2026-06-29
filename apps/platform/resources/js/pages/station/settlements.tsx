import {
    Badge,
    Kpi,
    Note,
    num,
    Page,
    PageHead,
    Table,
} from '@/components/fusy';

interface Batch {
    id: number;
    reference: string;
    gross_sales: number;
    refunds_deducted: number;
    net_amount: number;
    status: string;
    paid_at: string | null;
}

interface Props {
    summary: { today_sales: number; pending_amount: number };
    batches: Batch[];
}

export default function StationSettlements({ summary, batches }: Props) {
    return (
        <Page title="Reversements">
            <PageHead
                title="Reversements"
                sub="Le montant que Fusy vous reverse pour les paiements encaissés à vos pompes, par lot hebdomadaire."
            />

            <div className="stack">
                <div className="cols-4 grid">
                    <Kpi
                        icon="bolt"
                        variant="accent-green"
                        span2
                        label="Ventes Fusy du jour"
                        value={num(summary.today_sales)}
                        unit="FCFA"
                        foot="seront intégrées au lot de la semaine"
                    />
                    <Kpi
                        icon="clock"
                        variant="accent-warn"
                        span2
                        label="En attente de reversement"
                        value={num(summary.pending_amount)}
                        unit="FCFA"
                        foot="net du lot ouvert · versé en fin de semaine"
                    />
                </div>

                <Note>
                    Les lots sont générés et marqués payés par <b>Fusy</b>.
                    Cette page est en lecture seule — vous suivez ici l'état de
                    vos reversements.{' '}
                    <b>Net = ventes brutes − remboursements déduits.</b>
                </Note>

                <section className="card">
                    <div className="card-h">
                        <h3>Lots de reversement</h3>
                        <span className="sub">
                            <b>{batches.length}</b> lots
                        </span>
                    </div>
                    <Table
                        head={[
                            'Lot',
                            { label: 'Ventes brutes', num: true },
                            { label: 'Remb. déduits', num: true },
                            { label: 'Net à reverser', num: true },
                            'Statut',
                            'Payé le',
                        ]}
                        empty="Aucun lot pour le moment."
                    >
                        {batches.map((b) => (
                            <tr key={b.id}>
                                <td>
                                    <span className="mono font-bold">
                                        {b.reference}
                                    </span>
                                </td>
                                <td className="num tnum">
                                    {num(b.gross_sales)}
                                </td>
                                <td
                                    className="num tnum"
                                    style={{
                                        color: b.refunds_deducted
                                            ? 'var(--err)'
                                            : 'var(--muted)',
                                    }}
                                >
                                    {b.refunds_deducted
                                        ? `− ${num(b.refunds_deducted)}`
                                        : '—'}
                                </td>
                                <td className="num t-amount">
                                    {num(b.net_amount)}
                                </td>
                                <td>
                                    <Badge
                                        domain="settlement"
                                        value={b.status}
                                    />
                                </td>
                                <td className="tnum sub">
                                    {b.paid_at ?? (
                                        <span className="muted">—</span>
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

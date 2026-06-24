import { Head, router } from '@inertiajs/react';

interface Refund {
    id: number;
    status: string;
    reason: string | null;
    payment_reference: string;
    amount: number;
}

interface Batch {
    id: number;
    reference: string;
    station: string;
    net_amount: number;
    status: string;
    paid_at: string | null;
}

interface Props {
    refunds: Refund[];
    batches: Batch[];
    pendingRefunds: number;
}

export default function AdminOperations({
    refunds,
    batches,
    pendingRefunds,
}: Props) {
    return (
        <>
            <Head title="Opérations Fusy" />
            <div className="flex flex-col gap-6 p-4">
                <h1 className="text-2xl font-semibold">
                    Remboursements & reversements
                </h1>
                <p className="text-sm text-muted-foreground">
                    {pendingRefunds} demande(s) de remboursement en attente.
                </p>

                <section className="rounded-xl border border-border p-4">
                    <div className="mb-3 flex items-center justify-between">
                        <h2 className="font-medium">Reversements</h2>
                        <button
                            onClick={() =>
                                router.post('/admin/settlements/generate')
                            }
                            className="rounded bg-primary px-3 py-1.5 text-sm text-primary-foreground"
                        >
                            Générer les lots hebdomadaires
                        </button>
                    </div>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Référence</th>
                                <th className="p-2">Station</th>
                                <th className="p-2">Net</th>
                                <th className="p-2">Statut</th>
                                <th className="p-2" />
                            </tr>
                        </thead>
                        <tbody>
                            {batches.map((b) => (
                                <tr
                                    key={b.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2 font-mono">
                                        {b.reference}
                                    </td>
                                    <td className="p-2">{b.station}</td>
                                    <td className="p-2">
                                        {b.net_amount.toLocaleString('fr-FR')}
                                    </td>
                                    <td className="p-2">{b.status}</td>
                                    <td className="p-2">
                                        {b.status === 'open' && (
                                            <button
                                                onClick={() =>
                                                    router.post(
                                                        `/admin/settlements/${b.id}/paid`,
                                                    )
                                                }
                                                className="text-primary underline"
                                            >
                                                Marquer payé
                                            </button>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">
                        Demandes de remboursement
                    </h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Paiement</th>
                                <th className="p-2">Montant</th>
                                <th className="p-2">Motif</th>
                                <th className="p-2">Statut</th>
                                <th className="p-2" />
                            </tr>
                        </thead>
                        <tbody>
                            {refunds.map((r) => (
                                <tr
                                    key={r.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2 font-mono">
                                        {r.payment_reference}
                                    </td>
                                    <td className="p-2">
                                        {r.amount.toLocaleString('fr-FR')}
                                    </td>
                                    <td className="p-2">{r.reason ?? '—'}</td>
                                    <td className="p-2">{r.status}</td>
                                    <td className="p-2">
                                        {r.status === 'pending' && (
                                            <span className="flex gap-2">
                                                <button
                                                    onClick={() =>
                                                        router.post(
                                                            `/admin/refunds/${r.id}/approve`,
                                                        )
                                                    }
                                                    className="text-green-600 underline"
                                                >
                                                    Approuver
                                                </button>
                                                <button
                                                    onClick={() =>
                                                        router.post(
                                                            `/admin/refunds/${r.id}/reject`,
                                                        )
                                                    }
                                                    className="text-red-600 underline"
                                                >
                                                    Refuser
                                                </button>
                                            </span>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>
            </div>
        </>
    );
}

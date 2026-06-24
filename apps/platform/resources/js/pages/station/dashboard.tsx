import { Head, router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { useState } from 'react';

interface Pump {
    id: number;
    label: string;
    status: string;
    fixed_qr_active: boolean;
    available_fuels: string[];
}

interface Pompiste {
    id: number;
    name: string;
    phone: string | null;
    matricule: string | null;
    status: string;
    pin_is_temporary: boolean;
}

interface PaymentRow {
    id: number;
    reference: string;
    short_code: string;
    amount: number;
    status: string;
    enterprise: string;
    fuel_type: string;
    confirmed_at: string | null;
}

interface Batch {
    id: number;
    reference: string;
    net_amount: number;
    status: string;
    paid_at: string | null;
}

interface Props {
    pumps: Pump[];
    pompistes: Pompiste[];
    fuels: { value: string; label: string }[];
    payments: PaymentRow[];
    settlement: {
        today_sales: number;
        pending_amount: number;
        batches: Batch[];
    };
}

export default function StationDashboard({
    pumps,
    pompistes,
    fuels,
    payments,
    settlement,
}: Props) {
    const pumpForm = useForm<{ label: string; available_fuels: string[] }>({
        label: '',
        available_fuels: [],
    });
    const pompisteForm = useForm({ name: '', phone: '', matricule: '' });
    const [refundReasons, setRefundReasons] = useState<Record<number, string>>(
        {},
    );

    const submitPump = (e: FormEvent) => {
        e.preventDefault();
        pumpForm.post('/station/pumps', { onSuccess: () => pumpForm.reset() });
    };
    const submitPompiste = (e: FormEvent) => {
        e.preventDefault();
        pompisteForm.post('/station/pompistes', {
            onSuccess: () => pompisteForm.reset(),
        });
    };
    const toggleFuel = (value: string) => {
        const current = pumpForm.data.available_fuels;
        pumpForm.setData(
            'available_fuels',
            current.includes(value)
                ? current.filter((f) => f !== value)
                : [...current, value],
        );
    };

    return (
        <>
            <Head title="Espace station" />
            <div className="flex flex-col gap-6 p-4">
                <h1 className="text-2xl font-semibold">Espace station</h1>

                <div className="grid gap-4 md:grid-cols-3">
                    <Stat
                        label="Ventes Fusy du jour"
                        value={settlement.today_sales}
                    />
                    <Stat
                        label="En attente de reversement"
                        value={settlement.pending_amount}
                    />
                    <Stat label="Pompes" value={pumps.length} />
                </div>

                <div className="grid gap-6 lg:grid-cols-2">
                    <section className="rounded-xl border border-border p-4">
                        <h2 className="mb-3 font-medium">Ajouter une pompe</h2>
                        <form onSubmit={submitPump} className="grid gap-2">
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Libellé (ex: Pompe 1)"
                                value={pumpForm.data.label}
                                onChange={(e) =>
                                    pumpForm.setData('label', e.target.value)
                                }
                            />
                            <div className="flex flex-wrap gap-3 text-sm">
                                {fuels.map((f) => (
                                    <label
                                        key={f.value}
                                        className="flex items-center gap-1"
                                    >
                                        <input
                                            type="checkbox"
                                            checked={pumpForm.data.available_fuels.includes(
                                                f.value,
                                            )}
                                            onChange={() => toggleFuel(f.value)}
                                        />{' '}
                                        {f.label}
                                    </label>
                                ))}
                            </div>
                            <button
                                type="submit"
                                disabled={pumpForm.processing}
                                className="rounded bg-primary px-3 py-2 text-primary-foreground"
                            >
                                Créer
                            </button>
                        </form>
                    </section>

                    <section className="rounded-xl border border-border p-4">
                        <h2 className="mb-3 font-medium">
                            Ajouter un pompiste
                        </h2>
                        <form onSubmit={submitPompiste} className="grid gap-2">
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Nom"
                                value={pompisteForm.data.name}
                                onChange={(e) =>
                                    pompisteForm.setData('name', e.target.value)
                                }
                            />
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Téléphone"
                                value={pompisteForm.data.phone}
                                onChange={(e) =>
                                    pompisteForm.setData(
                                        'phone',
                                        e.target.value,
                                    )
                                }
                            />
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Matricule"
                                value={pompisteForm.data.matricule}
                                onChange={(e) =>
                                    pompisteForm.setData(
                                        'matricule',
                                        e.target.value,
                                    )
                                }
                            />
                            <button
                                type="submit"
                                disabled={pompisteForm.processing}
                                className="rounded bg-primary px-3 py-2 text-primary-foreground"
                            >
                                Créer
                            </button>
                        </form>
                    </section>
                </div>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Pompes</h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Pompe</th>
                                <th className="p-2">Carburants</th>
                                <th className="p-2">QR fixe</th>
                                <th className="p-2" />
                            </tr>
                        </thead>
                        <tbody>
                            {pumps.map((p) => (
                                <tr
                                    key={p.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2">{p.label}</td>
                                    <td className="p-2">
                                        {p.available_fuels.join(', ')}
                                    </td>
                                    <td className="p-2">
                                        {p.fixed_qr_active
                                            ? 'actif'
                                            : 'désactivé'}
                                    </td>
                                    <td className="p-2">
                                        <button
                                            onClick={() =>
                                                router.post(
                                                    `/station/pumps/${p.id}/toggle-qr`,
                                                )
                                            }
                                            className="text-primary underline"
                                        >
                                            {p.fixed_qr_active
                                                ? 'Désactiver'
                                                : 'Activer'}
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Pompistes</h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Nom</th>
                                <th className="p-2">Identifiant</th>
                                <th className="p-2">Statut</th>
                                <th className="p-2" />
                            </tr>
                        </thead>
                        <tbody>
                            {pompistes.map((u) => (
                                <tr
                                    key={u.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2">{u.name}</td>
                                    <td className="p-2">
                                        {u.phone ?? u.matricule ?? '—'}
                                    </td>
                                    <td className="p-2">
                                        {u.status}
                                        {u.pin_is_temporary
                                            ? ' · PIN temp'
                                            : ''}
                                    </td>
                                    <td className="p-2">
                                        <span className="flex gap-2 text-xs">
                                            <button
                                                onClick={() =>
                                                    router.post(
                                                        `/station/pompistes/${u.id}/reset-pin`,
                                                    )
                                                }
                                                className="text-primary underline"
                                            >
                                                Reset PIN
                                            </button>
                                            <button
                                                onClick={() =>
                                                    router.post(
                                                        `/station/pompistes/${u.id}/suspend`,
                                                    )
                                                }
                                                className="text-primary underline"
                                            >
                                                {u.status === 'active'
                                                    ? 'Suspendre'
                                                    : 'Réactiver'}
                                            </button>
                                        </span>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Paiements reçus</h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Code</th>
                                <th className="p-2">Entreprise</th>
                                <th className="p-2">Carburant</th>
                                <th className="p-2">Montant</th>
                                <th className="p-2">Statut</th>
                                <th className="p-2" />
                            </tr>
                        </thead>
                        <tbody>
                            {payments.map((p) => (
                                <tr
                                    key={p.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2 font-mono">
                                        {p.short_code}
                                    </td>
                                    <td className="p-2">{p.enterprise}</td>
                                    <td className="p-2">{p.fuel_type}</td>
                                    <td className="p-2">
                                        {p.amount.toLocaleString('fr-FR')}
                                    </td>
                                    <td className="p-2">{p.status}</td>
                                    <td className="p-2">
                                        {p.status === 'paid' && (
                                            <span className="flex items-center gap-1">
                                                <input
                                                    className="w-28 rounded border border-border bg-background p-1 text-xs"
                                                    placeholder="Motif"
                                                    value={
                                                        refundReasons[p.id] ??
                                                        ''
                                                    }
                                                    onChange={(e) =>
                                                        setRefundReasons({
                                                            ...refundReasons,
                                                            [p.id]: e.target
                                                                .value,
                                                        })
                                                    }
                                                />
                                                <button
                                                    onClick={() =>
                                                        router.post(
                                                            `/station/payments/${p.id}/refund`,
                                                            {
                                                                reason:
                                                                    refundReasons[
                                                                        p.id
                                                                    ] ?? '',
                                                            },
                                                        )
                                                    }
                                                    className="text-red-600 underline"
                                                >
                                                    Rembourser
                                                </button>
                                            </span>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Lots de reversement</h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Référence</th>
                                <th className="p-2">Net</th>
                                <th className="p-2">Statut</th>
                            </tr>
                        </thead>
                        <tbody>
                            {settlement.batches.map((b) => (
                                <tr
                                    key={b.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2 font-mono">
                                        {b.reference}
                                    </td>
                                    <td className="p-2">
                                        {b.net_amount.toLocaleString('fr-FR')}
                                    </td>
                                    <td className="p-2">{b.status}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>
            </div>
        </>
    );
}

function Stat({ label, value }: { label: string; value: number }) {
    return (
        <div className="rounded-xl border border-border p-4">
            <div className="text-sm text-muted-foreground">{label}</div>
            <div className="text-2xl font-semibold">
                {value.toLocaleString('fr-FR')}
            </div>
        </div>
    );
}

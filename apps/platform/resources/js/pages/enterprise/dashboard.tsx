import { Head, router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { useState } from 'react';

interface Budget {
    mode: string;
    amount: number;
    balance: number;
}

interface Driver {
    id: number;
    name: string;
    phone: string | null;
    matricule: string | null;
    status: string;
    pin_is_temporary: boolean;
    budget: Budget | null;
}

interface Transaction {
    id: number;
    reference: string;
    amount: number;
    status: string;
    station: string;
    created_at: string | null;
}

interface Props {
    balance: number;
    drivers: Driver[];
    transactions: Transaction[];
}

export default function EnterpriseDashboard({
    balance,
    drivers,
    transactions,
}: Props) {
    const driverForm = useForm({ name: '', phone: '', matricule: '' });
    const [budgets, setBudgets] = useState<
        Record<number, { mode: string; amount: string }>
    >({});

    const submitDriver = (e: FormEvent) => {
        e.preventDefault();
        driverForm.post('/enterprise/drivers', {
            onSuccess: () => driverForm.reset(),
        });
    };

    const submitBudget = (driverId: number) => {
        const b = budgets[driverId] ?? { mode: 'manual', amount: '' };
        router.post(`/enterprise/drivers/${driverId}/budget`, {
            mode: b.mode,
            amount: b.amount,
        });
    };

    return (
        <>
            <Head title="Espace entreprise" />
            <div className="flex flex-col gap-6 p-4">
                <div className="flex items-center justify-between">
                    <h1 className="text-2xl font-semibold">
                        Espace entreprise
                    </h1>
                    <a
                        href="/enterprise/export/transactions"
                        className="rounded border border-border px-3 py-1.5 text-sm"
                    >
                        Export CSV
                    </a>
                </div>

                <div className="rounded-xl border border-border p-4">
                    <div className="text-sm text-muted-foreground">
                        Solde du compte carburant
                    </div>
                    <div className="text-3xl font-semibold">
                        {balance.toLocaleString('fr-FR')} FCFA
                    </div>
                </div>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Ajouter un chauffeur</h2>
                    <form
                        onSubmit={submitDriver}
                        className="flex flex-wrap gap-2"
                    >
                        <input
                            className="rounded border border-border bg-background p-2"
                            placeholder="Nom"
                            value={driverForm.data.name}
                            onChange={(e) =>
                                driverForm.setData('name', e.target.value)
                            }
                        />
                        <input
                            className="rounded border border-border bg-background p-2"
                            placeholder="Téléphone"
                            value={driverForm.data.phone}
                            onChange={(e) =>
                                driverForm.setData('phone', e.target.value)
                            }
                        />
                        <input
                            className="rounded border border-border bg-background p-2"
                            placeholder="Matricule"
                            value={driverForm.data.matricule}
                            onChange={(e) =>
                                driverForm.setData('matricule', e.target.value)
                            }
                        />
                        <button
                            type="submit"
                            disabled={driverForm.processing}
                            className="rounded bg-primary px-3 py-2 text-primary-foreground"
                        >
                            Créer
                        </button>
                    </form>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Chauffeurs</h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Nom</th>
                                <th className="p-2">Identifiant</th>
                                <th className="p-2">Budget</th>
                                <th className="p-2">Statut</th>
                                <th className="p-2">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {drivers.map((d) => (
                                <tr
                                    key={d.id}
                                    className="border-t border-border align-top"
                                >
                                    <td className="p-2">{d.name}</td>
                                    <td className="p-2">
                                        {d.phone ?? d.matricule ?? '—'}
                                    </td>
                                    <td className="p-2">
                                        {d.budget
                                            ? `${d.budget.balance.toLocaleString('fr-FR')} / ${d.budget.amount.toLocaleString('fr-FR')} (${d.budget.mode})`
                                            : '—'}
                                        <div className="mt-1 flex gap-1">
                                            <select
                                                className="rounded border border-border bg-background p-1 text-xs"
                                                value={
                                                    budgets[d.id]?.mode ??
                                                    'manual'
                                                }
                                                onChange={(e) =>
                                                    setBudgets({
                                                        ...budgets,
                                                        [d.id]: {
                                                            mode: e.target
                                                                .value,
                                                            amount:
                                                                budgets[d.id]
                                                                    ?.amount ??
                                                                '',
                                                        },
                                                    })
                                                }
                                            >
                                                <option value="manual">
                                                    Manuel
                                                </option>
                                                <option value="weekly">
                                                    Hebdo
                                                </option>
                                                <option value="monthly">
                                                    Mensuel
                                                </option>
                                            </select>
                                            <input
                                                className="w-24 rounded border border-border bg-background p-1 text-xs"
                                                placeholder="Montant"
                                                value={
                                                    budgets[d.id]?.amount ?? ''
                                                }
                                                onChange={(e) =>
                                                    setBudgets({
                                                        ...budgets,
                                                        [d.id]: {
                                                            mode:
                                                                budgets[d.id]
                                                                    ?.mode ??
                                                                'manual',
                                                            amount: e.target
                                                                .value,
                                                        },
                                                    })
                                                }
                                            />
                                            <button
                                                onClick={() =>
                                                    submitBudget(d.id)
                                                }
                                                className="rounded bg-primary px-2 py-1 text-xs text-primary-foreground"
                                            >
                                                Définir
                                            </button>
                                        </div>
                                    </td>
                                    <td className="p-2">
                                        {d.status}
                                        {d.pin_is_temporary
                                            ? ' · PIN temp'
                                            : ''}
                                    </td>
                                    <td className="p-2">
                                        <div className="flex flex-col gap-1 text-xs">
                                            <button
                                                onClick={() =>
                                                    router.post(
                                                        `/enterprise/drivers/${d.id}/reset-pin`,
                                                    )
                                                }
                                                className="text-primary underline"
                                            >
                                                Reset PIN
                                            </button>
                                            <button
                                                onClick={() =>
                                                    router.post(
                                                        `/enterprise/drivers/${d.id}/suspend`,
                                                    )
                                                }
                                                className="text-primary underline"
                                            >
                                                {d.status === 'active'
                                                    ? 'Suspendre'
                                                    : 'Réactiver'}
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Transactions</h2>
                    <table className="w-full text-left text-sm">
                        <thead>
                            <tr>
                                <th className="p-2">Référence</th>
                                <th className="p-2">Station</th>
                                <th className="p-2">Montant</th>
                                <th className="p-2">Statut</th>
                            </tr>
                        </thead>
                        <tbody>
                            {transactions.map((t) => (
                                <tr
                                    key={t.id}
                                    className="border-t border-border"
                                >
                                    <td className="p-2 font-mono">
                                        {t.reference}
                                    </td>
                                    <td className="p-2">{t.station}</td>
                                    <td className="p-2">
                                        {t.amount.toLocaleString('fr-FR')}
                                    </td>
                                    <td className="p-2">{t.status}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </section>
            </div>
        </>
    );
}

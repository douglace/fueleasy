import { router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { useState } from 'react';
import { Card, num, Page, Table } from '@/components/fusy';

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

const input = 'rounded border border-border bg-background p-2';

export default function EnterpriseDrivers({ drivers }: { drivers: Driver[] }) {
    const driverForm = useForm({ name: '', phone: '', matricule: '' });
    const [budgets, setBudgets] = useState<
        Record<number, { mode: string; amount: string }>
    >({});

    const submitDriver = (e: FormEvent) => {
        e.preventDefault();
        driverForm.post('/enterprise/drivers', {
            preserveScroll: true,
            onSuccess: () => driverForm.reset(),
        });
    };
    const submitBudget = (id: number) => {
        const b = budgets[id] ?? { mode: 'manual', amount: '' };
        router.post(
            `/enterprise/drivers/${id}/budget`,
            { mode: b.mode, amount: b.amount },
            { preserveScroll: true },
        );
    };

    return (
        <Page title="Chauffeurs">
            <Card title="Ajouter un chauffeur">
                <form onSubmit={submitDriver} className="flex flex-wrap gap-2">
                    <input
                        className={input}
                        placeholder="Nom"
                        value={driverForm.data.name}
                        onChange={(e) =>
                            driverForm.setData('name', e.target.value)
                        }
                    />
                    <input
                        className={input}
                        placeholder="Téléphone"
                        value={driverForm.data.phone}
                        onChange={(e) =>
                            driverForm.setData('phone', e.target.value)
                        }
                    />
                    <input
                        className={input}
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
                <p className="mt-2 text-xs text-muted-foreground">
                    Le PIN temporaire est affiché après création.
                </p>
            </Card>

            <Card title={`${drivers.length} chauffeur(s)`}>
                <Table
                    head={['Nom', 'Identifiant', 'Budget', 'Statut', 'Actions']}
                >
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
                                    ? `${num(d.budget.balance)} / ${num(d.budget.amount)} (${d.budget.mode})`
                                    : '—'}
                                <div className="mt-1 flex gap-1">
                                    <select
                                        className="rounded border border-border bg-background p-1 text-xs"
                                        value={budgets[d.id]?.mode ?? 'manual'}
                                        onChange={(e) =>
                                            setBudgets({
                                                ...budgets,
                                                [d.id]: {
                                                    mode: e.target.value,
                                                    amount:
                                                        budgets[d.id]?.amount ??
                                                        '',
                                                },
                                            })
                                        }
                                    >
                                        <option value="manual">Manuel</option>
                                        <option value="weekly">Hebdo</option>
                                        <option value="monthly">Mensuel</option>
                                    </select>
                                    <input
                                        className="w-24 rounded border border-border bg-background p-1 text-xs"
                                        placeholder="Montant"
                                        value={budgets[d.id]?.amount ?? ''}
                                        onChange={(e) =>
                                            setBudgets({
                                                ...budgets,
                                                [d.id]: {
                                                    mode:
                                                        budgets[d.id]?.mode ??
                                                        'manual',
                                                    amount: e.target.value,
                                                },
                                            })
                                        }
                                    />
                                    <button
                                        onClick={() => submitBudget(d.id)}
                                        className="rounded bg-primary px-2 py-1 text-xs text-primary-foreground"
                                    >
                                        Définir
                                    </button>
                                    {d.budget && (
                                        <button
                                            onClick={() =>
                                                router.post(
                                                    `/enterprise/drivers/${d.id}/budget/reset`,
                                                    {},
                                                    { preserveScroll: true },
                                                )
                                            }
                                            className="text-xs text-primary underline"
                                        >
                                            Reset
                                        </button>
                                    )}
                                </div>
                            </td>
                            <td className="p-2">
                                {d.status}
                                {d.pin_is_temporary ? ' · PIN temp' : ''}
                            </td>
                            <td className="p-2">
                                <div className="flex flex-col gap-1 text-xs">
                                    <button
                                        onClick={() =>
                                            router.post(
                                                `/enterprise/drivers/${d.id}/reset-pin`,
                                                {},
                                                { preserveScroll: true },
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
                                                {},
                                                { preserveScroll: true },
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
                </Table>
            </Card>
        </Page>
    );
}

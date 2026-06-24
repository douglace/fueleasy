import { Head, router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';

interface Organization {
    id: number;
    code: string;
    type: string;
    name: string;
    status: string;
    is_demo: boolean;
    balance: number | null;
}

interface PaymentRow {
    id: number;
    reference: string;
    amount: number;
    status: string;
    station: string;
    enterprise: string;
    created_at: string | null;
}

interface AuditRow {
    id: number;
    action: string;
    organization_id: number | null;
    created_at: string | null;
}

interface Props {
    organizations: Organization[];
    recentPayments: PaymentRow[];
    audit: AuditRow[];
    stats: { enterprises: number; stations: number; paidPayments: number };
}

export default function AdminDashboard({
    organizations,
    recentPayments,
    audit,
    stats,
}: Props) {
    const orgForm = useForm({
        type: 'enterprise',
        name: '',
        is_demo: false as boolean,
        admin_name: '',
        admin_email: '',
        admin_password: '',
    });

    const creditForm = useForm({
        organization_id: '',
        amount: '',
        description: '',
    });

    const submitOrg = (e: FormEvent) => {
        e.preventDefault();
        orgForm.post('/admin/organizations', {
            onSuccess: () => orgForm.reset(),
        });
    };

    const submitCredit = (e: FormEvent) => {
        e.preventDefault();
        creditForm.post('/admin/fuel-credits', {
            onSuccess: () => creditForm.reset(),
        });
    };

    return (
        <>
            <Head title="Admin Fusy" />
            <div className="flex flex-col gap-6 p-4">
                <h1 className="text-2xl font-semibold">Admin Fusy</h1>

                <div className="grid gap-4 md:grid-cols-3">
                    <Stat label="Entreprises" value={stats.enterprises} />
                    <Stat label="Stations" value={stats.stations} />
                    <Stat label="Paiements réglés" value={stats.paidPayments} />
                </div>

                <div className="grid gap-6 lg:grid-cols-2">
                    <section className="rounded-xl border border-border p-4">
                        <h2 className="mb-3 font-medium">
                            Créer une organisation
                        </h2>
                        <form onSubmit={submitOrg} className="grid gap-2">
                            <select
                                className="rounded border border-border bg-background p-2"
                                value={orgForm.data.type}
                                onChange={(e) =>
                                    orgForm.setData('type', e.target.value)
                                }
                            >
                                <option value="enterprise">Entreprise</option>
                                <option value="station">Station</option>
                            </select>
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Nom de l'organisation"
                                value={orgForm.data.name}
                                onChange={(e) =>
                                    orgForm.setData('name', e.target.value)
                                }
                            />
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Nom de l'admin"
                                value={orgForm.data.admin_name}
                                onChange={(e) =>
                                    orgForm.setData(
                                        'admin_name',
                                        e.target.value,
                                    )
                                }
                            />
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Email admin"
                                value={orgForm.data.admin_email}
                                onChange={(e) =>
                                    orgForm.setData(
                                        'admin_email',
                                        e.target.value,
                                    )
                                }
                            />
                            <input
                                type="password"
                                className="rounded border border-border bg-background p-2"
                                placeholder="Mot de passe admin"
                                value={orgForm.data.admin_password}
                                onChange={(e) =>
                                    orgForm.setData(
                                        'admin_password',
                                        e.target.value,
                                    )
                                }
                            />
                            <label className="flex items-center gap-2 text-sm">
                                <input
                                    type="checkbox"
                                    checked={orgForm.data.is_demo}
                                    onChange={(e) =>
                                        orgForm.setData(
                                            'is_demo',
                                            e.target.checked,
                                        )
                                    }
                                />{' '}
                                Organisation démo
                            </label>
                            <button
                                type="submit"
                                disabled={orgForm.processing}
                                className="rounded bg-primary px-3 py-2 text-primary-foreground"
                            >
                                Créer
                            </button>
                        </form>
                    </section>

                    <section className="rounded-xl border border-border p-4">
                        <h2 className="mb-3 font-medium">
                            Créditer un compte carburant
                        </h2>
                        <form onSubmit={submitCredit} className="grid gap-2">
                            <select
                                className="rounded border border-border bg-background p-2"
                                value={creditForm.data.organization_id}
                                onChange={(e) =>
                                    creditForm.setData(
                                        'organization_id',
                                        e.target.value,
                                    )
                                }
                            >
                                <option value="">— Entreprise —</option>
                                {organizations
                                    .filter((o) => o.type === 'enterprise')
                                    .map((o) => (
                                        <option key={o.id} value={o.id}>
                                            {o.name} ({o.code})
                                        </option>
                                    ))}
                            </select>
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Montant FCFA"
                                value={creditForm.data.amount}
                                onChange={(e) =>
                                    creditForm.setData('amount', e.target.value)
                                }
                            />
                            <input
                                className="rounded border border-border bg-background p-2"
                                placeholder="Description"
                                value={creditForm.data.description}
                                onChange={(e) =>
                                    creditForm.setData(
                                        'description',
                                        e.target.value,
                                    )
                                }
                            />
                            <button
                                type="submit"
                                disabled={creditForm.processing}
                                className="rounded bg-primary px-3 py-2 text-primary-foreground"
                            >
                                Créditer
                            </button>
                        </form>
                        <button
                            onClick={() => router.visit('/admin/operations')}
                            className="mt-3 text-sm text-primary underline"
                        >
                            Remboursements & reversements →
                        </button>
                    </section>
                </div>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Organisations</h2>
                    <Table head={['Code', 'Type', 'Nom', 'Statut', 'Solde']}>
                        {organizations.map((o) => (
                            <tr key={o.id} className="border-t border-border">
                                <td className="p-2 font-mono">{o.code}</td>
                                <td className="p-2">
                                    {o.type}
                                    {o.is_demo ? ' (démo)' : ''}
                                </td>
                                <td className="p-2">{o.name}</td>
                                <td className="p-2">{o.status}</td>
                                <td className="p-2">
                                    {o.balance === null
                                        ? '—'
                                        : o.balance.toLocaleString('fr-FR')}
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Transactions récentes</h2>
                    <Table
                        head={[
                            'Référence',
                            'Entreprise',
                            'Station',
                            'Montant',
                            'Statut',
                        ]}
                    >
                        {recentPayments.map((p) => (
                            <tr key={p.id} className="border-t border-border">
                                <td className="p-2 font-mono">{p.reference}</td>
                                <td className="p-2">{p.enterprise}</td>
                                <td className="p-2">{p.station}</td>
                                <td className="p-2">
                                    {p.amount.toLocaleString('fr-FR')}
                                </td>
                                <td className="p-2">{p.status}</td>
                            </tr>
                        ))}
                    </Table>
                </section>

                <section className="rounded-xl border border-border p-4">
                    <h2 className="mb-3 font-medium">Audit</h2>
                    <ul className="text-sm">
                        {audit.map((a) => (
                            <li
                                key={a.id}
                                className="border-t border-border py-1"
                            >
                                {a.created_at} — {a.action}
                            </li>
                        ))}
                    </ul>
                </section>
            </div>
        </>
    );
}

function Stat({ label, value }: { label: string; value: number }) {
    return (
        <div className="rounded-xl border border-border p-4">
            <div className="text-sm text-muted-foreground">{label}</div>
            <div className="text-2xl font-semibold">{value}</div>
        </div>
    );
}

function Table({
    head,
    children,
}: {
    head: string[];
    children: React.ReactNode;
}) {
    return (
        <table className="w-full text-left text-sm">
            <thead>
                <tr>
                    {head.map((h) => (
                        <th key={h} className="p-2 text-muted-foreground">
                            {h}
                        </th>
                    ))}
                </tr>
            </thead>
            <tbody>{children}</tbody>
        </table>
    );
}

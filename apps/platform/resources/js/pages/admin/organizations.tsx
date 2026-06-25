import { useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { Card, Field, num, Page, Table } from '@/components/fusy';

interface Organization {
    id: number;
    code: string;
    type: string;
    name: string;
    status: string;
    is_demo: boolean;
    balance: number | null;
}

interface Authorization {
    id: number;
    enterprise: string;
    station: string;
}

interface Props {
    organizations: Organization[];
    enterprises: Organization[];
    stations: Organization[];
    authorizations: Authorization[];
}

const input = 'rounded border border-border bg-background p-2';

export default function AdminOrganizations({
    organizations,
    enterprises,
    stations,
    authorizations,
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
    const authForm = useForm({
        enterprise_organization_id: '',
        station_organization_id: '',
    });

    const submit =
        (form: ReturnType<typeof useForm>, url: string) => (e: FormEvent) => {
            e.preventDefault();
            form.post(url, {
                preserveScroll: true,
                onSuccess: () => form.reset(),
            });
        };

    return (
        <Page title="Organisations">
            <div className="grid gap-6 lg:grid-cols-3">
                <Card title="Créer une organisation">
                    <form
                        onSubmit={submit(orgForm, '/admin/organizations')}
                        className="grid gap-2"
                    >
                        <select
                            className={input}
                            value={orgForm.data.type}
                            onChange={(e) =>
                                orgForm.setData('type', e.target.value)
                            }
                        >
                            <option value="enterprise">Entreprise</option>
                            <option value="station">Station</option>
                        </select>
                        <input
                            className={input}
                            placeholder="Nom de l'organisation"
                            value={orgForm.data.name}
                            onChange={(e) =>
                                orgForm.setData('name', e.target.value)
                            }
                        />
                        <input
                            className={input}
                            placeholder="Nom de l'admin"
                            value={orgForm.data.admin_name}
                            onChange={(e) =>
                                orgForm.setData('admin_name', e.target.value)
                            }
                        />
                        <input
                            className={input}
                            placeholder="Email admin"
                            value={orgForm.data.admin_email}
                            onChange={(e) =>
                                orgForm.setData('admin_email', e.target.value)
                            }
                        />
                        <input
                            type="password"
                            className={input}
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
                                    orgForm.setData('is_demo', e.target.checked)
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
                </Card>

                <Card title="Créditer un compte carburant">
                    <form
                        onSubmit={submit(creditForm, '/admin/fuel-credits')}
                        className="grid gap-2"
                    >
                        <select
                            className={input}
                            value={creditForm.data.organization_id}
                            onChange={(e) =>
                                creditForm.setData(
                                    'organization_id',
                                    e.target.value,
                                )
                            }
                        >
                            <option value="">— Entreprise —</option>
                            {enterprises.map((o) => (
                                <option key={o.id} value={o.id}>
                                    {o.name} ({o.code})
                                </option>
                            ))}
                        </select>
                        <input
                            className={input}
                            placeholder="Montant FCFA"
                            value={creditForm.data.amount}
                            onChange={(e) =>
                                creditForm.setData('amount', e.target.value)
                            }
                        />
                        <input
                            className={input}
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
                </Card>

                <Card title="Autoriser une station">
                    <form
                        onSubmit={submit(
                            authForm,
                            '/admin/authorized-stations',
                        )}
                        className="grid gap-2"
                    >
                        <Field label="Entreprise">
                            <select
                                className={input}
                                value={authForm.data.enterprise_organization_id}
                                onChange={(e) =>
                                    authForm.setData(
                                        'enterprise_organization_id',
                                        e.target.value,
                                    )
                                }
                            >
                                <option value="">—</option>
                                {enterprises.map((o) => (
                                    <option key={o.id} value={o.id}>
                                        {o.name}
                                    </option>
                                ))}
                            </select>
                        </Field>
                        <Field label="Station">
                            <select
                                className={input}
                                value={authForm.data.station_organization_id}
                                onChange={(e) =>
                                    authForm.setData(
                                        'station_organization_id',
                                        e.target.value,
                                    )
                                }
                            >
                                <option value="">—</option>
                                {stations.map((o) => (
                                    <option key={o.id} value={o.id}>
                                        {o.name}
                                    </option>
                                ))}
                            </select>
                        </Field>
                        <button
                            type="submit"
                            disabled={authForm.processing}
                            className="rounded bg-primary px-3 py-2 text-primary-foreground"
                        >
                            Autoriser
                        </button>
                        <ul className="mt-2 text-xs text-muted-foreground">
                            {authorizations.map((a) => (
                                <li key={a.id}>
                                    {a.enterprise} → {a.station}
                                </li>
                            ))}
                        </ul>
                    </form>
                </Card>
            </div>

            <Card title="Toutes les organisations">
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
                                {o.balance === null ? '—' : num(o.balance)}
                            </td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

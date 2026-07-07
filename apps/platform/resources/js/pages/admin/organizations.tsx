import { Link, router, useForm } from '@inertiajs/react';
import { useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import {
    Badge,
    Btn,
    Chip,
    Field,
    fcfa,
    Input,
    Note,
    Page,
    PageHead,
    SearchMini,
    Seg,
    Select,
    Table,
} from '@/components/fusy';
import { ConfirmButton } from '@/components/overlays';

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

type OrgFilter = 'all' | 'enterprise' | 'station';

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

    const [filter, setFilter] = useState<OrgFilter>('all');
    const [q, setQ] = useState('');

    const rows = useMemo(() => {
        const needle = q.trim().toLowerCase();

        return organizations.filter((o) => {
            if (filter !== 'all' && o.type !== filter) {
                return false;
            }

            if (!needle) {
                return true;
            }

            return `${o.name} ${o.code}`.toLowerCase().includes(needle);
        });
    }, [organizations, filter, q]);

    return (
        <Page title="Organisations">
            <PageHead
                title="Organisations"
                sub="Créer et administrer entreprises et stations, créditer les comptes carburant et gérer les autorisations."
            />

            <div className="stack">
                <div className="cols-3 grid">
                    <form
                        className="card"
                        onSubmit={submit(orgForm, '/admin/organizations')}
                    >
                        <div className="card-h">
                            <h3>Créer une organisation</h3>
                        </div>
                        <div className="card-p">
                            <Field label="Type" required>
                                <Select
                                    value={orgForm.data.type}
                                    onChange={(e) =>
                                        orgForm.setData('type', e.target.value)
                                    }
                                >
                                    <option value="enterprise">
                                        Entreprise
                                    </option>
                                    <option value="station">Station</option>
                                </Select>
                            </Field>
                            <Field
                                label="Nom"
                                required
                                error={orgForm.errors.name}
                            >
                                <Input
                                    placeholder="Ex. Sahel Distribution"
                                    value={orgForm.data.name}
                                    error={!!orgForm.errors.name}
                                    onChange={(e) =>
                                        orgForm.setData('name', e.target.value)
                                    }
                                />
                            </Field>
                            <div className="form-grid">
                                <Field
                                    label="Nom de l'admin"
                                    error={orgForm.errors.admin_name}
                                >
                                    <Input
                                        placeholder="Prénom Nom"
                                        value={orgForm.data.admin_name}
                                        error={!!orgForm.errors.admin_name}
                                        onChange={(e) =>
                                            orgForm.setData(
                                                'admin_name',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                                <Field
                                    label="Email de l'admin"
                                    error={orgForm.errors.admin_email}
                                >
                                    <Input
                                        type="email"
                                        placeholder="admin@org.cm"
                                        value={orgForm.data.admin_email}
                                        error={!!orgForm.errors.admin_email}
                                        onChange={(e) =>
                                            orgForm.setData(
                                                'admin_email',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                            </div>
                            <Field
                                label="Mot de passe temporaire"
                                error={orgForm.errors.admin_password}
                            >
                                <Input
                                    type="password"
                                    value={orgForm.data.admin_password}
                                    error={!!orgForm.errors.admin_password}
                                    onChange={(e) =>
                                        orgForm.setData(
                                            'admin_password',
                                            e.target.value,
                                        )
                                    }
                                />
                            </Field>
                            <label className="check mb-3">
                                <input
                                    type="checkbox"
                                    checked={orgForm.data.is_demo}
                                    onChange={(e) =>
                                        orgForm.setData(
                                            'is_demo',
                                            e.target.checked,
                                        )
                                    }
                                />
                                Compte de démonstration
                            </label>
                            <Btn
                                type="submit"
                                className="w-full justify-center"
                                loading={orgForm.processing}
                                disabled={orgForm.processing}
                            >
                                Créer l'organisation
                            </Btn>
                        </div>
                    </form>

                    <form
                        className="card"
                        onSubmit={submit(creditForm, '/admin/fuel-credits')}
                    >
                        <div className="card-h">
                            <h3>Créditer un compte carburant</h3>
                        </div>
                        <div className="card-p">
                            <Note className="mb-[14px]">
                                Action financière sensible — crédite de l'argent
                                réel.
                            </Note>
                            <Field
                                label="Entreprise"
                                required
                                error={creditForm.errors.organization_id}
                            >
                                <Select
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
                                </Select>
                            </Field>
                            <Field
                                label="Montant (FCFA)"
                                required
                                error={creditForm.errors.amount}
                            >
                                <Input
                                    className="tnum"
                                    inputMode="numeric"
                                    placeholder="Ex. 1 000 000"
                                    value={creditForm.data.amount}
                                    error={!!creditForm.errors.amount}
                                    onChange={(e) =>
                                        creditForm.setData(
                                            'amount',
                                            e.target.value,
                                        )
                                    }
                                />
                            </Field>
                            <Field
                                label="Description"
                                error={creditForm.errors.description}
                            >
                                <Input
                                    placeholder="Réf. virement / motif"
                                    value={creditForm.data.description}
                                    onChange={(e) =>
                                        creditForm.setData(
                                            'description',
                                            e.target.value,
                                        )
                                    }
                                />
                            </Field>
                            <Btn
                                type="submit"
                                variant="green"
                                className="w-full justify-center"
                                loading={creditForm.processing}
                                disabled={creditForm.processing}
                            >
                                Créditer le compte
                            </Btn>
                        </div>
                    </form>

                    <form
                        className="card"
                        onSubmit={submit(
                            authForm,
                            '/admin/authorized-stations',
                        )}
                    >
                        <div className="card-h">
                            <h3>Autoriser une station</h3>
                        </div>
                        <div className="card-p">
                            <Field
                                label="Entreprise"
                                required
                                error={
                                    authForm.errors.enterprise_organization_id
                                }
                            >
                                <Select
                                    value={
                                        authForm.data.enterprise_organization_id
                                    }
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
                                </Select>
                            </Field>
                            <Field
                                label="Station"
                                required
                                error={authForm.errors.station_organization_id}
                            >
                                <Select
                                    value={
                                        authForm.data.station_organization_id
                                    }
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
                                </Select>
                            </Field>
                            <Btn
                                type="submit"
                                className="mb-[14px] w-full justify-center"
                                loading={authForm.processing}
                                disabled={authForm.processing}
                            >
                                Autoriser
                            </Btn>
                            <div className="sub mb-2 font-semibold">
                                Autorisations existantes (
                                {authorizations.length})
                            </div>
                            <div className="flex flex-col gap-[7px]">
                                {authorizations.map((a) => (
                                    <Chip key={a.id}>
                                        {a.enterprise} →{' '}
                                        <b className="text-[var(--fg)]">
                                            {a.station}
                                        </b>
                                    </Chip>
                                ))}
                            </div>
                        </div>
                    </form>
                </div>

                <section className="card">
                    <div className="card-h">
                        <h3>Toutes les organisations</h3>
                        <span className="sub">
                            <b>{rows.length}</b> / {organizations.length}
                        </span>
                        <div className="actions">
                            <Seg
                                value={filter}
                                onChange={setFilter}
                                options={[
                                    { value: 'all', label: 'Toutes' },
                                    {
                                        value: 'enterprise',
                                        label: 'Entreprises',
                                    },
                                    { value: 'station', label: 'Stations' },
                                ]}
                            />
                            <SearchMini
                                value={q}
                                onChange={setQ}
                                placeholder="Nom, code…"
                            />
                        </div>
                    </div>
                    <Table
                        head={[
                            'Code',
                            'Type',
                            'Nom',
                            'Statut',
                            { label: 'Solde carburant', num: true },
                            '',
                        ]}
                        empty="Aucune organisation."
                    >
                        {rows.map((o) => (
                            <tr key={o.id}>
                                <td>
                                    <span className="mono font-semibold">
                                        {o.code}
                                    </span>
                                </td>
                                <td>
                                    <Chip>
                                        {o.type === 'enterprise'
                                            ? 'Entreprise'
                                            : 'Station'}
                                    </Chip>
                                    {o.is_demo && (
                                        <span className="tag-demo">Démo</span>
                                    )}
                                </td>
                                <td className="strong">
                                    {o.type === 'station' ? (
                                        <Link
                                            href={`/admin/stations/${o.id}`}
                                            className="hover:underline"
                                        >
                                            {o.name}
                                        </Link>
                                    ) : (
                                        o.name
                                    )}
                                </td>
                                <td>
                                    <Badge domain="org" value={o.status} />
                                </td>
                                <td className="num t-amount">
                                    {o.balance === null ? (
                                        <span className="sub">—</span>
                                    ) : (
                                        fcfa(o.balance)
                                    )}
                                </td>
                                <td>
                                    <div className="row-actions">
                                        <ConfirmButton
                                            variant="ghost"
                                            size="sm"
                                            icon={
                                                o.status === 'active'
                                                    ? 'pause'
                                                    : 'play'
                                            }
                                            danger={o.status === 'active'}
                                            title={
                                                o.status === 'active'
                                                    ? 'Suspendre cette organisation ?'
                                                    : 'Réactiver cette organisation ?'
                                            }
                                            description={
                                                o.status === 'active'
                                                    ? `Tous les paiements impliquant ${o.name} seront bloqués jusqu'à réactivation.`
                                                    : `${o.name} pourra de nouveau effectuer ou recevoir des paiements.`
                                            }
                                            confirmLabel={
                                                o.status === 'active'
                                                    ? 'Suspendre'
                                                    : 'Réactiver'
                                            }
                                            onConfirm={() =>
                                                router.post(
                                                    `/admin/organizations/${o.id}/toggle-status`,
                                                    {},
                                                    { preserveScroll: true },
                                                )
                                            }
                                        >
                                            {o.status === 'active'
                                                ? 'Suspendre'
                                                : 'Réactiver'}
                                        </ConfirmButton>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

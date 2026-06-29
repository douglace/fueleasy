import { router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import {
    Badge,
    Btn,
    Field,
    Icon,
    Input,
    Kpi,
    Note,
    Page,
    PageHead,
    Table,
} from '@/components/fusy';
import { ConfirmButton } from '@/components/overlays';

interface Pompiste {
    id: number;
    name: string;
    phone: string | null;
    matricule: string | null;
    status: string;
    pin_is_temporary: boolean;
}

export default function StationPompistes({
    pompistes,
}: {
    pompistes: Pompiste[];
}) {
    const form = useForm({ name: '', phone: '', matricule: '' });

    const submit = (e: FormEvent) => {
        e.preventDefault();
        form.post('/station/pompistes', {
            preserveScroll: true,
            onSuccess: () => form.reset(),
        });
    };

    const activeCount = pompistes.filter((p) => p.status === 'active').length;
    const tempCount = pompistes.filter((p) => p.pin_is_temporary).length;

    return (
        <Page title="Pompistes">
            <PageHead
                title="Pompistes"
                sub="Votre équipe à la pompe. Chaque pompiste valide les paiements Fusy avec son PIN personnel."
            />

            <div className="stack">
                <div className="cols-3 grid">
                    <form className="card span-2" onSubmit={submit}>
                        <div className="card-h">
                            <span
                                style={{
                                    width: 30,
                                    height: 30,
                                    borderRadius: 8,
                                    background: 'var(--navy-soft)',
                                    color: 'var(--navy)',
                                    display: 'grid',
                                    placeItems: 'center',
                                }}
                            >
                                <Icon name="plus" size={16} />
                            </span>
                            <h3>Ajouter un pompiste</h3>
                        </div>
                        <div className="card-p">
                            <div className="form-grid">
                                <Field
                                    label="Nom complet"
                                    required
                                    error={form.errors.name}
                                >
                                    <Input
                                        placeholder="Prénom Nom"
                                        value={form.data.name}
                                        error={Boolean(form.errors.name)}
                                        onChange={(e) =>
                                            form.setData('name', e.target.value)
                                        }
                                    />
                                </Field>
                                <Field
                                    label="Téléphone"
                                    error={form.errors.phone}
                                >
                                    <Input
                                        className="tnum"
                                        inputMode="tel"
                                        placeholder="+237 6 .. .. .. .."
                                        value={form.data.phone}
                                        onChange={(e) =>
                                            form.setData(
                                                'phone',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                                <Field
                                    label="Matricule"
                                    error={form.errors.matricule}
                                >
                                    <Input
                                        className="mono"
                                        placeholder="PP-00"
                                        value={form.data.matricule}
                                        onChange={(e) =>
                                            form.setData(
                                                'matricule',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                            </div>
                            <Note className="mt-1 mb-[14px]">
                                Un <b>PIN temporaire</b> sera généré —
                                communiquez-le au pompiste pour son premier
                                accès.
                            </Note>
                            <Btn
                                type="submit"
                                icon="plus"
                                loading={form.processing}
                                disabled={form.processing}
                            >
                                Créer le pompiste
                            </Btn>
                        </div>
                    </form>

                    <div className="stack">
                        <Kpi
                            icon="users"
                            label="Pompistes actifs"
                            value={activeCount}
                            foot={`sur ${pompistes.length} au total`}
                        />
                        <Kpi
                            icon="key"
                            variant="accent-warn"
                            label="PIN temporaires"
                            value={tempCount}
                            foot="en attente de changement"
                        />
                    </div>
                </div>

                <section className="card">
                    <div className="card-h">
                        <h3>Équipe</h3>
                        <span className="sub">
                            <b>{pompistes.length}</b> pompistes
                        </span>
                    </div>
                    <Table
                        head={['Pompiste', 'Statut', '']}
                        empty="Aucun pompiste."
                    >
                        {pompistes.map((u) => (
                            <tr key={u.id}>
                                <td>
                                    <div className="strong">{u.name}</div>
                                    <div className="sub mono">
                                        {u.matricule ?? '—'}
                                        {u.phone ? ` · ${u.phone}` : ''}
                                    </div>
                                </td>
                                <td>
                                    <span
                                        style={{
                                            display: 'inline-flex',
                                            alignItems: 'center',
                                            gap: 6,
                                        }}
                                    >
                                        <Badge domain="org" value={u.status} />
                                        {u.pin_is_temporary && (
                                            <span
                                                className="tag-demo"
                                                style={{
                                                    background:
                                                        'var(--warn-bg)',
                                                    color: 'var(--warn)',
                                                }}
                                            >
                                                PIN temp
                                            </span>
                                        )}
                                    </span>
                                </td>
                                <td>
                                    <div className="row-actions">
                                        <ConfirmButton
                                            variant="ghost"
                                            size="sm"
                                            icon="key"
                                            title="Réinitialiser le PIN ?"
                                            description={`Un nouveau PIN temporaire sera généré pour ${u.name}.`}
                                            confirmLabel="Réinitialiser"
                                            onConfirm={() =>
                                                router.post(
                                                    `/station/pompistes/${u.id}/reset-pin`,
                                                    {},
                                                    { preserveScroll: true },
                                                )
                                            }
                                        >
                                            Reset PIN
                                        </ConfirmButton>
                                        <ConfirmButton
                                            variant="ghost"
                                            size="sm"
                                            icon={
                                                u.status === 'active'
                                                    ? 'pause'
                                                    : 'play'
                                            }
                                            danger={u.status === 'active'}
                                            title={
                                                u.status === 'active'
                                                    ? 'Suspendre ce pompiste ?'
                                                    : 'Réactiver ce pompiste ?'
                                            }
                                            description={
                                                u.status === 'active'
                                                    ? `${u.name} ne pourra plus valider de paiement jusqu'à réactivation.`
                                                    : `${u.name} pourra de nouveau valider des paiements.`
                                            }
                                            confirmLabel={
                                                u.status === 'active'
                                                    ? 'Suspendre'
                                                    : 'Réactiver'
                                            }
                                            onConfirm={() =>
                                                router.post(
                                                    `/station/pompistes/${u.id}/suspend`,
                                                    {},
                                                    { preserveScroll: true },
                                                )
                                            }
                                        >
                                            {u.status === 'active'
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

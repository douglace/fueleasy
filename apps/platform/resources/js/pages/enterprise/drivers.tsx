import { router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { useState } from 'react';
import {
    Badge,
    BudgetBar,
    Btn,
    Field,
    Icon,
    Input,
    Note,
    Page,
    PageHead,
    Select,
    Table,
} from '@/components/fusy';
import { ConfirmButton, Drawer } from '@/components/overlays';

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

const MODE_LABEL: Record<string, string> = {
    manual: 'Manuel',
    weekly: 'Hebdo',
    monthly: 'Mensuel',
};

export default function EnterpriseDrivers({ drivers }: { drivers: Driver[] }) {
    const driverForm = useForm({ name: '', phone: '', matricule: '' });
    const [editing, setEditing] = useState<Driver | null>(null);
    const [mode, setMode] = useState('manual');
    const [amount, setAmount] = useState('');

    const submitDriver = (e: FormEvent) => {
        e.preventDefault();
        driverForm.post('/enterprise/drivers', {
            preserveScroll: true,
            onSuccess: () => driverForm.reset(),
        });
    };

    const openBudget = (d: Driver) => {
        setEditing(d);
        setMode(d.budget?.mode ?? 'manual');
        setAmount(d.budget ? String(d.budget.amount) : '');
    };

    const saveBudget = () => {
        if (!editing) {
            return;
        }

        router.post(
            `/enterprise/drivers/${editing.id}/budget`,
            { mode, amount },
            { preserveScroll: true, onSuccess: () => setEditing(null) },
        );
    };

    const resetBudget = () => {
        if (!editing) {
            return;
        }

        router.post(
            `/enterprise/drivers/${editing.id}/budget/reset`,
            {},
            { preserveScroll: true, onSuccess: () => setEditing(null) },
        );
    };

    return (
        <Page title="Chauffeurs">
            <PageHead
                title="Chauffeurs"
                sub="Gérez vos chauffeurs et leurs budgets carburant. Le budget est une enveloppe d'autorisation — il ne déplace pas l'argent du solde tant qu'aucun paiement n'a lieu."
            />

            <div className="stack">
                <section className="card">
                    <div className="card-h">
                        <span className="grid size-[30px] place-items-center rounded-lg bg-[var(--navy-soft)] text-[var(--navy)]">
                            <Icon name="plus" size={16} />
                        </span>
                        <h3>Ajouter un chauffeur</h3>
                    </div>
                    <div className="card-p">
                        <form onSubmit={submitDriver}>
                            <div className="form-grid">
                                <Field
                                    label="Nom complet"
                                    required
                                    error={driverForm.errors.name}
                                >
                                    <Input
                                        placeholder="Prénom Nom"
                                        value={driverForm.data.name}
                                        error={!!driverForm.errors.name}
                                        onChange={(e) =>
                                            driverForm.setData(
                                                'name',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                                <Field
                                    label="Téléphone"
                                    error={driverForm.errors.phone}
                                >
                                    <Input
                                        className="tnum"
                                        inputMode="tel"
                                        placeholder="+237 6 .. .. .. .."
                                        value={driverForm.data.phone}
                                        error={!!driverForm.errors.phone}
                                        onChange={(e) =>
                                            driverForm.setData(
                                                'phone',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                                <Field
                                    label="Matricule"
                                    error={driverForm.errors.matricule}
                                >
                                    <Input
                                        className="mono"
                                        placeholder="TS-000"
                                        value={driverForm.data.matricule}
                                        error={!!driverForm.errors.matricule}
                                        onChange={(e) =>
                                            driverForm.setData(
                                                'matricule',
                                                e.target.value,
                                            )
                                        }
                                    />
                                </Field>
                            </div>
                            <Note className="my-[14px]">
                                Un <b>PIN temporaire</b> sera généré à la
                                création — communiquez-le au chauffeur, il devra
                                le changer au premier paiement.
                            </Note>
                            <Btn
                                type="submit"
                                icon="plus"
                                loading={driverForm.processing}
                            >
                                Créer le chauffeur
                            </Btn>
                        </form>
                    </div>
                </section>

                <section className="card">
                    <div className="card-h">
                        <h3>Tous les chauffeurs</h3>
                        <span className="sub">
                            <b>{drivers.length}</b> chauffeur(s)
                        </span>
                    </div>
                    <Table
                        head={[
                            'Nom',
                            'Identifiant',
                            'Budget',
                            'Statut',
                            'Actions',
                        ]}
                        empty="Aucun chauffeur pour le moment."
                    >
                        {drivers.map((d) => (
                            <tr key={d.id}>
                                <td className="strong">{d.name}</td>
                                <td>
                                    <span className="mono">
                                        {d.phone ?? d.matricule ?? '—'}
                                    </span>
                                </td>
                                <td style={{ minWidth: 230 }}>
                                    {d.budget ? (
                                        <BudgetBar
                                            balance={d.budget.balance}
                                            amount={d.budget.amount}
                                            mode={MODE_LABEL[d.budget.mode]}
                                        />
                                    ) : (
                                        <span className="sub">—</span>
                                    )}
                                </td>
                                <td>
                                    <Badge domain="org" value={d.status} />
                                    {d.pin_is_temporary && (
                                        <Badge tone="warn">PIN temp</Badge>
                                    )}
                                </td>
                                <td>
                                    <div className="row-actions">
                                        <Btn
                                            variant="ghost"
                                            size="sm"
                                            icon="wallet"
                                            onClick={() => openBudget(d)}
                                        >
                                            Budget
                                        </Btn>
                                        <ConfirmButton
                                            variant="ghost"
                                            size="sm"
                                            icon="key"
                                            title="Réinitialiser le PIN ?"
                                            description={`Un nouveau PIN temporaire sera généré pour ${d.name}.`}
                                            confirmLabel="Réinitialiser"
                                            onConfirm={() =>
                                                router.post(
                                                    `/enterprise/drivers/${d.id}/reset-pin`,
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
                                                d.status === 'active'
                                                    ? 'pause'
                                                    : 'play'
                                            }
                                            danger={d.status === 'active'}
                                            title={
                                                d.status === 'active'
                                                    ? 'Suspendre ce chauffeur ?'
                                                    : 'Réactiver ce chauffeur ?'
                                            }
                                            description={
                                                d.status === 'active'
                                                    ? `${d.name} ne pourra plus payer à la pompe jusqu'à réactivation.`
                                                    : `${d.name} pourra de nouveau payer à la pompe.`
                                            }
                                            confirmLabel={
                                                d.status === 'active'
                                                    ? 'Suspendre'
                                                    : 'Réactiver'
                                            }
                                            onConfirm={() =>
                                                router.post(
                                                    `/enterprise/drivers/${d.id}/suspend`,
                                                    {},
                                                    { preserveScroll: true },
                                                )
                                            }
                                        >
                                            {d.status === 'active'
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

            <Drawer
                open={editing !== null}
                onClose={() => setEditing(null)}
                title={editing ? `Budget — ${editing.name}` : 'Budget'}
            >
                <Note className="mb-4">
                    Le budget est une <b>autorisation de dépense</b>. Il limite
                    ce que le chauffeur peut payer ; l'argent réel reste sur le
                    solde de l'entreprise jusqu'au paiement.
                </Note>
                <Field label="Mode de renouvellement">
                    <Select
                        value={mode}
                        onChange={(e) => setMode(e.target.value)}
                    >
                        <option value="manual">Manuel</option>
                        <option value="weekly">Hebdo</option>
                        <option value="monthly">Mensuel</option>
                    </Select>
                </Field>
                <Field label="Montant alloué (FCFA)" required>
                    <Input
                        className="tnum"
                        inputMode="numeric"
                        placeholder="Ex. 120000"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                    />
                </Field>
                <div className="form-foot">
                    <Btn variant="ghost" icon="refund" onClick={resetBudget}>
                        Réinitialiser
                    </Btn>
                    <Btn icon="check" onClick={saveBudget}>
                        Enregistrer
                    </Btn>
                </div>
            </Drawer>
        </Page>
    );
}

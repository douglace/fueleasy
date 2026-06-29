import { router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import {
    Badge,
    Btn,
    Chip,
    Field,
    FUEL,
    Icon,
    Input,
    Kpi,
    Page,
    PageHead,
    Table,
} from '@/components/fusy';
import { ConfirmButton } from '@/components/overlays';

interface Pump {
    id: number;
    label: string;
    status: string;
    fixed_qr_active: boolean;
    available_fuels: string[];
}

interface Props {
    pumps: Pump[];
    fuels: { value: string; label: string }[];
}

export default function StationPumps({ pumps, fuels }: Props) {
    const pumpForm = useForm<{ label: string; available_fuels: string[] }>({
        label: '',
        available_fuels: [],
    });

    const submit = (e: FormEvent) => {
        e.preventDefault();
        pumpForm.post('/station/pumps', {
            preserveScroll: true,
            onSuccess: () => pumpForm.reset(),
        });
    };

    const toggleFuel = (value: string) => {
        const cur = pumpForm.data.available_fuels;
        pumpForm.setData(
            'available_fuels',
            cur.includes(value)
                ? cur.filter((f) => f !== value)
                : [...cur, value],
        );
    };

    const qrActive = pumps.filter((p) => p.fixed_qr_active).length;
    const inService = pumps.filter((p) => p.status === 'active').length;

    return (
        <Page title="Pompes">
            <PageHead
                title="Pompes"
                sub="Configurez vos pompes, les carburants disponibles et le QR fixe de paiement Fusy."
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
                            <h3>Ajouter une pompe</h3>
                        </div>
                        <div className="card-p">
                            <Field label="Libellé" required>
                                <Input
                                    placeholder="Ex. Pompe 5"
                                    value={pumpForm.data.label}
                                    error={Boolean(pumpForm.errors.label)}
                                    onChange={(e) =>
                                        pumpForm.setData(
                                            'label',
                                            e.target.value,
                                        )
                                    }
                                />
                            </Field>
                            <Field
                                label="Carburants disponibles"
                                required
                                error={pumpForm.errors.available_fuels}
                            >
                                <div
                                    style={{
                                        display: 'flex',
                                        gap: 8,
                                        flexWrap: 'wrap',
                                        marginTop: 4,
                                    }}
                                >
                                    {fuels.map((f) => (
                                        <label key={f.value} className="check">
                                            <input
                                                type="checkbox"
                                                checked={pumpForm.data.available_fuels.includes(
                                                    f.value,
                                                )}
                                                onChange={() =>
                                                    toggleFuel(f.value)
                                                }
                                            />
                                            {f.label}
                                        </label>
                                    ))}
                                </div>
                            </Field>
                            <Btn
                                type="submit"
                                icon="plus"
                                loading={pumpForm.processing}
                                disabled={pumpForm.processing}
                            >
                                Ajouter la pompe
                            </Btn>
                        </div>
                    </form>

                    <div className="stack">
                        <Kpi
                            icon="qr"
                            variant="accent-green"
                            label="QR fixes actifs"
                            value={qrActive}
                            foot="pompes prêtes au paiement"
                        />
                        <Kpi
                            icon="fuel"
                            label="Pompes en service"
                            value={inService}
                            foot={`sur ${pumps.length} installées`}
                        />
                    </div>
                </div>

                <section className="card">
                    <div className="card-h">
                        <h3>Toutes les pompes</h3>
                        <span className="sub">
                            <b>{pumps.length}</b> pompes
                        </span>
                    </div>
                    <Table
                        head={['Pompe', 'Carburants', 'État', 'QR fixe', '']}
                        empty="Aucune pompe."
                    >
                        {pumps.map((p) => (
                            <tr key={p.id}>
                                <td className="strong">{p.label}</td>
                                <td>
                                    {p.available_fuels.length ? (
                                        <div
                                            style={{
                                                display: 'flex',
                                                gap: 6,
                                                flexWrap: 'wrap',
                                            }}
                                        >
                                            {p.available_fuels.map((f) => (
                                                <Chip key={f}>
                                                    {FUEL[f] ?? f}
                                                </Chip>
                                            ))}
                                        </div>
                                    ) : (
                                        <span className="muted">—</span>
                                    )}
                                </td>
                                <td>
                                    <Badge domain="pump" value={p.status} />
                                </td>
                                <td>
                                    {p.fixed_qr_active ? (
                                        <Badge tone="ok">QR actif</Badge>
                                    ) : (
                                        <Badge tone="neutral">
                                            QR désactivé
                                        </Badge>
                                    )}
                                </td>
                                <td>
                                    <div className="row-actions">
                                        <ConfirmButton
                                            variant="ghost"
                                            size="sm"
                                            icon="qr"
                                            title={
                                                p.fixed_qr_active
                                                    ? 'Désactiver le QR fixe ?'
                                                    : 'Activer le QR fixe ?'
                                            }
                                            description={
                                                p.fixed_qr_active
                                                    ? `Le QR fixe de ${p.label} ne pourra plus être scanné pour payer.`
                                                    : `Le QR fixe de ${p.label} pourra de nouveau être scanné pour payer.`
                                            }
                                            confirmLabel={
                                                p.fixed_qr_active
                                                    ? 'Désactiver'
                                                    : 'Activer'
                                            }
                                            onConfirm={() =>
                                                router.post(
                                                    `/station/pumps/${p.id}/toggle-qr`,
                                                    {},
                                                    { preserveScroll: true },
                                                )
                                            }
                                        >
                                            {p.fixed_qr_active
                                                ? 'Désactiver le QR'
                                                : 'Activer le QR'}
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

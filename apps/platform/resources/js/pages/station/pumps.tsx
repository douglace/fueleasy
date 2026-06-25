import { router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { Card, Page, Table } from '@/components/fusy';

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

const input = 'rounded border border-border bg-background p-2';

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

    return (
        <Page title="Pompes">
            <Card title="Ajouter une pompe">
                <form onSubmit={submit} className="grid max-w-md gap-2">
                    <input
                        className={input}
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
            </Card>

            <Card title={`${pumps.length} pompe(s)`}>
                <Table head={['Pompe', 'Carburants', 'QR fixe', 'Action']}>
                    {pumps.map((p) => (
                        <tr key={p.id} className="border-t border-border">
                            <td className="p-2">{p.label}</td>
                            <td className="p-2">
                                {p.available_fuels.join(', ')}
                            </td>
                            <td className="p-2">
                                {p.fixed_qr_active ? 'actif' : 'désactivé'}
                            </td>
                            <td className="p-2">
                                <button
                                    onClick={() =>
                                        router.post(
                                            `/station/pumps/${p.id}/toggle-qr`,
                                            {},
                                            { preserveScroll: true },
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
                </Table>
            </Card>
        </Page>
    );
}

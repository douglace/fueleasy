import { router, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { Card, Page, Table } from '@/components/fusy';

interface Pompiste {
    id: number;
    name: string;
    phone: string | null;
    matricule: string | null;
    status: string;
    pin_is_temporary: boolean;
}

const input = 'rounded border border-border bg-background p-2';

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

    return (
        <Page title="Pompistes">
            <Card title="Ajouter un pompiste">
                <form onSubmit={submit} className="flex flex-wrap gap-2">
                    <input
                        className={input}
                        placeholder="Nom"
                        value={form.data.name}
                        onChange={(e) => form.setData('name', e.target.value)}
                    />
                    <input
                        className={input}
                        placeholder="Téléphone"
                        value={form.data.phone}
                        onChange={(e) => form.setData('phone', e.target.value)}
                    />
                    <input
                        className={input}
                        placeholder="Matricule"
                        value={form.data.matricule}
                        onChange={(e) =>
                            form.setData('matricule', e.target.value)
                        }
                    />
                    <button
                        type="submit"
                        disabled={form.processing}
                        className="rounded bg-primary px-3 py-2 text-primary-foreground"
                    >
                        Créer
                    </button>
                </form>
                <p className="mt-2 text-xs text-muted-foreground">
                    Le PIN temporaire est affiché après création.
                </p>
            </Card>

            <Card title={`${pompistes.length} pompiste(s)`}>
                <Table head={['Nom', 'Identifiant', 'Statut', 'Actions']}>
                    {pompistes.map((u) => (
                        <tr key={u.id} className="border-t border-border">
                            <td className="p-2">{u.name}</td>
                            <td className="p-2">
                                {u.phone ?? u.matricule ?? '—'}
                            </td>
                            <td className="p-2">
                                {u.status}
                                {u.pin_is_temporary ? ' · PIN temp' : ''}
                            </td>
                            <td className="p-2">
                                <span className="flex gap-2 text-xs">
                                    <button
                                        onClick={() =>
                                            router.post(
                                                `/station/pompistes/${u.id}/reset-pin`,
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
                                                `/station/pompistes/${u.id}/suspend`,
                                                {},
                                                { preserveScroll: true },
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
                </Table>
            </Card>
        </Page>
    );
}

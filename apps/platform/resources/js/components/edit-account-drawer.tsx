import { useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { Btn, Field, Input } from '@/components/fusy';
import { Drawer } from '@/components/overlays';

export interface EditableAccount {
    id: number;
    name: string;
    phone: string | null;
    matricule: string | null;
}

/**
 * Drawer d'édition d'une fiche chauffeur ou pompiste (nom, téléphone,
 * matricule). Monter avec key={account.id} pour réinitialiser le formulaire
 * quand la fiche change.
 */
export function EditAccountDrawer({
    account,
    url,
    title,
    onClose,
}: {
    account: EditableAccount;
    url: string;
    title: string;
    onClose: () => void;
}) {
    const form = useForm({
        name: account.name,
        phone: account.phone ?? '',
        matricule: account.matricule ?? '',
    });

    const submit = (e: FormEvent) => {
        e.preventDefault();
        form.patch(url, {
            preserveScroll: true,
            onSuccess: onClose,
        });
    };

    return (
        <Drawer open onClose={onClose} title={title}>
            <form onSubmit={submit}>
                <Field label="Nom complet" required error={form.errors.name}>
                    <Input
                        value={form.data.name}
                        error={Boolean(form.errors.name)}
                        onChange={(e) => form.setData('name', e.target.value)}
                    />
                </Field>
                <Field label="Téléphone" error={form.errors.phone}>
                    <Input
                        className="tnum"
                        inputMode="tel"
                        placeholder="+237 6 .. .. .. .."
                        value={form.data.phone}
                        error={Boolean(form.errors.phone)}
                        onChange={(e) => form.setData('phone', e.target.value)}
                    />
                </Field>
                <Field label="Matricule" error={form.errors.matricule}>
                    <Input
                        className="mono"
                        value={form.data.matricule}
                        error={Boolean(form.errors.matricule)}
                        onChange={(e) =>
                            form.setData('matricule', e.target.value)
                        }
                    />
                </Field>
                <div className="mt-3 flex gap-2">
                    <Btn
                        type="submit"
                        icon="check"
                        loading={form.processing}
                        disabled={form.processing}
                    >
                        Enregistrer
                    </Btn>
                    <Btn type="button" variant="ghost" onClick={onClose}>
                        Annuler
                    </Btn>
                </div>
            </form>
        </Drawer>
    );
}

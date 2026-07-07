import { usePage } from '@inertiajs/react';
import { toast } from 'sonner';
import { Icon } from '@/components/fusy';
import type { Auth } from '@/types/auth';

/**
 * Encart affichant le code de connexion de l'organisation courante (entreprise
 * ou station). C'est le « Code entreprise » que le chauffeur/pompiste saisit sur
 * l'écran de connexion de l'app mobile, avec son identifiant et son PIN temporaire.
 */
export function ConnectionCode({
    subject,
}: {
    subject: 'chauffeur' | 'pompiste';
}) {
    const { auth } = usePage<{ auth: Auth }>().props;
    const code = auth.organization?.code ?? null;

    if (!code) {
        return null;
    }

    const copy = () => {
        navigator.clipboard?.writeText(code);
        toast.success(`Code copié : ${code}`);
    };

    return (
        <section className="card">
            <div className="card-h">
                <span className="grid size-[30px] place-items-center rounded-lg bg-[var(--navy-soft)] text-[var(--navy)]">
                    <Icon name="key" size={16} />
                </span>
                <h3>Code de connexion</h3>
            </div>
            <div className="card-p stack">
                <button
                    type="button"
                    onClick={copy}
                    title="Copier le code"
                    className="mono copyable w-fit appearance-none border-0 bg-transparent p-0 text-2xl font-bold tracking-widest"
                >
                    {code}
                    <Icon name="copy" size={16} />
                </button>
                <div className="note">
                    <Icon name="info" size={18} />
                    <div>
                        C'est le <strong>code entreprise</strong> que le{' '}
                        {subject} saisit à la connexion de l'app mobile, avec
                        son <strong>téléphone ou matricule</strong> et son{' '}
                        <strong>PIN temporaire</strong> (affiché après sa
                        création).
                    </div>
                </div>
            </div>
        </section>
    );
}

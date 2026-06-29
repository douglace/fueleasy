import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { Btn, Icon } from '@/components/fusy';
import type { IconName } from '@/components/fusy';

function useEscape(open: boolean, onClose: () => void) {
    useEffect(() => {
        if (!open) {
            return;
        }

        const onKey = (e: KeyboardEvent) => {
            if (e.key === 'Escape') {
                onClose();
            }
        };
        document.addEventListener('keydown', onKey);

        return () => document.removeEventListener('keydown', onKey);
    }, [open, onClose]);
}

/* ---------------------------------------------------------------------------
   Modal de confirmation (ton navy ou danger)
   ------------------------------------------------------------------------- */
export function Modal({
    open,
    onClose,
    icon,
    title,
    subtitle,
    danger,
    confirmLabel = 'Confirmer',
    cancelLabel = 'Annuler',
    onConfirm,
    children,
}: {
    open: boolean;
    onClose: () => void;
    icon?: IconName;
    title: ReactNode;
    subtitle?: ReactNode;
    danger?: boolean;
    confirmLabel?: string;
    cancelLabel?: string;
    onConfirm?: () => void;
    children?: ReactNode;
}) {
    useEscape(open, onClose);

    if (!open) {
        return null;
    }

    const tone = danger ? 'var(--destr)' : 'var(--navy)';
    const toneBg = danger ? 'var(--destr-bg)' : 'var(--navy-soft)';

    return createPortal(
        <>
            <div className="scrim show" onClick={onClose} aria-hidden />
            <div className="modal show" role="dialog" aria-modal>
                <div className="m-h">
                    {icon && (
                        <div
                            className="m-ic"
                            style={{ background: toneBg, color: tone }}
                        >
                            <Icon name={icon} size={18} />
                        </div>
                    )}
                    <div className="flex-1">
                        <h3>{title}</h3>
                        {subtitle && <p>{subtitle}</p>}
                    </div>
                </div>
                {children && <div className="m-b">{children}</div>}
                <div className="m-f">
                    <Btn variant="ghost" onClick={onClose}>
                        {cancelLabel}
                    </Btn>
                    {onConfirm && (
                        <Btn
                            variant={danger ? 'danger' : 'primary'}
                            onClick={() => {
                                onConfirm();
                                onClose();
                            }}
                        >
                            {confirmLabel}
                        </Btn>
                    )}
                </div>
            </div>
        </>,
        document.body,
    );
}

/** Bouton qui ouvre une confirmation avant d'exécuter `onConfirm`. */
export function ConfirmButton({
    children,
    variant = 'ghost',
    size,
    icon,
    title,
    description,
    danger,
    confirmLabel,
    onConfirm,
}: {
    children: ReactNode;
    variant?: 'primary' | 'ghost' | 'green' | 'danger';
    size?: 'sm';
    icon?: IconName;
    title: ReactNode;
    description?: ReactNode;
    danger?: boolean;
    confirmLabel?: string;
    onConfirm: () => void;
}) {
    const [open, setOpen] = useState(false);

    return (
        <>
            <Btn
                variant={variant}
                size={size}
                icon={icon}
                onClick={() => setOpen(true)}
            >
                {children}
            </Btn>
            <Modal
                open={open}
                onClose={() => setOpen(false)}
                icon={danger ? 'alert' : 'info'}
                title={title}
                subtitle={description}
                danger={danger}
                confirmLabel={confirmLabel}
                onConfirm={onConfirm}
            />
        </>
    );
}

/* ---------------------------------------------------------------------------
   Drawer latéral
   ------------------------------------------------------------------------- */
export function Drawer({
    open,
    onClose,
    title,
    children,
}: {
    open: boolean;
    onClose: () => void;
    title: ReactNode;
    children: ReactNode;
}) {
    useEscape(open, onClose);

    if (!open) {
        return null;
    }

    return createPortal(
        <>
            <div className="scrim show" onClick={onClose} aria-hidden />
            <div className="drawer show" role="dialog" aria-modal>
                <div className="d-h">
                    <h3 className="flex-1 text-base font-bold">{title}</h3>
                    <button
                        type="button"
                        className="icon-btn"
                        onClick={onClose}
                        aria-label="Fermer"
                    >
                        <Icon name="x" size={18} />
                    </button>
                </div>
                <div className="d-b">{children}</div>
            </div>
        </>,
        document.body,
    );
}

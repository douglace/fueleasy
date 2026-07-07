import { Head } from '@inertiajs/react';
import {
    AlarmClockCheck,
    ArrowLeftRight,
    Banknote,
    Bell,
    Building2,
    Check,
    ChevronRight,
    Clock,
    Copy,
    Download,
    Droplet,
    Filter,
    Fuel,
    Info,
    Inbox,
    KeyRound,
    LayoutGrid,
    LogOut,
    MapPin,
    Menu,
    MoreVertical,
    Pause,
    Play,
    Plus,
    QrCode,
    Receipt,
    RotateCcw,
    ScrollText,
    Search,
    Shield,
    Store,
    TriangleAlert,
    TrendingDown,
    TrendingUp,
    Users,
    Wallet,
    X,
    Zap,
} from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import type {
    ButtonHTMLAttributes,
    InputHTMLAttributes,
    ReactNode,
    SelectHTMLAttributes,
    TextareaHTMLAttributes,
} from 'react';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

/* ---------------------------------------------------------------------------
   Icônes — mapping des noms Fusy (cf. FUSY-DASH/assets/fusy.js) vers lucide-react
   ------------------------------------------------------------------------- */
export const ICONS = {
    grid: LayoutGrid,
    building: Building2,
    swap: ArrowLeftRight,
    refund: RotateCcw,
    banknote: Banknote,
    audit: ScrollText,
    users: Users,
    pin: MapPin,
    fuel: Fuel,
    receipt: Receipt,
    search: Search,
    bell: Bell,
    menu: Menu,
    x: X,
    check: Check,
    alert: TriangleAlert,
    info: Info,
    plus: Plus,
    download: Download,
    chev: ChevronRight,
    copy: Copy,
    dots: MoreVertical,
    out: LogOut,
    shield: Shield,
    up: TrendingUp,
    down: TrendingDown,
    wallet: Wallet,
    store: Store,
    clock: Clock,
    drop: Droplet,
    key: KeyRound,
    pause: Pause,
    play: Play,
    qr: QrCode,
    bolt: Zap,
    inbox: Inbox,
    filter: Filter,
    schedule: AlarmClockCheck,
} satisfies Record<string, LucideIcon>;

export type IconName = keyof typeof ICONS;

export function Icon({
    name,
    size = 18,
    className,
}: {
    name: IconName;
    size?: number;
    className?: string;
}) {
    const C = ICONS[name];

    return <C size={size} className={className} aria-hidden />;
}

/* ---------------------------------------------------------------------------
   Formatage
   ------------------------------------------------------------------------- */
export const fcfa = (n: number | null | undefined) =>
    n == null ? '—' : `${Number(n).toLocaleString('fr-FR')} FCFA`;
export const num = (n: number | null | undefined) =>
    n == null ? '—' : Number(n).toLocaleString('fr-FR');

/* ---------------------------------------------------------------------------
   Page + en-tête
   ------------------------------------------------------------------------- */
export function Page({
    title,
    children,
}: {
    title: string;
    children: ReactNode;
}) {
    return (
        <>
            <Head title={title} />
            {children}
        </>
    );
}

export function PageHead({
    title,
    sub,
    actions,
}: {
    title: string;
    sub?: ReactNode;
    actions?: ReactNode;
}) {
    return (
        <div className="page-head">
            <div>
                <h1>{title}</h1>
                {sub && <div className="sub">{sub}</div>}
            </div>
            {actions && <div className="actions">{actions}</div>}
        </div>
    );
}

/* ---------------------------------------------------------------------------
   Boutons
   ------------------------------------------------------------------------- */
type BtnVariant = 'primary' | 'ghost' | 'green' | 'danger';

export function Btn({
    variant = 'primary',
    size,
    loading,
    icon,
    className,
    children,
    ...rest
}: {
    variant?: BtnVariant;
    size?: 'sm';
    loading?: boolean;
    icon?: IconName;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
    return (
        <button
            className={cn(
                'btn',
                `btn-${variant}`,
                size === 'sm' && 'btn-sm',
                loading && 'loading',
                className,
            )}
            {...rest}
        >
            {icon && <Icon name={icon} size={size === 'sm' ? 15 : 17} />}
            {children}
        </button>
    );
}

/* ---------------------------------------------------------------------------
   Cartes
   ------------------------------------------------------------------------- */
export function Card({
    title,
    sub,
    actions,
    icon,
    bodyClassName,
    padded = true,
    className,
    children,
}: {
    title?: ReactNode;
    sub?: ReactNode;
    actions?: ReactNode;
    icon?: ReactNode;
    bodyClassName?: string;
    /** false : pas de wrapper .card-p (tables, listes pleine largeur). */
    padded?: boolean;
    className?: string;
    children: ReactNode;
}) {
    const hasHeader = title || actions || icon;

    return (
        <section className={cn('card', className)}>
            {hasHeader && (
                <div className="card-h">
                    {icon}
                    {title && <h3>{title}</h3>}
                    {sub && <span className="sub">{sub}</span>}
                    {actions && <div className="actions">{actions}</div>}
                </div>
            )}
            {padded ? (
                <div className={cn('card-p', bodyClassName)}>{children}</div>
            ) : (
                children
            )}
        </section>
    );
}

/* ---------------------------------------------------------------------------
   KPI / Stat
   ------------------------------------------------------------------------- */
export function Kpi({
    label,
    value,
    unit,
    icon,
    variant = 'default',
    foot,
    span2,
}: {
    label: ReactNode;
    value: ReactNode;
    unit?: string;
    icon?: IconName;
    variant?: 'default' | 'hero' | 'accent-green' | 'accent-warn';
    foot?: ReactNode;
    span2?: boolean;
}) {
    return (
        <div
            className={cn(
                'kpi',
                variant !== 'default' && variant,
                span2 && 'span-2',
            )}
        >
            <div className="lbl">
                {icon && (
                    <span className="ic">
                        <Icon name={icon} size={16} />
                    </span>
                )}
                {label}
            </div>
            <div className="val tnum">
                {value}
                {unit && <small>{unit}</small>}
            </div>
            {foot && <div className="foot">{foot}</div>}
        </div>
    );
}

export function Trend({
    dir,
    children,
}: {
    dir: 'up' | 'down';
    children: ReactNode;
}) {
    return (
        <span className={cn('trend', dir)}>
            <Icon name={dir} size={13} />
            {children}
        </span>
    );
}

/** Conserve l'ancien composant Stat pour compat éventuelle (boîte simple). */
export function Stat({ label, value }: { label: string; value: ReactNode }) {
    return <Kpi label={label} value={value} />;
}

/* ---------------------------------------------------------------------------
   Badges / chips — map portée depuis FUSY-DASH/assets/fusy.js
   ------------------------------------------------------------------------- */
export type BadgeTone = 'ok' | 'info' | 'warn' | 'err' | 'destr' | 'neutral';

const BADGE: Record<string, Record<string, [BadgeTone, string]>> = {
    payment: {
        pending: ['info', 'En attente'],
        paid: ['ok', 'Payé'],
        expired: ['warn', 'Expiré'],
        failed: ['err', 'Échec'],
        refunded: ['neutral', 'Remboursé'],
    },
    refund: {
        pending: ['info', 'En attente'],
        approved: ['ok', 'Approuvé'],
        rejected: ['destr', 'Refusé'],
    },
    settlement: { open: ['info', 'Ouvert'], paid: ['ok', 'Payé'] },
    org: { active: ['ok', 'Actif'], suspended: ['destr', 'Suspendu'] },
    pump: {
        active: ['ok', 'En service'],
        suspended: ['warn', 'Hors service'],
    },
};

export type BadgeDomain = keyof typeof BADGE;

export function badgeMeta(
    domain: BadgeDomain,
    value: string,
): [BadgeTone, string] {
    return BADGE[domain]?.[value] ?? ['neutral', value];
}

export function Badge({
    domain,
    value,
    tone,
    children,
}: {
    domain?: BadgeDomain;
    value?: string;
    tone?: BadgeTone;
    children?: ReactNode;
}) {
    let t: BadgeTone = tone ?? 'neutral';
    let label: ReactNode = children;

    if (domain && value) {
        const [mt, ml] = badgeMeta(domain, value);
        t = tone ?? mt;
        label = children ?? ml;
    }

    return (
        <span className={cn('badge', t)}>
            <span className="d" />
            {label}
        </span>
    );
}

export function Chip({
    icon,
    children,
}: {
    icon?: IconName;
    children: ReactNode;
}) {
    return (
        <span className="chip">
            {icon && <Icon name={icon} size={13} />}
            {children}
        </span>
    );
}

export const FUEL: Record<string, string> = {
    gasoil: 'Gasoil',
    super: 'Super sans plomb',
    petrole: 'Pétrole lampant',
};

/* ---------------------------------------------------------------------------
   Code court copiable (code paiement, code pompe…)
   ------------------------------------------------------------------------- */
export function CopyCode({ code }: { code: string | null }) {
    if (!code) {
        return <span className="muted">—</span>;
    }

    return (
        <span
            className="mono copyable font-bold"
            onClick={() => {
                navigator.clipboard?.writeText(code);
                toast.success(`Copié : ${code}`);
            }}
            title="Copier le code"
        >
            {code}
            <Icon name="copy" size={13} />
        </span>
    );
}

/* ---------------------------------------------------------------------------
   Tableau
   ------------------------------------------------------------------------- */
type Col = string | { label: string; num?: boolean };

export function Table({
    head,
    children,
    empty = 'Aucune donnée.',
}: {
    head: Col[];
    children: ReactNode;
    empty?: ReactNode;
}) {
    const rows = Array.isArray(children) ? children : [children];
    const hasRows = rows.flat().filter(Boolean).length > 0;

    return (
        <div className="tbl-wrap">
            <table className="tbl">
                <thead>
                    <tr>
                        {head.map((h, i) => {
                            const label = typeof h === 'string' ? h : h.label;
                            const isNum = typeof h !== 'string' && h.num;

                            return (
                                <th
                                    key={i}
                                    className={isNum ? 'num' : undefined}
                                >
                                    {label}
                                </th>
                            );
                        })}
                    </tr>
                </thead>
                <tbody>
                    {hasRows ? (
                        children
                    ) : (
                        <tr>
                            <td colSpan={head.length}>
                                <div className="empty">
                                    <span className="ic">
                                        <Icon name="inbox" size={22} />
                                    </span>
                                    <p>{empty}</p>
                                </div>
                            </td>
                        </tr>
                    )}
                </tbody>
            </table>
        </div>
    );
}

/* ---------------------------------------------------------------------------
   Barre de filtres (segments + recherche) — version React contrôlée
   ------------------------------------------------------------------------- */
export function Seg<T extends string>({
    value,
    onChange,
    options,
}: {
    value: T;
    onChange: (v: T) => void;
    options: { value: T; label: string }[];
}) {
    return (
        <div className="seg">
            {options.map((o) => (
                <button
                    key={o.value}
                    type="button"
                    className={value === o.value ? 'on' : undefined}
                    onClick={() => onChange(o.value)}
                >
                    {o.label}
                </button>
            ))}
        </div>
    );
}

export function SearchMini({
    value,
    onChange,
    placeholder = 'Rechercher…',
}: {
    value: string;
    onChange: (v: string) => void;
    placeholder?: string;
}) {
    return (
        <div className="search-mini">
            <Icon name="search" size={15} />
            <input
                value={value}
                placeholder={placeholder}
                onChange={(e) => onChange(e.target.value)}
            />
        </div>
    );
}

/* ---------------------------------------------------------------------------
   Formulaires
   ------------------------------------------------------------------------- */
export function Field({
    label,
    required,
    hint,
    error,
    children,
}: {
    label: ReactNode;
    required?: boolean;
    hint?: ReactNode;
    error?: ReactNode;
    children: ReactNode;
}) {
    return (
        <div className="field">
            <label>
                {label}
                {required && <span className="req"> *</span>}
            </label>
            {children}
            {hint && !error && <span className="hint">{hint}</span>}
            {error && (
                <span className="msg-err">
                    <Icon name="alert" size={13} />
                    {error}
                </span>
            )}
        </div>
    );
}

export function Input({
    className,
    error,
    ...rest
}: { error?: boolean } & InputHTMLAttributes<HTMLInputElement>) {
    return (
        <input className={cn('input', error && 'err', className)} {...rest} />
    );
}

export function Select({
    className,
    children,
    ...rest
}: SelectHTMLAttributes<HTMLSelectElement>) {
    return (
        <select className={cn('input', className)} {...rest}>
            {children}
        </select>
    );
}

export function Textarea({
    className,
    ...rest
}: TextareaHTMLAttributes<HTMLTextAreaElement>) {
    return <textarea className={cn('input', className)} {...rest} />;
}

/* ---------------------------------------------------------------------------
   Barre de budget, note, empty
   ------------------------------------------------------------------------- */
export function BudgetBar({
    balance,
    amount,
    mode,
}: {
    balance: number;
    amount: number;
    mode?: string;
}) {
    const pct = amount > 0 ? Math.min(100, (balance / amount) * 100) : 0;
    const tone = pct < 15 ? 'err' : pct < 35 ? 'warn' : '';

    return (
        <div className="budget">
            <div className="nums">
                <b className="tnum">{num(balance)}</b>
                <span className="tnum">
                    / {num(amount)} FCFA{mode ? ` · ${mode}` : ''}
                </span>
            </div>
            <div className={cn('bar', tone)}>
                <i style={{ width: `${pct}%` }} />
            </div>
        </div>
    );
}

export function Note({
    tone = 'info',
    icon = 'info',
    children,
    className,
}: {
    tone?: 'info' | 'warn';
    icon?: IconName;
    children: ReactNode;
    className?: string;
}) {
    return (
        <div className={cn('note', tone === 'warn' && 'warn', className)}>
            <Icon name={icon} size={18} />
            <div>{children}</div>
        </div>
    );
}

export function Empty({
    icon = 'inbox',
    title,
    children,
}: {
    icon?: IconName;
    title?: ReactNode;
    children?: ReactNode;
}) {
    return (
        <div className="empty">
            <span className="ic">
                <Icon name={icon} size={22} />
            </span>
            {title && <b>{title}</b>}
            {children && <p>{children}</p>}
        </div>
    );
}

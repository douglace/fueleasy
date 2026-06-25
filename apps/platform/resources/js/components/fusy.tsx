import { Head } from '@inertiajs/react';
import type { ReactNode } from 'react';

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
            <div className="flex flex-col gap-6 p-4">
                <h1 className="text-2xl font-semibold">{title}</h1>
                {children}
            </div>
        </>
    );
}

export function Card({
    title,
    actions,
    children,
}: {
    title?: string;
    actions?: ReactNode;
    children: ReactNode;
}) {
    return (
        <section className="rounded-xl border border-border p-4">
            {(title || actions) && (
                <div className="mb-3 flex items-center justify-between">
                    {title && <h2 className="font-medium">{title}</h2>}
                    {actions}
                </div>
            )}
            {children}
        </section>
    );
}

export function Stat({ label, value }: { label: string; value: ReactNode }) {
    return (
        <div className="rounded-xl border border-border p-4">
            <div className="text-sm text-muted-foreground">{label}</div>
            <div className="text-2xl font-semibold">{value}</div>
        </div>
    );
}

export function Table({
    head,
    children,
    empty = 'Aucune donnée.',
}: {
    head: string[];
    children: ReactNode;
    empty?: string;
}) {
    const rows = Array.isArray(children) ? children : [children];
    const hasRows = rows.flat().filter(Boolean).length > 0;

    return (
        <table className="w-full text-left text-sm">
            <thead>
                <tr>
                    {head.map((h) => (
                        <th key={h} className="p-2 text-muted-foreground">
                            {h}
                        </th>
                    ))}
                </tr>
            </thead>
            <tbody>
                {hasRows ? (
                    children
                ) : (
                    <tr>
                        <td
                            colSpan={head.length}
                            className="p-4 text-center text-muted-foreground"
                        >
                            {empty}
                        </td>
                    </tr>
                )}
            </tbody>
        </table>
    );
}

export function Field({
    label,
    children,
}: {
    label: string;
    children: ReactNode;
}) {
    return (
        <label className="grid gap-1 text-sm">
            <span className="text-muted-foreground">{label}</span>
            {children}
        </label>
    );
}

export const fcfa = (n: number) => `${n.toLocaleString('fr-FR')} FCFA`;
export const num = (n: number) => n.toLocaleString('fr-FR');

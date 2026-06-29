import { useMemo, useState } from 'react';
import {
    Chip,
    Page,
    PageHead,
    SearchMini,
    Select,
    Table,
} from '@/components/fusy';

interface AuditRow {
    id: number;
    action: string;
    actor: string | null;
    organization_id: number | null;
    subject_type: string | null;
    subject_id: number | null;
    created_at: string | null;
}

const subjectLabel = (a: AuditRow) =>
    a.subject_type
        ? `${a.subject_type.split('\\').pop()}#${a.subject_id}`
        : '—';

export default function AdminAudit({ audit }: { audit: AuditRow[] }) {
    const [action, setAction] = useState('all');
    const [q, setQ] = useState('');

    const actions = useMemo(
        () => [...new Set(audit.map((a) => a.action))].sort(),
        [audit],
    );

    const rows = useMemo(() => {
        const needle = q.trim().toLowerCase();

        return audit.filter((a) => {
            if (action !== 'all' && a.action !== action) {
                return false;
            }

            if (!needle) {
                return true;
            }

            return `${a.action} ${a.actor ?? ''} ${subjectLabel(a)}`
                .toLowerCase()
                .includes(needle);
        });
    }, [audit, action, q]);

    return (
        <Page title="Journal d'audit">
            <PageHead
                title="Journal d'audit"
                sub="Trace immuable des actions sensibles. L'action est l'information."
            />

            <div className="stack">
                <section className="card">
                    <div className="card-h">
                        <h3>{audit.length} entrée(s)</h3>
                        <div className="actions">
                            <Chip icon="filter">Filtrer</Chip>
                            <Select
                                value={action}
                                onChange={(e) => setAction(e.target.value)}
                                className="h-9 w-auto min-w-[190px]"
                            >
                                <option value="all">Toutes les actions</option>
                                {actions.map((a) => (
                                    <option key={a} value={a}>
                                        {a}
                                    </option>
                                ))}
                            </Select>
                            <SearchMini
                                value={q}
                                onChange={setQ}
                                placeholder="Action, acteur, sujet…"
                            />
                        </div>
                    </div>
                    <Table
                        head={[
                            'Horodatage',
                            'Action',
                            'Acteur',
                            'Organisation',
                            'Sujet',
                        ]}
                        empty="Aucune action ne correspond à ce filtre."
                    >
                        {rows.map((a) => (
                            <tr key={a.id}>
                                <td className="tnum sub whitespace-nowrap">
                                    {a.created_at ?? '—'}
                                </td>
                                <td>
                                    <span className="mono font-semibold text-[var(--fg)]">
                                        {a.action}
                                    </span>
                                </td>
                                <td>
                                    {a.actor ?? (
                                        <span className="sub">— système —</span>
                                    )}
                                </td>
                                <td>{a.organization_id ?? '—'}</td>
                                <td>
                                    <span className="mono sub">
                                        {subjectLabel(a)}
                                    </span>
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

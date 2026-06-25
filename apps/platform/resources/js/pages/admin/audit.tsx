import { Card, Page, Table } from '@/components/fusy';

interface AuditRow {
    id: number;
    action: string;
    actor: string | null;
    organization_id: number | null;
    subject_type: string | null;
    subject_id: number | null;
    created_at: string | null;
}

export default function AdminAudit({ audit }: { audit: AuditRow[] }) {
    return (
        <Page title="Journal d'audit">
            <Card title={`${audit.length} entrée(s)`}>
                <Table
                    head={['Date', 'Action', 'Acteur', 'Organisation', 'Sujet']}
                >
                    {audit.map((a) => (
                        <tr key={a.id} className="border-t border-border">
                            <td className="p-2">{a.created_at}</td>
                            <td className="p-2 font-mono">{a.action}</td>
                            <td className="p-2">{a.actor ?? '—'}</td>
                            <td className="p-2">{a.organization_id ?? '—'}</td>
                            <td className="p-2 text-muted-foreground">
                                {a.subject_type
                                    ? `${a.subject_type.split('\\').pop()}#${a.subject_id}`
                                    : '—'}
                            </td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

import { Link } from '@inertiajs/react';
import {
    Badge,
    Chip,
    CopyCode,
    FUEL,
    Page,
    PageHead,
    Table,
} from '@/components/fusy';

interface Station {
    id: number;
    name: string;
    code: string;
    status: string;
}

interface Pump {
    id: number;
    label: string;
    code: string;
    status: string;
    fixed_qr_active: boolean;
    available_fuels: string[];
}

interface Pompiste {
    id: number;
    name: string;
    phone: string | null;
    matricule: string | null;
    status: string;
}

interface Props {
    station: Station;
    pumps: Pump[];
    pompistes: Pompiste[];
}

export default function AdminStationDetail({
    station,
    pumps,
    pompistes,
}: Props) {
    return (
        <Page title={station.name}>
            <PageHead
                title={station.name}
                sub={
                    <>
                        Vue lecture seule des pompes et pompistes de la station{' '}
                        <span className="mono font-semibold">
                            {station.code}
                        </span>
                        . <Link href="/admin/organizations">← Retour</Link>
                    </>
                }
                actions={<Badge domain="org" value={station.status} />}
            />

            <div className="stack">
                <section className="card">
                    <div className="card-h">
                        <h3>Pompes</h3>
                        <span className="sub">
                            <b>{pumps.length}</b> pompes
                        </span>
                    </div>
                    <Table
                        head={[
                            'Pompe',
                            'Code pompe',
                            'Carburants',
                            'État',
                            'QR fixe',
                        ]}
                        empty="Aucune pompe."
                    >
                        {pumps.map((p) => (
                            <tr key={p.id}>
                                <td className="strong">{p.label}</td>
                                <td>
                                    <CopyCode code={p.code} />
                                </td>
                                <td>
                                    {p.available_fuels.length ? (
                                        <div className="flex flex-wrap gap-1.5">
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
                            </tr>
                        ))}
                    </Table>
                </section>

                <section className="card">
                    <div className="card-h">
                        <h3>Pompistes</h3>
                        <span className="sub">
                            <b>{pompistes.length}</b> pompistes
                        </span>
                    </div>
                    <Table
                        head={['Pompiste', 'Téléphone', 'Matricule', 'Statut']}
                        empty="Aucun pompiste."
                    >
                        {pompistes.map((u) => (
                            <tr key={u.id}>
                                <td className="strong">{u.name}</td>
                                <td className="tnum">{u.phone ?? '—'}</td>
                                <td className="mono">{u.matricule ?? '—'}</td>
                                <td>
                                    <Badge domain="org" value={u.status} />
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

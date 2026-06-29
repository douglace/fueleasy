import { Badge, Note, Page, PageHead, Table } from '@/components/fusy';

interface Station {
    id: number;
    name: string;
    code: string;
    status: string;
}

export default function EnterpriseStations({
    stations,
}: {
    stations: Station[];
}) {
    return (
        <Page title="Stations autorisées">
            <PageHead
                title="Stations autorisées"
                sub="Les stations où vos chauffeurs peuvent payer avec Fusy."
            />

            <div className="stack">
                <Note icon="shield">
                    Ces stations sont <b>définies par Fusy</b> à votre demande.
                    Vos chauffeurs ne peuvent payer que dans cette liste — toute
                    tentative ailleurs est refusée. Pour en ajouter, contactez
                    votre référent Fusy.
                </Note>

                <section className="card">
                    <div className="card-h">
                        <h3>Réseau autorisé</h3>
                        <span className="sub">
                            <b>{stations.length}</b> station(s)
                        </span>
                    </div>
                    <Table
                        head={['Code', 'Nom', 'Statut']}
                        empty="Aucune station autorisée pour le moment."
                    >
                        {stations.map((s) => (
                            <tr key={s.id}>
                                <td>
                                    <span className="mono">{s.code}</span>
                                </td>
                                <td className="strong">{s.name}</td>
                                <td>
                                    <Badge domain="org" value={s.status} />
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

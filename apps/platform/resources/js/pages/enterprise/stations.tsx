import { Card, Page, Table } from '@/components/fusy';

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
            <Card title={`${stations.length} station(s) autorisée(s)`}>
                <p className="mb-3 text-sm text-muted-foreground">
                    Les stations autorisées sont définies par Fusy. Vos
                    chauffeurs ne peuvent payer que dans ces stations.
                </p>
                <Table
                    head={['Code', 'Nom', 'Statut']}
                    empty="Aucune station autorisée pour le moment."
                >
                    {stations.map((s) => (
                        <tr key={s.id} className="border-t border-border">
                            <td className="p-2 font-mono">{s.code}</td>
                            <td className="p-2">{s.name}</td>
                            <td className="p-2">{s.status}</td>
                        </tr>
                    ))}
                </Table>
            </Card>
        </Page>
    );
}

import { Link } from '@inertiajs/react';
import { AreaFusy, DonutFusy } from '@/components/charts';
import {
    Badge,
    Chip,
    Empty,
    FUEL,
    Icon,
    Kpi,
    num,
    Page,
    PageHead,
    Table,
} from '@/components/fusy';

interface PaymentRow {
    id: number;
    reference: string;
    amount: number;
    status: string;
    fuel_type: string;
    station: string;
    created_at: string | null;
}

interface Props {
    balance: number;
    stats: {
        drivers: number;
        authorizedStations: number;
        paidPayments: number;
        spentTotal: number;
    };
    charts: {
        volume: { l: string; v: number }[];
        fuelMix: { name: string; value: number; fuel: string }[];
    };
    recentTransactions: PaymentRow[];
}

const FUEL_COLOR: Record<string, string> = {
    gasoil: 'var(--navy)',
    super: 'var(--green)',
    petrole: '#E0A93B',
};

const timeOf = (s: string | null) =>
    s
        ? new Date(s.replace(' ', 'T')).toLocaleTimeString('fr-FR', {
              hour: '2-digit',
              minute: '2-digit',
          })
        : '—';

export default function EnterpriseDashboard({
    balance,
    stats,
    charts,
    recentTransactions,
}: Props) {
    const donut = charts.fuelMix.map((f) => ({
        v: f.value,
        c: FUEL_COLOR[f.fuel] ?? 'var(--faint)',
        name: f.name,
    }));

    return (
        <Page title="Tableau de bord — Entreprise">
            <PageHead
                title="Tableau de bord"
                sub="Pilotage de votre flotte et de votre compte carburant"
            />

            <div className="stack">
                <div className="cols-4 grid">
                    <Kpi
                        icon="wallet"
                        variant="hero"
                        span2
                        label="Solde du compte carburant"
                        value={num(balance)}
                        unit="FCFA"
                        foot="argent réel prépayé · distinct des budgets chauffeurs"
                    />
                    <Kpi
                        icon="users"
                        label="Chauffeurs"
                        value={num(stats.drivers)}
                    />
                    <Kpi
                        icon="pin"
                        label="Stations autorisées"
                        value={num(stats.authorizedStations)}
                    />
                </div>

                <div className="cols-3 grid">
                    <section className="card span-2">
                        <div className="card-h">
                            <h3>Volume des paiements</h3>
                            <span className="sub">7 derniers jours · FCFA</span>
                        </div>
                        <div className="card-p">
                            <AreaFusy data={charts.volume} />
                        </div>
                    </section>

                    <div className="stack">
                        <Kpi
                            icon="check"
                            variant="accent-green"
                            label="Paiements réglés"
                            value={num(stats.paidPayments)}
                        />
                        <Kpi
                            icon="bolt"
                            label="Total dépensé"
                            value={num(stats.spentTotal)}
                            unit="FCFA"
                        />
                    </div>
                </div>

                <div className="cols-3 grid">
                    <section className="card span-2">
                        <div className="card-h">
                            <h3>Transactions récentes</h3>
                            <div className="actions">
                                <Link
                                    className="btn btn-ghost btn-sm"
                                    href="/enterprise/transactions"
                                >
                                    Tout voir <Icon name="chev" size={15} />
                                </Link>
                            </div>
                        </div>
                        <Table
                            head={[
                                'Référence',
                                'Station',
                                'Carburant',
                                { label: 'Montant', num: true },
                                'Statut',
                                'Heure',
                            ]}
                            empty="Aucune transaction."
                        >
                            {recentTransactions.map((p) => (
                                <tr key={p.id}>
                                    <td className="ref">{p.reference}</td>
                                    <td className="strong">{p.station}</td>
                                    <td>
                                        <Chip icon="drop">
                                            {FUEL[p.fuel_type] ?? p.fuel_type}
                                        </Chip>
                                    </td>
                                    <td className="num t-amount">
                                        {num(p.amount)}
                                    </td>
                                    <td>
                                        <Badge
                                            domain="payment"
                                            value={p.status}
                                        />
                                    </td>
                                    <td className="tnum sub">
                                        {timeOf(p.created_at)}
                                    </td>
                                </tr>
                            ))}
                        </Table>
                    </section>

                    <section className="card">
                        <div className="card-h">
                            <h3>Mix carburant</h3>
                        </div>
                        <div className="card-p flex items-center gap-[18px]">
                            {donut.length ? (
                                <>
                                    <DonutFusy
                                        data={donut}
                                        center={num(stats.paidPayments)}
                                        label="paiements"
                                    />
                                    <div className="legend flex-col gap-[10px]">
                                        {charts.fuelMix.map((f) => (
                                            <span key={f.fuel}>
                                                <i
                                                    style={{
                                                        background:
                                                            FUEL_COLOR[
                                                                f.fuel
                                                            ] ?? 'var(--faint)',
                                                    }}
                                                />
                                                {f.name}
                                            </span>
                                        ))}
                                    </div>
                                </>
                            ) : (
                                <Empty title="Aucun paiement">
                                    Le mix carburant apparaîtra ici.
                                </Empty>
                            )}
                        </div>
                    </section>
                </div>
            </div>
        </Page>
    );
}

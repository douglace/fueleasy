import { Link } from '@inertiajs/react';
import { toast } from 'sonner';
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
    short_code: string | null;
    amount: number;
    status: string;
    enterprise: string;
    fuel_type: string;
    confirmed_at: string | null;
}

interface Props {
    stats: {
        todaySales: number;
        pendingAmount: number;
        pumps: number;
        pompistes: number;
    };
    charts: {
        volume: { l: string; v: number }[];
        fuelMix: { name: string; value: number; fuel: string }[];
    };
    recentPayments: PaymentRow[];
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

function CopyCode({ code }: { code: string | null }) {
    if (!code) {
        return <>—</>;
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

export default function StationDashboard({
    stats,
    charts,
    recentPayments,
}: Props) {
    const donut = charts.fuelMix.map((f) => ({
        v: f.value,
        c: FUEL_COLOR[f.fuel] ?? 'var(--faint)',
        name: f.name,
    }));

    return (
        <Page title="Tableau de bord — Station">
            <PageHead
                title="Tableau de bord"
                sub="Activité de la station et reversements"
            />

            <div className="stack">
                <div className="cols-4 grid">
                    <Kpi
                        icon="wallet"
                        variant="hero"
                        label="Ventes du jour"
                        value={num(stats.todaySales)}
                        unit="FCFA"
                    />
                    <Kpi
                        icon="banknote"
                        variant="accent-warn"
                        label="Reversement attendu"
                        value={num(stats.pendingAmount)}
                        unit="FCFA"
                    />
                    <Kpi icon="fuel" label="Pompes" value={num(stats.pumps)} />
                    <Kpi
                        icon="users"
                        label="Pompistes"
                        value={num(stats.pompistes)}
                    />
                </div>

                <div className="cols-3 grid">
                    <section className="card span-2">
                        <div className="card-h">
                            <h3>Ventes réglées</h3>
                            <span className="sub">7 derniers jours · FCFA</span>
                        </div>
                        <div className="card-p">
                            <AreaFusy data={charts.volume} />
                        </div>
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
                                        center={num(recentPayments.length)}
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
                                <Empty title="Aucune vente">
                                    Le mix carburant apparaîtra ici.
                                </Empty>
                            )}
                        </div>
                    </section>
                </div>

                <section className="card">
                    <div className="card-h">
                        <h3>Paiements récents</h3>
                        <div className="actions">
                            <Link
                                className="btn btn-ghost btn-sm"
                                href="/station/payments"
                            >
                                Tout voir <Icon name="chev" size={15} />
                            </Link>
                        </div>
                    </div>
                    <Table
                        head={[
                            'Référence',
                            'Code',
                            'Entreprise',
                            'Carburant',
                            { label: 'Montant', num: true },
                            'Statut',
                            'Heure',
                        ]}
                        empty="Aucun paiement."
                    >
                        {recentPayments.map((p) => (
                            <tr key={p.id}>
                                <td className="ref">{p.reference}</td>
                                <td>
                                    <CopyCode code={p.short_code} />
                                </td>
                                <td className="strong">{p.enterprise}</td>
                                <td>
                                    <Chip icon="drop">
                                        {FUEL[p.fuel_type] ?? p.fuel_type}
                                    </Chip>
                                </td>
                                <td className="num t-amount">
                                    {num(p.amount)}
                                </td>
                                <td>
                                    <Badge domain="payment" value={p.status} />
                                </td>
                                <td className="tnum sub">
                                    {timeOf(p.confirmed_at)}
                                </td>
                            </tr>
                        ))}
                    </Table>
                </section>
            </div>
        </Page>
    );
}

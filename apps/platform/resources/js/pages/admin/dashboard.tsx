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
    Note,
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
    fuel_type: string;
    station: string;
    enterprise: string;
    created_at: string | null;
}

interface AuditRow {
    id: number;
    action: string;
    organization_id: number | null;
    created_at: string | null;
}

interface Props {
    stats: {
        enterprises: number;
        stations: number;
        paidPayments: number;
        pendingRefunds: number;
        totalBalance: number;
    };
    charts: {
        volume: { l: string; v: number }[];
        fuelMix: { name: string; value: number; fuel: string }[];
    };
    recentPayments: PaymentRow[];
    audit: AuditRow[];
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

export default function AdminDashboard({
    stats,
    charts,
    recentPayments,
    audit,
}: Props) {
    const donut = charts.fuelMix.map((f) => ({
        v: f.value,
        c: FUEL_COLOR[f.fuel] ?? 'var(--faint)',
        name: f.name,
    }));

    return (
        <Page title="Tableau de bord — Admin Fusy">
            <PageHead
                title="Tableau de bord"
                sub="Vue d'ensemble de l'activité Fusy"
            />

            {stats.pendingRefunds > 0 && (
                <Note tone="warn" icon="alert" className="mb-[18px]">
                    <b>
                        {stats.pendingRefunds} remboursement(s) en attente de
                        décision.
                    </b>{' '}
                    Chaque approbation recrédite l'entreprise et le budget
                    chauffeur.{' '}
                    <Link href="/admin/refunds" className="font-bold underline">
                        Traiter les remboursements →
                    </Link>
                </Note>
            )}

            <div className="stack">
                <div className="cols-5 grid">
                    <Kpi
                        icon="building"
                        label="Entreprises"
                        value={num(stats.enterprises)}
                    />
                    <Kpi
                        icon="fuel"
                        label="Stations"
                        value={num(stats.stations)}
                    />
                    <Kpi
                        icon="check"
                        variant="accent-green"
                        label="Paiements réglés"
                        value={num(stats.paidPayments)}
                    />
                    <Kpi
                        icon="refund"
                        variant="accent-warn"
                        label="Remb. en attente"
                        value={num(stats.pendingRefunds)}
                        foot="à traiter sous 48 h"
                    />
                    <Kpi
                        icon="wallet"
                        variant="hero"
                        label="Soldes carburant"
                        value={num(stats.totalBalance)}
                        unit="FCFA"
                        foot="cumul des comptes entreprises"
                    />
                </div>

                <div className="cols-3 grid">
                    <section className="card span-2">
                        <div className="card-h">
                            <h3>Volume des paiements</h3>
                            <span className="sub">7 derniers jours · FCFA</span>
                            <div className="actions">
                                <span className="legend">
                                    <span>
                                        <i
                                            style={{
                                                background: 'var(--navy)',
                                            }}
                                        />
                                        Réglés
                                    </span>
                                </span>
                            </div>
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

                <div className="cols-3 grid">
                    <section className="card span-2">
                        <div className="card-h">
                            <h3>Transactions récentes</h3>
                            <div className="actions">
                                <Link
                                    className="btn btn-ghost btn-sm"
                                    href="/admin/transactions"
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
                                'Station',
                                'Carburant',
                                { label: 'Montant', num: true },
                                'Statut',
                                'Heure',
                            ]}
                            empty="Aucune transaction."
                        >
                            {recentPayments.map((p) => (
                                <tr key={p.id}>
                                    <td className="ref">{p.reference}</td>
                                    <td>
                                        <span className="mono font-bold">
                                            {p.short_code ?? '—'}
                                        </span>
                                    </td>
                                    <td className="strong">{p.enterprise}</td>
                                    <td>{p.station}</td>
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
                            <h3>Activité récente</h3>
                            <span className="sub">Audit</span>
                        </div>
                        <div className="py-[6px]">
                            {audit.length ? (
                                audit.map((a) => (
                                    <div
                                        key={a.id}
                                        className="flex items-start gap-3 px-5 py-[11px]"
                                    >
                                        <span className="grid size-[30px] flex-none place-items-center rounded-lg border border-[var(--line)] bg-[var(--bg)] text-[var(--fg-muted)]">
                                            <Icon name="audit" size={15} />
                                        </span>
                                        <div className="min-w-0">
                                            <div className="mono text-[12.5px] font-semibold text-[var(--fg)]">
                                                {a.action}
                                            </div>
                                            <div className="sub text-[12px]">
                                                {a.created_at}
                                            </div>
                                        </div>
                                    </div>
                                ))
                            ) : (
                                <div className="state-pad">
                                    <Empty title="Aucune activité" />
                                </div>
                            )}
                            <div className="px-5 pt-[10px] pb-[14px]">
                                <Link
                                    className="btn btn-ghost btn-sm w-full justify-center"
                                    href="/admin/audit"
                                >
                                    Journal complet
                                </Link>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </Page>
    );
}

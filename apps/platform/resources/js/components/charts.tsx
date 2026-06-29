import {
    Area,
    AreaChart,
    Bar,
    BarChart,
    CartesianGrid,
    Cell,
    Pie,
    PieChart,
    ResponsiveContainer,
    Tooltip,
    XAxis,
} from 'recharts';
import { num } from '@/components/fusy';

const tooltipStyle = {
    background: 'var(--card)',
    border: '1px solid var(--line)',
    borderRadius: 10,
    boxShadow: 'var(--shadow-pop)',
    fontSize: 12,
    color: 'var(--fg)',
};

/** Courbe d'aire — ligne navy + remplissage dégradé. data: {l, v}[] */
export function AreaFusy({
    data,
    height = 200,
}: {
    data: { l: string; v: number }[];
    height?: number;
}) {
    return (
        <ResponsiveContainer width="100%" height={height}>
            <AreaChart
                data={data}
                margin={{ top: 14, right: 6, left: 6, bottom: 0 }}
            >
                <defs>
                    <linearGradient id="fusy-area" x1="0" y1="0" x2="0" y2="1">
                        <stop
                            offset="0%"
                            stopColor="var(--navy)"
                            stopOpacity={0.22}
                        />
                        <stop
                            offset="100%"
                            stopColor="var(--navy)"
                            stopOpacity={0}
                        />
                    </linearGradient>
                </defs>
                <CartesianGrid
                    vertical={false}
                    stroke="var(--line)"
                    strokeDasharray="3 4"
                />
                <XAxis
                    dataKey="l"
                    tick={{ fill: 'var(--faint)', fontSize: 10.5 }}
                    axisLine={false}
                    tickLine={false}
                />
                <Tooltip
                    contentStyle={tooltipStyle}
                    formatter={(v) => [num(Number(v)), '']}
                    labelStyle={{ color: 'var(--fg-muted)' }}
                    cursor={{ stroke: 'var(--border-strong)' }}
                />
                <Area
                    type="monotone"
                    dataKey="v"
                    stroke="var(--navy)"
                    strokeWidth={2.4}
                    fill="url(#fusy-area)"
                    dot={{
                        r: 2.6,
                        fill: 'var(--card)',
                        stroke: 'var(--navy)',
                        strokeWidth: 2,
                    }}
                    activeDot={{ r: 4, fill: 'var(--navy)' }}
                />
            </AreaChart>
        </ResponsiveContainer>
    );
}

/** Barres arrondies. data: {l, v, c?}[] */
export function BarsFusy({
    data,
    height = 190,
}: {
    data: { l: string; v: number; c?: string }[];
    height?: number;
}) {
    return (
        <ResponsiveContainer width="100%" height={height}>
            <BarChart
                data={data}
                margin={{ top: 12, right: 6, left: 6, bottom: 0 }}
            >
                <CartesianGrid
                    vertical={false}
                    stroke="var(--line)"
                    strokeDasharray="3 4"
                />
                <XAxis
                    dataKey="l"
                    tick={{ fill: 'var(--faint)', fontSize: 10.5 }}
                    axisLine={false}
                    tickLine={false}
                />
                <Tooltip
                    contentStyle={tooltipStyle}
                    formatter={(v) => [num(Number(v)), '']}
                    labelStyle={{ color: 'var(--fg-muted)' }}
                    cursor={{ fill: 'var(--card-2)' }}
                />
                <Bar dataKey="v" radius={[4, 4, 0, 0]} maxBarSize={40}>
                    {data.map((d, i) => (
                        <Cell key={i} fill={d.c ?? 'var(--green)'} />
                    ))}
                </Bar>
            </BarChart>
        </ResponsiveContainer>
    );
}

/** Donut avec libellé central. data: {v, c, name?}[] */
export function DonutFusy({
    data,
    center,
    label,
    size = 150,
}: {
    data: { v: number; c: string; name?: string }[];
    center?: string;
    label?: string;
    size?: number;
}) {
    return (
        <div style={{ position: 'relative', width: size, height: size }}>
            <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                    <Pie
                        data={data}
                        dataKey="v"
                        innerRadius={size * 0.32}
                        outerRadius={size * 0.427}
                        startAngle={90}
                        endAngle={-270}
                        stroke="none"
                    >
                        {data.map((d, i) => (
                            <Cell key={i} fill={d.c} />
                        ))}
                    </Pie>
                    <Tooltip
                        contentStyle={tooltipStyle}
                        formatter={(v, n) => [num(Number(v)), n]}
                    />
                </PieChart>
            </ResponsiveContainer>
            <div
                style={{
                    position: 'absolute',
                    inset: 0,
                    display: 'grid',
                    placeItems: 'center',
                    textAlign: 'center',
                    pointerEvents: 'none',
                }}
            >
                <div>
                    {center && (
                        <div
                            style={{
                                fontSize: 22,
                                fontWeight: 700,
                                color: 'var(--fg)',
                            }}
                        >
                            {center}
                        </div>
                    )}
                    {label && (
                        <div style={{ fontSize: 11, color: 'var(--fg-muted)' }}>
                            {label}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

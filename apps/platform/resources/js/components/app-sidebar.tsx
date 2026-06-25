import { Link, usePage } from '@inertiajs/react';
import {
    Banknote,
    Building2,
    CreditCard,
    Fuel,
    LayoutGrid,
    Receipt,
    RotateCcw,
    ScrollText,
    Users,
    Wrench,
} from 'lucide-react';
import AppLogo from '@/components/app-logo';
import { NavMain } from '@/components/nav-main';
import { NavUser } from '@/components/nav-user';
import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar';
import { dashboard } from '@/routes';
import type { Auth, NavItem } from '@/types';

const navByRole: Record<string, NavItem[]> = {
    fusy_admin: [
        { title: 'Tableau de bord', href: '/admin', icon: LayoutGrid },
        {
            title: 'Organisations',
            href: '/admin/organizations',
            icon: Building2,
        },
        { title: 'Transactions', href: '/admin/transactions', icon: Receipt },
        { title: 'Remboursements', href: '/admin/refunds', icon: RotateCcw },
        { title: 'Reversements', href: '/admin/settlements', icon: Banknote },
        { title: 'Audit', href: '/admin/audit', icon: ScrollText },
    ],
    enterprise_admin: [
        { title: 'Tableau de bord', href: '/enterprise', icon: LayoutGrid },
        { title: 'Chauffeurs', href: '/enterprise/drivers', icon: Users },
        {
            title: 'Stations autorisées',
            href: '/enterprise/stations',
            icon: Fuel,
        },
        {
            title: 'Transactions',
            href: '/enterprise/transactions',
            icon: Receipt,
        },
    ],
    station_admin: [
        { title: 'Tableau de bord', href: '/station', icon: LayoutGrid },
        { title: 'Pompes', href: '/station/pumps', icon: Fuel },
        { title: 'Pompistes', href: '/station/pompistes', icon: Wrench },
        { title: 'Paiements', href: '/station/payments', icon: CreditCard },
        { title: 'Reversements', href: '/station/settlements', icon: Banknote },
    ],
};

export function AppSidebar() {
    const { auth } = usePage<{ auth: Auth }>().props;
    const role = typeof auth?.user?.role === 'string' ? auth.user.role : '';
    const items = navByRole[role] ?? [
        { title: 'Tableau de bord', href: dashboard(), icon: LayoutGrid },
    ];

    return (
        <Sidebar collapsible="icon" variant="inset">
            <SidebarHeader>
                <SidebarMenu>
                    <SidebarMenuItem>
                        <SidebarMenuButton size="lg" asChild>
                            <Link href={items[0].href} prefetch>
                                <AppLogo />
                            </Link>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarHeader>

            <SidebarContent>
                <NavMain items={items} />
            </SidebarContent>

            <SidebarFooter>
                <NavUser />
            </SidebarFooter>
        </Sidebar>
    );
}

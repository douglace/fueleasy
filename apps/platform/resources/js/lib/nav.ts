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
import type { NavItem } from '@/types';

/**
 * Navigation par rôle — aligné sur les espaces du design FUSY-DASH
 * (admin / enterprise / station).
 */
export const navByRole: Record<string, NavItem[]> = {
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

export const roleLabels: Record<string, string> = {
    fusy_admin: 'Admin Fusy',
    enterprise_admin: 'Espace Entreprise',
    station_admin: 'Espace Station',
};

export const fallbackNav: NavItem[] = [
    { title: 'Tableau de bord', href: '/dashboard', icon: LayoutGrid },
];

import { usePage } from '@inertiajs/react';
import { useEffect, useState } from 'react';
import { toast } from 'sonner';
import { AppSidebar } from '@/components/app-sidebar';
import { AppTopbar } from '@/components/app-topbar';
import { useCurrentUrl } from '@/hooks/use-current-url';
import { useFlashToast } from '@/hooks/use-flash-toast';
import { fallbackNav, navByRole, roleLabels } from '@/lib/nav';
import { cn } from '@/lib/utils';
import type { AppLayoutProps, Auth } from '@/types';

export default function AppSidebarLayout({ children }: AppLayoutProps) {
    const { auth, flash } = usePage<{
        auth: Auth;
        flash?: { status?: string | null };
    }>().props;
    const role = typeof auth?.user?.role === 'string' ? auth.user.role : '';
    const items = navByRole[role] ?? fallbackNav;
    const roleLabel = roleLabels[role] ?? 'Espace';
    const { isCurrentUrl } = useCurrentUrl();
    const activeTitle = items.find((i) => isCurrentUrl(i.href))?.title;

    const [navOpen, setNavOpen] = useState(false);

    // Toasts structurés (PIN, succès/erreurs) via flash Inertia.
    useFlashToast();
    useEffect(() => {
        if (flash?.status) {
            toast.success(flash.status);
        }
    }, [flash?.status]);

    return (
        <div className={cn('app', navOpen && 'nav-open')}>
            <AppSidebar onNavigate={() => setNavOpen(false)} />
            <div
                className="scrim-nav"
                onClick={() => setNavOpen(false)}
                aria-hidden
            />
            <main className="main">
                <AppTopbar
                    roleLabel={roleLabel}
                    title={activeTitle}
                    onMenu={() => setNavOpen((v) => !v)}
                />
                <div className="page">{children}</div>
            </main>
        </div>
    );
}

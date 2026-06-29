import { Link, usePage } from '@inertiajs/react';
import AppLogoIcon from '@/components/app-logo-icon';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { UserMenuContent } from '@/components/user-menu-content';
import { useCurrentUrl } from '@/hooks/use-current-url';
import { useInitials } from '@/hooks/use-initials';
import { fallbackNav, navByRole, roleLabels } from '@/lib/nav';
import type { Auth } from '@/types';

export function AppSidebar({ onNavigate }: { onNavigate?: () => void }) {
    const { auth } = usePage<{ auth: Auth }>().props;
    const role = typeof auth?.user?.role === 'string' ? auth.user.role : '';
    const items = navByRole[role] ?? fallbackNav;
    const label = roleLabels[role] ?? 'Espace';
    const { isCurrentUrl } = useCurrentUrl();
    const initials = useInitials();
    const user = auth.user;

    return (
        <aside className="sidebar">
            <div className="brand">
                <AppLogoIcon size={32} className="mark" />
                <span className="word">Fusy</span>
            </div>

            <div className="nav-group-t">{label}</div>

            {items.map((item) => {
                const ItemIcon = item.icon;

                return (
                    <Link
                        key={item.title}
                        href={item.href}
                        prefetch
                        onClick={onNavigate}
                        className={
                            isCurrentUrl(item.href) ? 'nav-i active' : 'nav-i'
                        }
                    >
                        {ItemIcon && <ItemIcon />}
                        <span className="nav-label">{item.title}</span>
                    </Link>
                );
            })}

            {user && (
                <div className="side-foot">
                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <button
                                type="button"
                                className="who w-full cursor-pointer border-0 bg-transparent text-left"
                            >
                                <div className="av">{initials(user.name)}</div>
                                <div className="nav-label">
                                    <b>{user.name}</b>
                                    <span>{user.email}</span>
                                </div>
                            </button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent
                            align="start"
                            side="top"
                            className="min-w-56 rounded-lg"
                        >
                            <UserMenuContent user={user} />
                        </DropdownMenuContent>
                    </DropdownMenu>
                </div>
            )}
        </aside>
    );
}

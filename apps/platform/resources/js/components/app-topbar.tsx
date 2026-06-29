import { Moon, Sun } from 'lucide-react';
import { useEffect, useRef } from 'react';
import { Icon } from '@/components/fusy';
import { useAppearance } from '@/hooks/use-appearance';

export function AppTopbar({
    roleLabel,
    title,
    onMenu,
}: {
    roleLabel: string;
    title?: string;
    onMenu: () => void;
}) {
    const { resolvedAppearance, updateAppearance } = useAppearance();
    const isDark = resolvedAppearance === 'dark';
    const searchRef = useRef<HTMLInputElement>(null);

    // Raccourci "/" : focus la recherche (sauf si déjà dans un champ).
    useEffect(() => {
        const onKey = (e: KeyboardEvent) => {
            const tag = (e.target as HTMLElement)?.tagName ?? '';

            if (e.key === '/' && !/input|textarea/i.test(tag)) {
                e.preventDefault();
                searchRef.current?.focus();
            }
        };
        document.addEventListener('keydown', onKey);

        return () => document.removeEventListener('keydown', onKey);
    }, []);

    return (
        <div className="topbar">
            <button
                className="burger"
                type="button"
                onClick={onMenu}
                title="Menu"
                aria-label="Menu"
            >
                <Icon name="menu" size={18} />
            </button>

            <div className="crumb">
                <b>{roleLabel}</b>
                {title ? <>&nbsp;›&nbsp; {title}</> : null}
            </div>

            <div className="topsearch">
                <Icon name="search" size={16} />
                <input ref={searchRef} placeholder="Rechercher…" />
                <kbd>/</kbd>
            </div>

            <button
                className="icon-btn"
                type="button"
                title="Thème"
                aria-label="Basculer le thème"
                onClick={() => updateAppearance(isDark ? 'light' : 'dark')}
            >
                {isDark ? <Sun size={18} /> : <Moon size={18} />}
            </button>

            <button
                className="icon-btn"
                type="button"
                title="Notifications"
                aria-label="Notifications"
            >
                <Icon name="bell" size={18} />
                <span className="dot" />
            </button>
        </div>
    );
}

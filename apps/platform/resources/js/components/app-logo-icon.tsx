/**
 * Mark Fusy — F navy + flèche verte sur fond blanc arrondi.
 * Porté depuis FUSY-DASH/assets/fusy.js (Fusy.mark).
 */
export default function AppLogoIcon({
    size = 32,
    className,
}: {
    size?: number;
    className?: string;
}) {
    return (
        <svg
            width={size}
            height={size}
            viewBox="0 0 40 40"
            fill="none"
            className={className}
            aria-hidden
        >
            <rect width="40" height="40" rx="10" fill="#fff" />
            <path d="M8 9h22l-5 6H13v4h11l-5 6H13v6H8z" fill="#003362" />
            <path d="M9 22h6c0 4 3 7 7 7v6c-8 0-13-6-13-13z" fill="#00B473" />
        </svg>
    );
}

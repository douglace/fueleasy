# Platform Architecture

- `app/Domain`: règles métier indépendantes du transport HTTP.
- `app/Application`: cas d'usage et orchestration.
- `app/Http`: contrôleurs, middlewares, requests et resources.
- `resources/js`: dashboards Inertia React selon organisation/rôle.
- `routes/web.php`: dashboards web.
- `routes/api.php`: API mobile versionnée.

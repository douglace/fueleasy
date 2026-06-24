# Fusy V3 — Checklist d'implémentation traçable

Source d'exigences : `plan_mvp/00_OVERVIEW.md` (+ sprints), `docs/superpowers/specs/2026-06-24-fusy-mvp-v3-implementation-design.md`,
`docs/superpowers/specs/2026-06-23-fusy-mvp-v3-design.md`. Parcours de référence = **V3** (QR dynamique, débit immédiat, pompiste vérifie sans valider).

Légende : `[x]` fait & testé.

## Tranche 1 — Socle V3
- [x] Couches `app/Domain` et `app/Application`, value objects `Money`, `OrganizationCode`, enums
- [x] Tests sur PostgreSQL (`fusy_testing`), inscription publique supprimée

## Tranche 2 — Organisations, utilisateurs, rôles, isolation
- [x] Migrations organizations + extension users, index uniques partiels (email global, (org,phone), (org,matricule))
- [x] Générateur de code unique, tests isolation multi-organisation

## Tranche 3 — Ledger, compte entreprise, budgets chauffeur
- [x] fuel_accounts (CHECK), ledger_entries (trigger immuabilité), driver_budgets, audit_logs
- [x] Crédit atomique + ledger, reset budget remplace le solde, sur-allocation, tests PG

## Tranche 4 — Onboarding & dashboard Admin Fusy
- [x] OnboardOrganization (org + code + compte + 1er admin), crédit, stations autorisées
- [x] Supervision transactions + audit, dashboard Inertia + tests

## Tranche 5 — Dashboard entreprise
- [x] Chauffeurs (CRUD, PIN temp/reset), budgets (set/reset), sur-allocation
- [x] Transactions, export CSV, dashboard Inertia + tests d'isolation

## Tranche 6 — Dashboard station, pompes, carburants
- [x] Pompes (création, QR fixe révocable), pompistes (CRUD, PIN), sessions de travail
- [x] Paiements reçus, reversements, demande de remboursement, dashboard Inertia + tests

## Tranche 7 — Auth mobile, PIN, appareil unique (API)
- [x] Activation (PIN temp→perso, device, SMS), login PIN, changement d'appareil (SMS), un seul device actif
- [x] 5 tentatives → blocage 15 min → reset admin, tests API permissions/isolation

## Tranche 8 — QR dynamique, QR fixe secours, paiement atomique (API)
- [x] QR signé 60 s + QR fixe révocable, session 5 min, contrôles d'éligibilité
- [x] Débit atomique (compte+budget+paiement+ledger), idempotence
- [x] Tests PG concurrence/verrouillage/atomicité/idempotence/expiration/perte réseau (pcntl_fork)

## Tranche 9 — Alertes pompiste, reçus, SMS de secours
- [x] Reçu PDF consultable, alerte + recherche par code court, ack
- [x] SMS de secours si pas d'accusé, vérification serveur du paiement

## Tranche 10 — Remboursements, reversements, exports
- [x] Remboursement total (station→Fusy) + écritures compensatoires, paiement initial conservé
- [x] Lots hebdomadaires + marquage payé, exports CSV/PDF, jobs

## Tranche 11 — Simulations Orange Money, MTN MoMo, USSD
- [x] Recharge démo (pending/successful/failed) sur solde fictif isolé, parcours USSD
- [x] Isolation stricte démo / pilote (refus sur org réelle)

## Tranche 12 — QA, déploiement, pilote
- [x] Seeders pilote/démo idempotents + test
- [x] Runbook déploiement VPS (`docs/RUNBOOK_DEPLOIEMENT.md`), scheduler câblé
- [x] `composer ci:check` + `npm run build` + migrations base vide verts
- [x] Aucun TODO/placeholder/test ignoré/parcours mort

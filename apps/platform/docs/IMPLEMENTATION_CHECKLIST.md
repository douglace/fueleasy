# Fusy V3 — Checklist d'implémentation traçable

Source d'exigences : `plan_mvp/00_OVERVIEW.md` (+ sprints), `docs/superpowers/specs/2026-06-24-fusy-mvp-v3-implementation-design.md`,
`docs/superpowers/specs/2026-06-23-fusy-mvp-v3-design.md`. Parcours de référence = **V3** (QR dynamique, débit immédiat, pompiste vérifie sans valider).

Légende : `[x]` fait & testé · `[~]` en cours · `[ ]` à faire.

## Tranche 1 — Socle V3 (structure, doc, CI)
- [x] Couches `app/Domain` et `app/Application` créées
- [x] Value objects `Money` (FCFA entier), `OrganizationCode`
- [x] Enums `OrganizationType`, `OrganizationStatus`, `Role`, `UserStatus`
- [x] Tests sur PostgreSQL (`fusy_testing`), `composer ci:check` vert
- [x] Inscription publique supprimée (hors périmètre)

## Tranche 2 — Organisations, utilisateurs, rôles, isolation
- [x] Migration `organizations` (code unique 6 car., type, statut, is_demo, settings)
- [x] Extension `users` (organization_id, role, status, phone, matricule, PIN, device)
- [x] Index uniques partiels : email global, (org, phone), (org, matricule)
- [x] `OrganizationCodeGenerator` (unicité globale)
- [x] Tests : unicité code, même téléphone multi-org, isolation `belongsToOrganization`
- [ ] Policies / Gates par rôle + middleware d'organisation
- [ ] Login web tenant-aware (code organisation) — à confirmer

## Tranche 3 — Ledger, compte entreprise, budgets chauffeur
- [ ] Migration `fuel_accounts` + `ledger_entries` (immuable)
- [ ] Migration `driver_budgets` (mode manuel/hebdo/mensuel, reset remplace)
- [ ] Crédit manuel atomique + écriture ledger
- [ ] Reset budget remplace le solde (ne l'additionne pas)
- [ ] Tests PG : atomicité crédit, immutabilité ledger, reset

## Tranche 4 — Onboarding & dashboard Admin Fusy
- [ ] Création organisation + premier admin + code
- [ ] Financements manuels, stations autorisées par entreprise
- [ ] Supervision transactions, suspensions, audit
- [ ] Interfaces Inertia admin Fusy + tests fonctionnels

## Tranche 5 — Dashboard entreprise
- [ ] Chauffeurs (création/suspension, PIN temp/reset)
- [ ] Budgets, sur-allocation, stations autorisées
- [ ] Dépenses, reçus, exports CSV/PDF
- [ ] Interfaces Inertia + tests

## Tranche 6 — Dashboard station, pompes, carburants
- [ ] Pompistes (création/suspension, PIN)
- [ ] Pompes + carburants par pompe, QR fixes de secours
- [ ] Paiements reçus, reversements, remboursements
- [ ] Interfaces Inertia + tests

## Tranche 7 — Auth mobile, PIN, appareil unique (API)
- [ ] Première connexion (code org + identifiant + PIN temp → PIN perso + SMS + device)
- [ ] Connexions suivantes par PIN sur device enregistré
- [ ] 5 tentatives → blocage 15 min → reset admin
- [ ] Un seul device actif, changement confirmé par SMS, ancienne session révoquée
- [ ] Tests API permissions + isolation

## Tranche 8 — QR dynamique, QR fixe secours, paiement atomique (API)
- [ ] Session pompiste + QR signé 60 s
- [ ] QR fixe pompe (secours) signé/révocable
- [ ] Session de paiement 5 min, contrôles d'éligibilité
- [ ] Débit atomique (compte + budget + paiement + ledger) sous verrou PG
- [ ] Idempotence (clé par tentative), double envoi = 1 débit
- [ ] Tests PG concurrence/verrouillage/atomicité/idempotence/expiration

## Tranche 9 — Alertes pompiste, reçus, SMS de secours
- [ ] Reçu généré + consultable (chauffeur/entreprise/station/admin)
- [ ] Alerte pompiste + recherche par code court
- [ ] SMS de secours si pas d'accusé de réception
- [ ] Vérification serveur du paiement par le pompiste

## Tranche 10 — Remboursements, reversements, exports
- [ ] Demande de remboursement total (station) → approbation Fusy
- [ ] Écritures compensatoires (compte, budget, reversement), paiement initial conservé
- [ ] Lots hebdomadaires de reversement + marquage payé
- [ ] Exports CSV + PDF

## Tranche 11 — Simulations Orange Money, MTN MoMo, USSD
- [ ] Recharge démo (états pending/successful/failed) sur solde fictif isolé
- [ ] Parcours USSD simulé
- [ ] Isolation stricte démo / pilote (aucun impact réel)

## Tranche 12 — QA, déploiement, pilote
- [ ] Seeders pilote/démo
- [ ] Runbook déploiement VPS documenté
- [ ] `composer ci:check` + `npm run build` + migrations base vide verts
- [ ] Revue finale : aucun TODO/placeholder/test ignoré/parcours mort

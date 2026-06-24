# Prompt Claude Design — Dashboard Admin Fusy

Conçois le **Dashboard Admin Fusy** interne du **MVP B2B fermé**. Lis tous les documents de `design-briefs/00-shared/` et `design-briefs/04-fusy-admin-dashboard/`. Utilise `assets/primary-logo.png` sans le modifier.

## Direction imposée

Clarté opérationnelle, Manrope uniquement, bleu `#003362`, vert accent `#00B473`, fond `#F6F8FA`, thème clair. Interface interne dense mais lisible, conçue à 1440 px et utilisable à 1280 px, avec montants FCFA tabulaires, tables de 48 px et contraste WCAG AA.

## Produit

Admin Fusy crée entreprises, stations et pompistes, crédite manuellement les comptes après preuve, génère les QR fixes, autorise les stations, supervise les transactions, consulte l'audit et prépare les lots de reversement. Les paiements et dépôts ont lieu hors plateforme.

## Concevoir

Connexion, vue d'ensemble, listes/création/détails entreprise et station, création admin entreprise, crédit manuel, suspension/réactivation, QR, pompistes, stations autorisées, transactions/détail, audit, reporting simple, reversements et détail lot.

Inclure onboarding incomplet, champs invalides, opération financière en cours, résultat réseau inconnu, QR absent/actif/remplacé/désactivé, station suspendue, transaction bloquée, lot vide/vérifié/payé/annulé et action concurrente.

Utiliser TransLog Cameroun SARL, crédit 500 000 FCFA, nouveau solde 2 350 000 FCFA, Tradex Bonamoussadi, Armand Etoa et lot REV-2026-W25-TRADX01 de 3 486 000 FCFA.

## Sortie

Architecture, maquettes haute fidélité, variantes critiques, composants sensibles et annotations d'impact. N'ajoute ni Mobile Money automatisé, KYC, microcrédit, paiement bancaire intégré, commissions automatiques, rôles internes complexes, ticketing ou BI avancée. N'expose aucune fonction Admin aux autres utilisateurs.

# Périmètre et architecture — Admin Fusy

## Fonctions MVP

- Entreprises : liste, création, modification, détail, suspension/réactivation.
- Création de l'admin entreprise.
- Crédit manuel après preuve de dépôt, virement ou transfert.
- Stations : liste, création, détail, suspension/réactivation.
- QR fixe : générer, télécharger, remplacer, désactiver.
- Pompistes : créer, rattacher, suspendre, relancer activation.
- Stations autorisées par entreprise.
- Transactions globales et détail.
- Audit minimal.
- Reporting du pilote.
- Lots hebdomadaires de reversement par station.

## Hors périmètre

KYC automatisé, intégration Mobile Money, commissions automatiques, paiement bancaire du reversement dans Fusy, microcrédit, support ticketing, campagnes, BI avancée et permissions internes multi-niveaux.

## Navigation latérale

```text
Vue d'ensemble
Entreprises
Stations
Pompistes
Transactions
Reversements
Audit
```

Les stations autorisées se gèrent depuis le détail d'une entreprise. Les QR et pompistes se gèrent depuis le détail d'une station, avec accès transversal aux listes globales.

## En-tête de dossier

Pour entreprise, station ou personne : nom, identifiant, statut, informations essentielles et actions principales. Les actions destructives restent dans un menu ou une zone séparée avec confirmation.

## Modèle de reversement

Un lot agrège les transactions `completed` d'une station non encore rattachées. Statuts : `En attente`, `Vérifié`, `Payé`, `Annulé`. Le paiement a lieu hors plateforme ; l'admin enregistre seulement son statut et sa référence.

# Périmètre et architecture — Entreprise

## Fonctions MVP

- Tableau de bord : solde, chauffeurs, budgets, consommation et alertes.
- Création, modification, suspension et réactivation des chauffeurs.
- Relance de l'activation.
- Budget manuel, hebdomadaire ou mensuel.
- Champ libre véhicule, plaque ou mission.
- Stations autorisées en lecture seule.
- Transactions filtrables et reçus.
- Export CSV et PDF simple.
- Reporting simple par période, chauffeur, station, statut et carburant.

## Hors périmètre

Recharge automatisée, modification des stations, départements, approbation multi-niveau, règles horaires, géofencing, véhicules structurés, intégration comptable, facturation d'abonnement, BI avancée et gestion d'autres entreprises.

## Navigation latérale

```text
Vue d'ensemble
Chauffeurs
Stations autorisées
Transactions
Rapports
Paramètres du compte
```

Les exports se trouvent dans Transactions et Rapports, pas comme destination principale. Le compte carburant est visible dans l'en-tête ou la vue d'ensemble sans créer une section `Wallet`.

## Hiérarchie du tableau de bord

1. Solde du compte carburant et état opérationnel.
2. Action `Ajouter un chauffeur`.
3. Indicateurs : chauffeurs actifs, budgets configurés, consommation de la période.
4. Alertes : solde bas, activation en attente, budget épuisé, transactions bloquées.
5. Activité récente.

## Règles de données

- Le budget total configuré peut dépasser le solde sans être une erreur.
- Un reset remplace le reliquat et doit être expliqué avant enregistrement.
- Les stations sont consultables mais non modifiables.
- Seules les transactions terminées comptent dans le total consommé.

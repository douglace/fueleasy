# Sprint 7 — Reporting, Exports Et Reversements

> **Semaines :** S13-S14  
> **Objectif :** fournir les rapports nécessaires aux entreprises, stations et Fusy pour exploiter le pilote.  
> **Jalon :** exports CSV/PDF et lots hebdomadaires de reversement disponibles.

---

## 1. Objectifs

Finaliser la partie exploitation :

- reporting entreprise ;
- reporting station ;
- reporting admin Fusy ;
- exports CSV ;
- exports PDF simples ;
- lots hebdomadaires de reversement station ;
- alertes solde bas et anomalies simples.

---

## 2. Reporting Entreprise

Filtres :

- période ;
- chauffeur ;
- station ;
- statut ;
- type carburant.

Indicateurs :

- total consommé ;
- nombre de transactions ;
- transactions refusées ;
- transactions expirées ;
- consommation par chauffeur ;
- consommation par station.

Exports :

- CSV ;
- PDF simple.

---

## 3. Reporting Station

Filtres :

- période ;
- pompiste ;
- entreprise ;
- statut.

Indicateurs :

- transactions du jour ;
- montant total validé ;
- montant à reverser ;
- transactions refusées/expirées ;
- activité par pompiste.

---

## 4. Reporting Admin Fusy

Indicateurs :

- entreprises actives ;
- stations actives ;
- chauffeurs actifs ;
- transactions réussies ;
- transactions bloquées ;
- volume traité ;
- soldes comptes carburant ;
- montants dus aux stations.

---

## 5. Lots Hebdomadaires De Reversement

Règle MVP :

- génération manuelle ou planifiée d'un lot hebdomadaire par station ;
- le lot agrège les transactions `completed` non encore rattachées à un lot ;
- le paiement réel se fait hors plateforme ;
- admin Fusy marque le lot comme payé ;
- audit du changement de statut.

Statuts lot :

- `pending` ;
- `reviewed` ;
- `paid` ;
- `cancelled`.

---

## 6. Alertes MVP

Alertes in-app/dashboard :

- solde entreprise bas ;
- transaction bloquée pour solde insuffisant ;
- transaction expirée ;
- station suspendue ;
- chauffeur suspendu.

SMS uniquement pour activation chauffeur et cas critiques décidés par Fusy.

Pas de push FCM au MVP.

---

## 7. Tests Critiques

À couvrir :

- export CSV transactions entreprise ;
- export PDF transactions entreprise ;
- calcul total par station ;
- génération lot hebdomadaire ;
- impossibilité de rattacher deux fois une transaction à un lot ;
- passage lot à `paid` ;
- audit paiement manuel.

---

## 8. Livrables

- Pages reporting entreprise.
- Pages reporting station/admin.
- Exports CSV/PDF.
- Génération lots hebdomadaires.
- Statuts lots.
- Alertes dashboard.

---

## 9. Critères De Validation

- Une entreprise peut exporter ses transactions.
- Fusy peut voir les montants dus par station.
- Fusy peut générer un lot hebdomadaire.
- Fusy peut marquer un lot comme payé.
- Les montants de lots correspondent aux transactions validées.

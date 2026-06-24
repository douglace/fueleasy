# Sprint 3 — Dashboard Entreprise

> **Semaines :** S5-S6  
> **Objectif :** permettre à une entreprise pilote de gérer ses chauffeurs, budgets et stations autorisées.  
> **Jalon :** une entreprise peut préparer son usage terrain sans support technique.

---

## 1. Objectifs

Construire le dashboard web destiné aux entreprises clientes.

Le dashboard entreprise doit rester simple :

- solde du compte carburant ;
- chauffeurs ;
- budgets ;
- stations autorisées en lecture ;
- transactions en lecture ;
- exports simples.

---

## 2. Écrans Entreprise

### 2.1 Tableau De Bord

Afficher :

- solde compte carburant ;
- nombre de chauffeurs actifs ;
- budget total configuré ;
- montant consommé sur la période ;
- alertes : solde bas, chauffeurs sans budget, transactions refusées.

Important : expliquer clairement que le solde entreprise est l'argent réel et que les budgets chauffeurs sont des autorisations.

### 2.2 Chauffeurs

Actions :

- créer chauffeur ;
- modifier nom/téléphone ;
- suspendre/réactiver ;
- relancer activation ;
- voir historique chauffeur.

Données :

- nom ;
- téléphone ;
- statut : invité, actif, suspendu ;
- budget disponible ;
- mode budget ;
- champ libre véhicule/plaque/mission.

Le véhicule reste optionnel et non structuré.

### 2.3 Budgets Chauffeur

Modes :

- manuel ;
- hebdomadaire ;
- mensuel.

Règles :

- reset hebdomadaire/mensuel remplace le solde restant ;
- sur-allocation autorisée ;
- le solde entreprise n'est pas réservé au moment de l'allocation ;
- le débit réel se fait uniquement à la transaction.

### 2.4 Stations Autorisées

L'entreprise voit les stations autorisées configurées par Fusy.

Au MVP, l'entreprise ne modifie pas elle-même cette liste si Fusy veut garder le contrôle pilote. Une demande de modification peut être faite hors plateforme.

### 2.5 Transactions

Liste filtrable :

- date ;
- chauffeur ;
- station ;
- montant ;
- type carburant ;
- statut ;
- code court ;
- reçu.

---

## 3. Activation Chauffeur

Le chauffeur est créé par l'admin entreprise, puis active son compte côté mobile.

Le dashboard doit permettre :

- génération d'un code d'activation ;
- relance SMS critique si configurée ;
- affichage du statut d'activation.

---

## 4. Exports MVP

Prévoir :

- export CSV des transactions filtrées ;
- export PDF simple des transactions filtrées.

Pas de rapports avancés ou BI au MVP.

---

## 5. Livrables

- Layout dashboard entreprise Inertia React.
- Écran tableau de bord.
- Gestion chauffeurs.
- Gestion budgets.
- Lecture stations autorisées.
- Liste transactions.
- Reçus en lecture.
- Export CSV/PDF simple.

---

## 6. Critères De Validation

- Une entreprise peut créer 5 à 15 chauffeurs sans intervention technique.
- Un chauffeur peut être configuré en mode manuel, hebdomadaire ou mensuel.
- La sur-allocation est acceptée par l'interface.
- L'entreprise voit clairement son solde réel.
- L'entreprise voit ses stations autorisées.
- Les transactions sont filtrables.
- Les exports CSV/PDF fonctionnent.

# Sprint 5 — App Pompiste Flutter Android

> **Semaines :** S9-S10  
> **Objectif :** permettre aux pompistes de consulter les paiements effectués de leur station et d'en accuser réception.  
> **Jalon :** app pompiste Android utilisable dans une station pilote.

---

## 1. Objectifs

Construire une app pompiste dédiée, minimaliste et rapide.

Fonctions MVP :

- activation/connexion pompiste ;
- rattachement station ;
- ouverture/fermeture d'une session de travail sur une pompe ;
- affichage du QR de la pompe en service ;
- liste des paiements effectués du jour ;
- accusé de réception d'un nouveau paiement ;
- recherche par code court ;
- historique du jour ;
- état réseau simple.

Le pompiste **ne valide ni ne refuse jamais** une transaction : au moment où un paiement apparaît, il est déjà réglé par le PIN du chauffeur.

---

## 2. Écrans

### 2.1 Connexion

Le pompiste se connecte avec :

- téléphone ;
- PIN.

Le compte est créé par admin Fusy.

### 2.2 Session de travail

- choix de la pompe ;
- ouverture de la session ;
- affichage du QR de la pompe pour le scan par les chauffeurs ;
- fermeture de la session en fin de service.

### 2.3 Paiements Du Jour

Afficher uniquement les paiements de la station du pompiste, le plus récent en tête.

Informations par ligne :

- code court ;
- chauffeur ;
- entreprise ;
- montant ;
- type carburant ;
- heure ;
- statut d'accusé (`à accuser` / `accusé`).

### 2.4 Détail Paiement

Le pompiste voit, en lecture seule :

- code court ;
- montant ;
- type carburant ;
- chauffeur ;
- entreprise ;
- station ;
- bouton `Accuser réception` si le paiement n'est pas encore accusé.

Le pompiste ne peut ni modifier, ni valider, ni refuser.

### 2.5 Historique Du Jour

Afficher :

- paiements du jour ;
- montant total du jour ;
- filtre simple (tous / à accuser / accusés).

---

## 3. Règles Métier

- Un pompiste ne voit que les paiements de sa station.
- Un paiement apparaît déjà réglé : aucune action de validation ou de refus.
- L'accusé de réception ne débite ni n'annule rien ; il confirme que le pompiste a vu la transaction.
- Un nouveau paiement non accusé déclenche un SMS de secours après un délai ; l'accusé dans l'app lève ce rappel.

---

## 4. Tests Terrain À Prévoir

- pompiste voit un paiement effectué dans sa station ;
- pompiste ne voit pas les paiements d'une autre station ;
- pompiste accuse réception d'un paiement ;
- paiement déjà accusé sur un autre appareil ;
- ouverture/fermeture de session sur une pompe ;
- réseau faible ;
- recherche par code court.

---

## 5. Livrables

- App Flutter Android pompiste.
- Connexion téléphone + PIN.
- Session de travail sur pompe + QR.
- Liste des paiements du jour.
- Détail paiement en lecture seule.
- Accusé de réception.
- Historique du jour.

---

## 6. Critères De Validation

- Un pompiste rattaché à une station peut se connecter.
- Un paiement effectué apparaît dans l'app pompiste.
- Le pompiste peut accuser réception d'un paiement.
- Le pompiste ne peut ni modifier, ni valider, ni refuser.
- L'historique du jour est consultable.

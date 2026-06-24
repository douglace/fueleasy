# Sprint 5 — App Pompiste Flutter Android

> **Semaines :** S9-S10  
> **Objectif :** permettre aux pompistes de valider ou refuser les demandes carburant.  
> **Jalon :** app pompiste Android utilisable dans une station pilote.

---

## 1. Objectifs

Construire une app pompiste dédiée, minimaliste et rapide.

Fonctions MVP :

- activation/connexion pompiste ;
- rattachement station ;
- demandes en attente ;
- recherche par code court ;
- validation/refus ;
- historique du jour ;
- état réseau simple.

---

## 2. Écrans

### 2.1 Connexion

Le pompiste se connecte avec :

- téléphone ;
- PIN.

Le compte est créé par admin Fusy.

### 2.2 Demandes En Attente

Afficher uniquement les demandes de la station du pompiste.

Informations :

- code court ;
- chauffeur ;
- entreprise ;
- montant ;
- type carburant ;
- temps restant avant expiration.

### 2.3 Détail Demande

Le pompiste voit :

- code court ;
- montant ;
- type carburant ;
- chauffeur ;
- entreprise ;
- station ;
- bouton valider ;
- bouton refuser.

Le pompiste ne peut pas modifier le montant.

### 2.4 Historique Du Jour

Afficher :

- transactions validées ;
- refusées ;
- expirées ;
- montant total du jour.

---

## 3. Règles De Validation

- Une demande expirée ne peut pas être validée.
- Un pompiste ne voit que les demandes de sa station.
- Une demande refusée ne débite rien.
- Après validation pompiste, le chauffeur doit confirmer par PIN.
- La transaction n'est complète qu'après confirmation chauffeur.

---

## 4. Tests Terrain À Prévoir

- pompiste voit une demande créée par chauffeur ;
- pompiste ne voit pas les demandes d'une autre station ;
- pompiste valide dans le délai ;
- pompiste refuse ;
- demande expirée ;
- réseau faible ;
- code court vérifié.

---

## 5. Livrables

- App Flutter Android pompiste.
- Connexion téléphone + PIN.
- Liste demandes en attente.
- Détail demande.
- Validation/refus.
- Historique du jour.

---

## 6. Critères De Validation

- Un pompiste rattaché à une station peut se connecter.
- Une demande chauffeur apparaît dans l'app pompiste.
- Le pompiste peut valider ou refuser.
- Le pompiste ne peut pas modifier le montant.
- Une demande expirée n'est plus validable.
- L'historique du jour est consultable.

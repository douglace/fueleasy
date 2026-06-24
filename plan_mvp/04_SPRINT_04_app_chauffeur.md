# Sprint 4 — App Chauffeur Flutter Android + iOS

> **Semaines :** S7-S8  
> **Objectif :** permettre au chauffeur d'activer son compte, consulter son budget et initier une demande carburant depuis un QR station.  
> **Jalon :** app chauffeur utilisable en test interne Android et iOS.

---

## 1. Objectifs

Construire l'app mobile chauffeur avec Flutter pour Android et iOS.

Fonctions MVP :

- activation téléphone + code ;
- création PIN à 4 chiffres ;
- connexion par téléphone + PIN ;
- affichage budget disponible ;
- statut compte entreprise ;
- scan QR station ;
- saisie montant et type carburant ;
- création demande carburant ;
- confirmation finale par PIN ;
- historique et reçus.

---

## 2. Écrans

### 2.1 Activation

Étapes :

1. Saisie numéro de téléphone.
2. Saisie code activation/SMS.
3. Définition PIN.
4. Accès au compte.

### 2.2 Accueil Chauffeur

Afficher :

- nom chauffeur ;
- entreprise ;
- budget disponible ;
- statut compte entreprise : opérationnel, solde insuffisant, suspendu ;
- bouton scanner QR station ;
- dernier reçu.

### 2.3 Scan QR Station

Le scan lit le QR fixe station.

Après scan :

- afficher nom station ;
- vérifier station autorisée ;
- bloquer immédiatement si station non autorisée ;
- demander montant et type carburant si station valide.

### 2.4 Demande Carburant

Champs :

- montant ;
- type carburant ;
- champ libre véhicule/plaque/mission si requis par l'entreprise ;
- station détectée.

Avant création, l'API vérifie :

- budget chauffeur ;
- solde entreprise ;
- statut chauffeur ;
- statut entreprise ;
- statut station.

### 2.5 Confirmation PIN

Après validation pompiste :

- afficher montant ;
- station ;
- type carburant ;
- code court ;
- bouton confirmer ;
- saisie PIN obligatoire.

### 2.6 Historique Et Reçus

Afficher :

- transactions récentes ;
- statut ;
- reçu détaillé.

---

## 3. Notifications MVP

Notifications dans l'app :

- transaction en attente ;
- pompiste a validé ;
- transaction réussie ;
- transaction refusée ;
- transaction expirée ;
- solde entreprise insuffisant.

SMS uniquement pour activation et cas critiques.

Pas de push FCM au MVP.

---

## 4. Tests Terrain À Prévoir

- scan QR sur Android bas/milieu de gamme ;
- scan QR sur iPhone ;
- permission caméra ;
- réseau instable ;
- PIN incorrect ;
- transaction expirée ;
- station non autorisée ;
- solde entreprise insuffisant.

---

## 5. Livrables

- App Flutter chauffeur.
- Build Android testable.
- Build iOS testable.
- Auth téléphone + activation + PIN.
- Scan QR station.
- Création demande carburant.
- Confirmation finale PIN.
- Historique et reçus.

---

## 6. Critères De Validation

- Un chauffeur créé par l'entreprise peut activer son compte.
- Un chauffeur peut se connecter avec son PIN.
- Un chauffeur peut scanner un QR station.
- Une station non autorisée bloque le parcours.
- Un montant supérieur au budget bloque le parcours.
- Un solde entreprise insuffisant bloque le parcours.
- Une demande valide est créée.
- Le chauffeur peut confirmer par PIN après validation pompiste.

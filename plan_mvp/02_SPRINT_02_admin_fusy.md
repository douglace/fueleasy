# Sprint 2 — Dashboard Admin Fusy

> **Semaines :** S3-S4  
> **Objectif :** permettre à Fusy d'onboarder manuellement entreprises, stations et pompistes.  
> **Jalon :** Fusy peut préparer un pilote sans intervention technique.

---

## 1. Objectifs

Construire le dashboard admin interne pour gérer le pilote B2B fermé.

Fonctions prioritaires :

- création entreprise ;
- création admin entreprise ;
- crédit manuel du compte carburant ;
- création station ;
- génération QR fixe station ;
- création pompistes ;
- rattachement pompistes/station ;
- association stations autorisées/entreprise ;
- suspension/réactivation des entités.

---

## 2. Écrans Admin

### 2.1 Entreprises

Liste :

- nom ;
- contact principal ;
- statut ;
- solde compte carburant ;
- nombre de chauffeurs ;
- nombre de stations autorisées.

Actions :

- créer entreprise ;
- modifier infos ;
- suspendre/réactiver ;
- créer admin entreprise ;
- voir transactions liées.

### 2.2 Crédit Manuel Du Compte Carburant

L'admin Fusy peut créditer une entreprise après preuve de dépôt/virement.

Champs :

- entreprise ;
- montant ;
- référence de paiement ;
- méthode : dépôt, virement, transfert ;
- note interne ;
- date de réception.

Chaque crédit crée une entrée d'audit.

### 2.3 Stations

Actions :

- créer station ;
- modifier station ;
- suspendre/réactiver ;
- générer QR fixe ;
- remplacer/désactiver QR ;
- voir pompistes ;
- voir transactions.

### 2.4 Pompistes

Actions :

- créer pompiste ;
- rattacher à une station ;
- suspendre/réactiver ;
- réinitialiser activation si besoin.

### 2.5 Stations Autorisées Par Entreprise

L'admin Fusy associe une ou plusieurs stations à une entreprise.

Règle MVP :

- une entreprise possède une liste unique de stations autorisées ;
- pas de règles par chauffeur ;
- pas de règles horaires ;
- pas de géofencing.

---

## 3. QR Fixe Station

Chaque station possède un QR fixe.

Le QR contient :

- identifiant public ou token de station ;
- URL/deeplink compatible app chauffeur ;
- aucune information de montant.

Le QR doit être :

- générable depuis l'admin ;
- téléchargeable/imprimable ;
- désactivable ;
- remplaçable.

---

## 4. Audit Minimal

Actions à auditer :

- création/suspension entreprise ;
- crédit manuel compte carburant ;
- création/suspension station ;
- génération/remplacement QR ;
- création/suspension pompiste ;
- modification stations autorisées.

---

## 5. Livrables

- Layout admin Fusy Inertia React.
- CRUD entreprises.
- Création admin entreprise.
- Crédit manuel compte carburant.
- CRUD stations.
- Gestion QR fixe station.
- CRUD pompistes.
- Gestion stations autorisées par entreprise.
- Audit minimal.

---

## 6. Critères De Validation

- Un admin Fusy peut créer une entreprise pilote.
- Un admin Fusy peut créditer manuellement son compte carburant.
- Un admin Fusy peut créer une station et télécharger son QR.
- Un admin Fusy peut créer un pompiste rattaché à une station.
- Un admin Fusy peut autoriser une station pour une entreprise.
- Les actions sensibles sont visibles dans l'audit.

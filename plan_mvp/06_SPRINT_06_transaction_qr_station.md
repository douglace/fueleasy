# Sprint 6 — Flux Transaction QR Station

> **Semaines :** S11-S12  
> **Objectif :** assembler le flux complet chauffeur + pompiste + dashboards autour d'une transaction carburant réelle.  
> **Jalon :** transaction carburant complète de bout en bout.

---

## 1. Objectifs

Finaliser le coeur métier du MVP :

- scan QR station ;
- vérifications avant création ;
- demande en attente ;
- validation pompiste ;
- confirmation PIN chauffeur ;
- débit compte entreprise ;
- débit budget chauffeur ;
- expiration 5 minutes ;
- reçu.

---

## 2. États De Transaction

États MVP :

- `pending_attendant_validation` ;
- `attendant_approved` ;
- `completed` ;
- `rejected` ;
- `expired` ;
- `cancelled` ;
- `blocked`.

`blocked` correspond aux tentatives bloquées avant création financière : station non autorisée, solde insuffisant, budget insuffisant, statut invalide.

---

## 3. Vérifications Avant Création

Avant de créer une demande carburant, l'API vérifie :

- entreprise active ;
- chauffeur actif ;
- station active ;
- QR station actif ;
- station autorisée pour l'entreprise ;
- budget chauffeur suffisant ;
- solde entreprise suffisant ;
- montant positif ;
- type carburant valide.

Si une vérification échoue, aucune transaction financière n'est créée. Un événement d'audit peut être enregistré.

---

## 4. Expiration 5 Minutes

Règle :

- la demande expire 5 minutes après sa création ;
- si le pompiste ne valide pas dans les 5 minutes, statut `expired` ;
- si le pompiste valide mais que le chauffeur ne confirme pas dans les 5 minutes, statut `expired` ;
- aucun débit si expiration.

---

## 5. Débit Final

Le débit a lieu seulement après :

1. validation pompiste ;
2. confirmation PIN chauffeur.

À ce moment :

- solde entreprise diminué ;
- budget chauffeur diminué ;
- reçu généré ;
- transaction `completed`.

Le débit doit être atomique pour éviter les incohérences.

---

## 6. Reçu MVP

Le reçu contient :

- entreprise ;
- chauffeur ;
- station ;
- pompiste ;
- montant ;
- type carburant ;
- date/heure ;
- ID transaction ;
- statut ;
- code court.

---

## 7. Tests Critiques

À couvrir obligatoirement :

- transaction complète réussie ;
- station non autorisée bloquée avant création ;
- solde entreprise insuffisant bloqué avant création ;
- budget chauffeur insuffisant bloqué avant création ;
- pompiste refuse ;
- chauffeur PIN incorrect ;
- expiration avant validation pompiste ;
- expiration après validation pompiste mais avant confirmation chauffeur ;
- double confirmation impossible ;
- débit atomique ;
- reçu généré.

---

## 8. Livrables

- Endpoints transaction complets.
- Jobs ou commandes d'expiration.
- Intégration app chauffeur.
- Intégration app pompiste.
- Reçus.
- Historique transaction côté dashboards.
- Tests critiques.

---

## 9. Critères De Validation

- Le flux complet marche de bout en bout.
- Une transaction réussie débite les bons soldes.
- Une transaction refusée/expirée ne débite rien.
- Les statuts sont cohérents dans les apps et dashboards.
- Les reçus sont disponibles.

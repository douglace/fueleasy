# Sprint 6 — Flux Transaction QR Station

> **Semaines :** S11-S12  
> **Objectif :** assembler le flux complet chauffeur + pompiste + dashboards autour d'une transaction carburant réelle.  
> **Jalon :** transaction carburant complète de bout en bout.

---

## 1. Objectifs

Finaliser le coeur métier du MVP :

- scan QR station ;
- vérifications avant création ;
- demande créée (en attente de confirmation PIN) ;
- confirmation PIN chauffeur (débit immédiat) ;
- débit compte entreprise ;
- débit budget chauffeur ;
- expiration 5 minutes ;
- reçu ;
- consultation et accusé de réception côté pompiste.

---

## 2. États De Transaction

États réels du paiement (`app/Domain/Payments/PaymentStatus.php`) :

- `pending` (demande créée, en attente de confirmation PIN) ;
- `paid` (PIN confirmé, débits effectués, reçu généré) ;
- `expired` (5 minutes dépassées sans confirmation) ;
- `failed` (confirmation échouée, aucun débit) ;
- `refunded` (remboursement a posteriori depuis le back-office).

Un échec des vérifications avant création bloque la transaction **avant enregistrement** (station non autorisée, solde insuffisant, budget insuffisant, statut invalide) : aucun paiement n'est créé, il n'existe donc pas d'état persisté pour ce cas. Il n'existe **aucun état de validation ou de refus pompiste**.

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
- si le chauffeur ne confirme pas son PIN dans les 5 minutes, statut `expired` ;
- aucun débit si expiration.

---

## 5. Débit Final

Le débit a lieu à la **confirmation PIN du chauffeur**.

À ce moment :

- solde entreprise diminué ;
- budget chauffeur diminué ;
- reçu généré ;
- transaction `paid`.

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
- chauffeur PIN incorrect ;
- expiration avant confirmation PIN ;
- double confirmation impossible ;
- débit atomique ;
- reçu généré ;
- accusé de réception pompiste enregistré.

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
- Une transaction expirée ou bloquée ne débite rien.
- Les statuts sont cohérents dans les apps et dashboards.
- Les reçus sont disponibles.

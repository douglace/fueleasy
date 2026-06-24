# Sprint 1 — Fondations Techniques Et Domaine

> **Semaines :** S1-S2  
> **Objectif :** poser le socle Laravel, base de données, rôles, auth, compte carburant et ledger financier minimal.  
> **Jalon :** socle technique validé, tests critiques du ledger en place.

---

## 1. Objectifs

À la fin du sprint, l'équipe doit disposer d'un backend prêt à supporter le MVP B2B :

- application Laravel initialisée ;
- PostgreSQL configuré ;
- Inertia React configuré ;
- authentification web et API mobile ;
- rôles utilisateurs de base ;
- modèles principaux ;
- ledger financier minimal ;
- tests ciblés sur les règles sensibles.

---

## 2. Stack Cible

| Couche | Choix |
|---|---|
| Backend | Laravel |
| Web dashboards | Inertia React |
| Mobile | Flutter |
| Base de données | PostgreSQL |
| Cache/queues | Redis si disponible, sinon database queue au MVP |
| Auth web | Session Laravel |
| Auth mobile | Tokens API type Sanctum |
| Déploiement | VPS staging + production |

---

## 3. Rôles MVP

| Rôle | Description |
|---|---|
| `fusy_admin` | Admin interne Fusy |
| `enterprise_admin` | Admin d'une entreprise cliente |
| `driver` | Chauffeur ou agent terrain |
| `attendant` | Pompiste rattaché à une station |

Les rôles station admin, client B2C, super admin complexe et micro-crédit sont hors MVP.

---

## 4. Modèle De Données Initial

Tables à prévoir dès le socle :

- `users` ;
- `enterprises` ;
- `stations` ;
- `station_qr_codes` ;
- `enterprise_station` ;
- `fuel_accounts` ;
- `drivers` ou profil driver lié à `users` ;
- `driver_budgets` ;
- `budget_events` ;
- `fuel_transactions` ;
- `transaction_events` ;
- `settlement_batches` ;
- `audit_logs`.

Le modèle peut évoluer pendant les sprints, mais les noms doivent rester orientés B2B.

---

## 5. Ledger Financier Minimal

Règles :

- le compte carburant entreprise représente l'argent réel disponible ;
- le budget chauffeur représente une autorisation de dépense ;
- la sur-allocation est autorisée ;
- une transaction ne passe que si le budget chauffeur et le solde entreprise couvrent le montant ;
- le débit réel a lieu uniquement à la finalisation de la transaction ;
- aucune somme n'est débitée si une transaction est refusée, expirée ou annulée.

---

## 6. Tests Critiques Du Sprint

À couvrir dès le sprint 1 :

- crédit manuel du compte carburant ;
- débit du compte carburant ;
- refus de débit si solde insuffisant ;
- création budget chauffeur ;
- sur-allocation autorisée ;
- budget reset manuel/hebdomadaire/mensuel avec remplacement du solde restant ;
- audit des opérations sensibles.

---

## 7. Livrables

- Projet Laravel opérationnel.
- Inertia React installé et rendu sur une page de test.
- Migrations principales.
- Seeders de rôles.
- Auth web basique.
- Auth mobile basique.
- Services de compte carburant et budget.
- Tests unitaires/feature ciblés sur ledger et budgets.

---

## 8. Critères De Validation

- Les migrations passent sur une base propre.
- Un admin Fusy peut se connecter au web.
- Les rôles existent.
- Un compte carburant peut être crédité et débité via service backend.
- Une sur-allocation de budgets chauffeurs est possible.
- Un débit est refusé si le solde entreprise est insuffisant.
- Les tests critiques du sprint passent.

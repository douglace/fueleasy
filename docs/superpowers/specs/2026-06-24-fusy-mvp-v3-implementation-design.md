# Fusy MVP V3 — Design d’implémentation

Date : 2026-06-24
Statut : validé
Source produit : `docs/superpowers/specs/2026-06-23-fusy-mvp-v3-design.md`

## 1. Décision de référence

La V3 remplace le flux V2 fondé sur une validation préalable du pompiste.

Le parcours de référence est désormais le suivant :

- une seule application Flutter Android/iOS adapte son interface au rôle chauffeur ou pompiste ;
- le QR dynamique associé à la session du pompiste et à la pompe est le parcours principal ;
- le QR fixe de pompe est le parcours de secours ;
- le chauffeur confirme le paiement avec son PIN ;
- le débit devient immédiatement définitif côté serveur ;
- le pompiste vérifie le statut serveur avant de servir et ne valide ni ne refuse le paiement.

Les documents décrivant encore deux applications mobiles, un QR fixe de station comme parcours principal ou une validation du pompiste avant débit sont obsolètes et doivent être alignés sur cette décision.

## 2. Stratégie de livraison

L’implémentation est découpée en tranches métier verticales. Chaque tranche livre ensemble son modèle, ses règles métier, ses cas d’usage, ses endpoints et son interface. Elle se termine par un comportement métier testable de bout en bout.

L’ordre de livraison est :

1. socle V3, documentation alignée, application Flutter et CI ;
2. organisations, utilisateurs, rôles et isolation ;
3. ledger, compte entreprise et budgets chauffeur ;
4. onboarding et dashboard Admin Fusy ;
5. dashboard entreprise ;
6. dashboard station, pompes et carburants ;
7. authentification mobile, PIN et appareil unique ;
8. QR dynamique, QR fixe de secours et paiement atomique ;
9. alertes pompiste, reçus et SMS de secours ;
10. remboursements, reversements et exports ;
11. simulations Orange Money, MTN MoMo et USSD ;
12. QA, déploiement et pilote.

## 3. Architecture

Le monorepo contient deux applications :

- `apps/platform` : Laravel, API, moteur métier et dashboards Inertia React ;
- `apps/mobile` : application Flutter unifiée pour les chauffeurs et pompistes.

Dans `apps/platform` :

- `app/Domain` contient les règles métier, les états et les invariants indépendants de HTTP ;
- `app/Application` orchestre les cas d’usage et les transactions atomiques ;
- `app/Http` expose les contrôleurs web et l’API mobile versionnée ;
- `resources/js` contient les interfaces Admin Fusy, entreprise et station ;
- PostgreSQL est la source de vérité métier et financière.

Toute donnée métier appartient explicitement à une organisation, à l’exception des opérations globales réalisées par un Admin Fusy. Les autorisations doivent vérifier l’organisation côté serveur ; un filtrage d’interface ne constitue jamais une frontière de sécurité.

Le ledger est immuable. Une correction financière produit une écriture compensatoire et ne modifie jamais une écriture existante.

## 4. Modules métier

### Identity

Gère les utilisateurs, rôles, PIN, appareils enregistrés, sessions et blocages d’authentification.

### Organizations

Gère les entreprises, stations, codes d’organisation, statuts et paramètres propres à chaque type d’organisation.

### FuelAccounts

Gère le compte carburant réel de l’entreprise, les crédits manuels et le ledger financier.

### DriverBudgets

Gère les allocations chauffeur et les resets manuels, hebdomadaires ou mensuels. Un reset remplace le budget restant ; il ne l’additionne pas.

### Stations

Gère les pompes, carburants disponibles, pompistes et sessions de travail.

### Payments

Gère les QR signés, sessions de paiement, contrôles d’éligibilité, idempotence et débit atomique.

### Operations

Gère les reçus, remboursements totaux, lots de reversement et exports.

### Demo

Gère les simulations Orange Money, MTN MoMo et USSD. Les données et soldes de démonstration sont isolés des comptes réels et des reversements.

### Audit

Enregistre les opérations sensibles, notamment les changements de statut, crédits manuels, réinitialisations de PIN, changements d’appareil, paiements et remboursements.

## 5. Flux de paiement

1. Le pompiste ouvre une session de travail sur une pompe.
2. Le serveur produit un QR signé valable 60 secondes.
3. Le chauffeur scanne le QR dynamique ou le QR fixe de secours.
4. Le serveur vérifie l’organisation, le chauffeur, la station, la pompe, les carburants disponibles et les stations autorisées.
5. Le chauffeur choisit le carburant et saisit le montant en FCFA.
6. Le serveur crée une session de paiement valable cinq minutes.
7. Le chauffeur confirme avec son PIN.
8. Une transaction PostgreSQL verrouille le compte entreprise et le budget chauffeur.
9. Le serveur revérifie le solde, le budget, les statuts et l’expiration sous verrou.
10. Le compte, le budget, le paiement et les écritures ledger sont enregistrés atomiquement.
11. Le serveur génère le reçu et retourne le statut `paid`.
12. Le pompiste reçoit l’alerte et vérifie le paiement dans l’historique serveur avant de servir.

L’historique serveur est la preuve du paiement. Une capture d’écran présentée par le chauffeur n’en est jamais une.

## 6. Garanties et erreurs

Aucun débit n’est autorisé si le QR, l’organisation, l’utilisateur, la station, la pompe, le carburant, la session, le budget ou le solde est invalide.

Chaque confirmation possède une clé d’idempotence. Les contrôles financiers sont exécutés une première fois avant la confirmation, puis répétés dans la transaction de débit après verrouillage des lignes concernées.

Le débit du compte entreprise, le débit du budget chauffeur, le paiement et les écritures ledger appartiennent à une seule transaction PostgreSQL. Toute erreur provoque un rollback complet.

Le mobile n’affiche jamais un paiement réussi sans réponse positive du serveur. Une perte réseau après envoi déclenche une consultation du statut par clé d’idempotence avant toute nouvelle tentative.

Le QR fixe de secours applique les mêmes règles métier que le QR dynamique. L’absence de session pompiste dans le QR fixe ne supprime ni les contrôles de pompe ni la vérification serveur par le pompiste.

Un remboursement total approuvé crée des écritures compensatoires pour le compte entreprise, le budget chauffeur et le reversement station. Le paiement original reste inchangé dans l’historique.

## 7. Stratégie de tests

Chaque tranche verticale suit un cycle test-first et contient les niveaux pertinents parmi :

- tests unitaires des règles et transitions métier ;
- tests d’intégration PostgreSQL pour les verrous, la concurrence, l’atomicité et l’idempotence ;
- tests API des permissions et de l’isolation entre organisations ;
- tests fonctionnels Inertia des dashboards ;
- tests Flutter des parcours chauffeur et pompiste ;
- tests de bout en bout du paiement, de la perte réseau et du remboursement ;
- tests terrain sur Android bas ou milieu de gamme et sur iPhone.

SQLite peut rester utilisé pour les tests sans comportement spécifique à PostgreSQL. Les scénarios de concurrence, de verrouillage et de contraintes financières doivent obligatoirement être exécutés sur PostgreSQL.

## 8. Critères d’acceptation techniques

- Une organisation ne peut ni lire ni modifier les données d’une autre organisation.
- Un double envoi avec la même clé d’idempotence ne produit qu’un paiement et qu’un débit.
- Deux paiements concurrents ne peuvent pas dépenser le même solde ou budget.
- Aucun état partiel ne subsiste après une erreur de paiement.
- Un QR dynamique expiré ou un QR fixe révoqué est rejeté.
- Une session de paiement expirée ne peut pas être confirmée.
- Les données démo ne modifient jamais un solde réel ni un reversement.
- Le pompiste peut vérifier côté serveur un paiement avant de servir.
- Un remboursement conserve le paiement initial et produit des écritures compensatoires auditables.

## 9. Hors périmètre

Restent hors MVP : intégrations réelles Orange Money, MTN MoMo et USSD, inscription publique, B2C, microcrédit, paiement en litres, remboursement partiel, commission transactionnelle, multi-app mobile et fonctionnement hors ligne avec validation locale.

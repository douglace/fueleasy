# Sprint 8 — QA, Déploiement Et Pilote

> **Semaines :** S15-S16  
> **Objectif :** stabiliser le produit, préparer staging/production VPS et lancer le pilote contrôlé.  
> **Jalon :** Go/No-Go pilote.

---

## 1. Objectifs

Finaliser le MVP pour usage réel limité :

- tests flux critiques ;
- corrections terrain ;
- documentation déploiement manuel ;
- staging ;
- production ;
- scripts de sauvegarde ;
- onboarding pilote ;
- supports de formation ;
- critères Go/No-Go.

---

## 2. Tests Critiques À Exécuter

### 2.1 Backend

Obligatoire :

- crédit manuel compte carburant ;
- sur-allocation ;
- reset budget manuel/hebdomadaire/mensuel ;
- blocage station non autorisée ;
- blocage solde entreprise insuffisant ;
- blocage budget chauffeur insuffisant ;
- transaction réussie ;
- transaction expirée ;
- confirmation PIN ;
- reçu ;
- exports ;
- lot hebdomadaire reversement.

### 2.2 Mobile Chauffeur

Obligatoire :

- activation ;
- connexion PIN ;
- scan QR Android ;
- scan QR iOS ;
- station non autorisée ;
- solde insuffisant ;
- création demande ;
- confirmation PIN ;
- historique/reçu.

### 2.3 Mobile Pompiste

Obligatoire :

- connexion ;
- demande visible ;
- validation ;
- refus ;
- demande expirée ;
- historique du jour.

### 2.4 Dashboards

Obligatoire :

- création entreprise ;
- crédit manuel ;
- création station ;
- génération QR ;
- création pompiste ;
- création chauffeur ;
- configuration budgets ;
- exports ;
- lots reversement.

---

## 3. Déploiement

Environnements :

- staging VPS ;
- production VPS.

À documenter :

- variables d'environnement ;
- migrations ;
- seed admin Fusy ;
- build Inertia React ;
- build mobile test ;
- configuration queue/cron expiration ;
- sauvegarde PostgreSQL ;
- procédure rollback simple ;
- monitoring minimal logs.

Déploiement automatique complet hors MVP. Déploiement manuel documenté accepté.

---

## 4. Pilote Terrain

Objectifs :

- 3 entreprises pilotes minimum ;
- cible idéale 5 entreprises si support maîtrisé ;
- 3 stations pilotes minimum ;
- cible idéale 5 stations ;
- 5 à 15 chauffeurs par entreprise ;
- limite haute 30 chauffeurs si entreprise très motivée.

Composition :

- 1 PME avec équipes terrain ;
- 1 entreprise transport/logistique/BTP ;
- 1 entreprise opportuniste selon meilleur contact disponible.

---

## 5. Formation Et Support

Préparer :

- fiche admin Fusy ;
- fiche admin entreprise ;
- fiche chauffeur ;
- fiche pompiste ;
- script de formation station ;
- procédure incident transaction ;
- procédure solde entreprise insuffisant ;
- procédure remplacement QR station.

---

## 6. Critères Go/No-Go

Go si :

- le flux transaction complet est stable ;
- aucune incohérence de solde connue ;
- expiration 5 minutes fonctionne ;
- les QR stations pilotes sont générés et testés ;
- au moins 3 stations sont prêtes ;
- au moins 3 entreprises sont prêtes ou en cours d'onboarding ;
- les supports de formation sont prêts ;
- staging et production sont opérationnels.

No-Go si :

- débit financier incohérent ;
- confirmation PIN chauffeur instable ;
- accusé de réception pompiste instable ;
- app chauffeur ne scanne pas correctement QR sur appareils pilotes ;
- reçu ou historique incohérent ;
- aucune station pilote réellement prête ;
- aucune entreprise prête à tester.

---

## 7. Critère De Succès MVP

Le MVP est considéré validé si :

- le flux technique fonctionne en conditions réelles ;
- les entreprises pilotes utilisent le produit avec des chauffeurs réels ;
- les stations valident les transactions ;
- au moins une entreprise accepte de payer après le pilote.

---

## 8. Livrables

- Produit stabilisé.
- Staging VPS.
- Production VPS.
- Documentation déploiement manuel.
- Supports de formation.
- Checklist Go/No-Go.
- Rapport pilote initial.

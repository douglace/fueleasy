# Fusy — Plan MVP B2B

> **Version :** 2.0  
> **Date :** 2026-06-16  
> **Statut :** Nouveau plan de référence MVP  
> **Durée cible :** 4 mois, 8 sprints de 2 semaines  
> **Positionnement :** gestion B2B des budgets carburant pour entreprises et flottes

---

## 1. Résumé Produit

Fusy aide les entreprises à remplacer les bons carburant papier et les avances cash par un compte carburant prépayé, des budgets par chauffeur, des stations autorisées et une validation digitale à la pompe.

Le MVP est volontairement B2B et fermé. Les entreprises sont créées par Fusy après signature commerciale. Les stations et les pompistes sont également créés manuellement par Fusy. L'objectif n'est pas de lancer un wallet carburant grand public, mais de valider qu'une entreprise accepte de payer pour contrôler ses dépenses carburant.

---

## 2. Décisions MVP Validées

| Sujet | Décision |
|---|---|
| Durée | 4 mois, 8 sprints de 2 semaines |
| Nom dans les documents | Fusy |
| Modèle économique | Abonnement uniquement |
| Rechargement entreprise | Manuel : dépôt, virement ou transfert hors plateforme, validé par admin Fusy |
| Intégration Orange/MTN | Hors MVP |
| Entreprises pilotes | 3 minimum, cible idéale 5 |
| Stations pilotes | 3 minimum, cible idéale 5 |
| Chauffeurs pilotes | 5 à 15 par entreprise, limite haute 30 si entreprise très motivée |
| App chauffeur | Flutter Android + iOS |
| App pompiste | Flutter Android uniquement |
| Dashboards web | Laravel backend + Inertia React |
| Stations autorisées | Liste définie par entreprise uniquement |
| QR station | QR fixe par station, désactivable/remplaçable |
| Validation transaction | Pompiste valide d'abord, chauffeur confirme ensuite par PIN |
| PIN chauffeur | Obligatoire pour chaque transaction validée par pompiste |
| Expiration transaction | 5 minutes |
| Budget chauffeur | Manuel, hebdomadaire ou mensuel |
| Reset budget | Remplace le solde restant, ne l'ajoute pas |
| Sur-allocation | Autorisée |
| Véhicule | Champ libre optionnel, pas de module véhicule complet |
| Notifications | In-app + SMS uniquement pour activation et cas critiques |
| Exports | CSV + PDF simple |
| Reversements station | Suivi manuel + génération d'un lot hebdomadaire simple |
| Déploiement | Staging + production sur VPS, déploiement manuel documenté |
| Tests | Tests ciblés sur les flux critiques, pas d'objectif arbitraire de 80% |

---

## 3. Cibles Du Pilote

Le pilote doit couvrir au moins trois profils d'entreprise :

1. Une PME avec équipes terrain : sécurité, techniciens, ONG, commerciaux, maintenance.
2. Une entreprise transport, logistique ou BTP.
3. Une entreprise opportuniste selon le meilleur contact disponible.

Critère business principal : le MVP est validé si au moins une entreprise accepte de payer après le pilote, en plus du bon fonctionnement technique.

---

## 4. Surfaces Produit

### 4.1 Dashboard Admin Fusy

Permet à Fusy de gérer :

- entreprises ;
- comptes admins entreprise ;
- crédits manuels du compte carburant ;
- stations ;
- QR fixes de station ;
- pompistes ;
- stations autorisées par entreprise ;
- transactions ;
- lots hebdomadaires de reversement ;
- statuts et suspensions ;
- audit minimal.

### 4.2 Dashboard Entreprise

Permet à une entreprise de gérer :

- solde du compte carburant ;
- chauffeurs ;
- budgets chauffeur ;
- modes de reset manuel/hebdomadaire/mensuel ;
- stations autorisées ;
- transactions ;
- reçus ;
- exports CSV/PDF ;
- alertes de solde bas ou refus.

### 4.3 App Chauffeur

Permet au chauffeur de :

- activer son compte avec téléphone + code SMS/activation ;
- définir un PIN à 4 chiffres ;
- consulter son budget disponible ;
- scanner le QR fixe station ;
- saisir montant et type carburant ;
- confirmer par PIN après validation pompiste ;
- consulter historique et reçus.

### 4.4 App Pompiste

Permet au pompiste de :

- se connecter avec téléphone + PIN ;
- voir les demandes en attente pour sa station ;
- vérifier le code court ;
- valider ou refuser ;
- consulter l'historique du jour.

Le pompiste ne modifie jamais le montant. Si le montant est faux, il refuse et le chauffeur recrée la demande.

---

## 5. Parcours Transaction Principal

1. L'entreprise alimente son compte carburant hors plateforme.
2. Admin Fusy valide le dépôt et crédite le compte carburant.
3. Admin entreprise crée les chauffeurs et budgets.
4. Chauffeur scanne le QR fixe de la station.
5. Fusy vérifie : station autorisée, chauffeur actif, entreprise active, station active, budget chauffeur, solde entreprise.
6. Si une vérification échoue, la transaction est bloquée avant création.
7. Chauffeur saisit montant et type carburant.
8. Une demande est créée pour 5 minutes.
9. Pompiste valide ou refuse dans l'app pompiste.
10. Si validée, chauffeur confirme par PIN.
11. Fusy débite le compte entreprise et le budget chauffeur.
12. Reçu généré et visible côté chauffeur, entreprise, station et admin.

---

## 6. Out Of Scope MVP

Sont explicitement exclus :

- B2C public ;
- micro-crédit ;
- portefeuille personnel ;
- intégration Orange Money ou MTN MoMo automatique ;
- paiement carte bancaire ;
- inscription self-service entreprise ;
- onboarding self-service station ;
- commission sur transaction ;
- commission station ;
- module véhicule complet ;
- départements ;
- règles par chauffeur pour les stations ;
- règles horaires ;
- géolocalisation avancée ;
- USSD ;
- programme fidélité ;
- notifications push FCM ;
- import CSV/Excel chauffeur ;
- API publique ;
- BI avancée.

---

## 7. Matrice Des Sprints

| Sprint | Semaines | Objectif | Jalon |
|---|---:|---|---|
| Sprint 1 | S1-S2 | Fondations, auth, rôles, base financière | Socle technique validé |
| Sprint 2 | S3-S4 | Dashboard admin Fusy | Fusy peut créer entreprises, stations, pompistes |
| Sprint 3 | S5-S6 | Dashboard entreprise | Entreprise peut gérer chauffeurs, budgets, stations autorisées |
| Sprint 4 | S7-S8 | App chauffeur Flutter Android/iOS | Chauffeur peut activer compte et initier demande |
| Sprint 5 | S9-S10 | App pompiste Flutter Android | Pompiste peut valider/refuser |
| Sprint 6 | S11-S12 | Flux QR station complet | Transaction carburant complète de bout en bout |
| Sprint 7 | S13-S14 | Reporting, exports, reversements | Exports et lots hebdomadaires disponibles |
| Sprint 8 | S15-S16 | QA, pilote, déploiement | Go/No-Go pilote |

---

## 8. Critères De Succès MVP

### Critères Business

- 3 entreprises pilotes minimum onboardées.
- Cible idéale : 5 entreprises si le support terrain reste maîtrisé.
- 3 stations pilotes minimum.
- Cible idéale : 5 stations.
- 5 à 15 chauffeurs actifs par entreprise.
- Au moins 1 entreprise accepte de payer après le pilote.

### Critères Produit

- Une entreprise peut être créée manuellement par Fusy.
- Un compte carburant entreprise peut être crédité manuellement.
- Une entreprise peut créer un chauffeur et lui attribuer un budget.
- Un chauffeur peut scanner un QR station fixe.
- Une station non autorisée bloque la transaction avant création.
- Un solde entreprise insuffisant bloque la transaction avant création.
- Un pompiste peut valider ou refuser une demande.
- Le chauffeur confirme par PIN.
- La transaction expire après 5 minutes si non finalisée.
- Le reçu est consultable.
- Les exports CSV/PDF sont disponibles.
- Les lots hebdomadaires de reversement sont générables.

---

## 9. Risques Principaux

| Risque | Impact | Mitigation MVP |
|---|---|---|
| Adoption pompiste faible | Élevé | App pompiste minimaliste, formation station, 3 à 5 stations maximum |
| Solde entreprise insuffisant en station | Élevé | Blocage avant création, alertes solde bas, statut visible côté chauffeur |
| Confusion budget vs argent réel | Élevé | Séparer budget chauffeur et compte carburant entreprise dans l'interface |
| QR fixe copié | Moyen | Validation pompiste obligatoire, QR désactivable, station affichée avant saisie |
| Complexité front web | Moyen | Inertia React simple, composants sobres, pas de design system lourd |
| Réglementaire paiement | Élevé | Pilote fermé, recharge manuelle, pas de micro-crédit, validation juridique avant extension |
| Support terrain trop lourd | Moyen | Limiter à 3 entreprises minimum, cible 5 si maîtrisé |

---

## 10. Documents De Référence

- `docs/superpowers/specs/2026-06-15-fusy-mvp-b2b-design.md`
- `docs/business/dossier-presentation-business-fusy.md`
- `docs/business/dossier-presentation-business-fusy.pdf`

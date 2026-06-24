# Cahier des Charges Final — Fusy

| | |
|---|---|
| **Projet** | Fusy — Digitalisation des bons de carburant |
| **Version** | 1.0 |
| **Date** | 17 février 2026 |
| **Statut** | Validé — Prêt pour développement |
| **Pays cible** | Cameroun |
| **Porteur** | Startup indépendante |
| **Confidentialité** | Document confidentiel |

---

## Table des matières

1. [Résumé exécutif](#1-résumé-exécutif)
2. [Contexte et problématique](#2-contexte-et-problématique)
3. [Objectifs du projet](#3-objectifs-du-projet)
4. [Périmètre du projet](#4-périmètre-du-projet)
5. [Acteurs et parties prenantes](#5-acteurs-et-parties-prenantes)
6. [Modèle économique](#6-modèle-économique)
7. [Exigences fonctionnelles détaillées](#7-exigences-fonctionnelles-détaillées)
8. [Exigences non fonctionnelles](#8-exigences-non-fonctionnelles)
9. [Architecture technique](#9-architecture-technique)
10. [Parcours utilisateurs](#10-parcours-utilisateurs)
11. [Modèle de données](#11-modèle-de-données)
12. [Roadmap et phasage](#12-roadmap-et-phasage)
13. [Analyse des risques](#13-analyse-des-risques)
14. [Critères de recette](#14-critères-de-recette)
15. [Stratégie d'acquisition des stations partenaires](#15-stratégie-dacquisition-des-stations-partenaires)
16. [Annexes](#16-annexes)

---

## 1. Résumé exécutif

### Le problème

Au Cameroun, le système de bons de carburant repose entièrement sur des supports papier. Ce mode de fonctionnement génère des inefficacités majeures : fraude facilitée (falsification, duplication de bons), lourdeur administrative pour les entreprises (comptabilité manuelle, archivage physique), absence de traçabilité fiable et exclusion des travailleurs indépendants et des populations à revenus fluctuants qui n'ont pas accès aux systèmes de prépaiement carburant.

### La solution

**Fusy** est une plateforme mobile et web qui digitalise intégralement le cycle de vie des bons de carburant. L'application permet à tout utilisateur de recharger un portefeuille numérique (via Orange Money ou MTN MoMo), d'acheter du carburant dans les stations partenaires via un système de validation sécurisé (QR Code + OTP), et de suivre ses dépenses en temps réel. Pour les entreprises, un dashboard B2B offre la gestion complète des flottes de véhicules avec plafonds, restrictions et rapports détaillés.

### Le marché

Le Cameroun compte environ 27 millions d'habitants, un parc automobile en croissance estimé à 600 000 véhicules, et un taux de pénétration du mobile money supérieur à 40%. Le marché de la distribution de carburant représente plus de 1 500 milliards FCFA par an. Aucune solution digitale de gestion des bons de carburant n'existe actuellement sur le marché camerounais.

### L'ambition

Devenir la plateforme de référence pour la gestion digitale des dépenses de carburant au Cameroun, avec une expansion progressive vers la zone CEMAC. L'objectif à 12 mois est d'atteindre 15 000 utilisateurs actifs mensuels et un volume de transactions de 500 millions FCFA cumulés.

---

## 2. Contexte et problématique

### 2.1 Situation actuelle

Le système de bons de carburant papier est profondément ancré dans les pratiques camerounaises, tant dans le secteur public (primes carburant des fonctionnaires) que privé (flottes d'entreprises). Ce système présente des failles structurelles :

**Fraude et perte financière**
- Les bons papier sont facilement falsifiables ou duplicables
- Les pompistes peuvent détourner des bons ou gonfler les montants
- Les entreprises estiment entre 15% et 25% de perte liée à la fraude sur les bons carburant

**Inefficacité opérationnelle**
- Processus de création, distribution et validation entièrement manuel
- Comptabilité fastidieuse nécessitant le traitement physique de chaque bon
- Délais de réconciliation entre entreprises et stations (jusqu'à 30 jours)

**Exclusion financière**
- Les travailleurs indépendants (taximen, moto-taximen, commerçants) n'ont pas accès aux systèmes de bons d'entreprise
- Aucune solution de prépaiement carburant accessible aux particuliers
- Pas de possibilité d'avance carburant pour les travailleurs à revenus irréguliers

**Contraintes logistiques**
- Stockage physique volumineux et risque de détérioration
- Distribution géographique contraignante (zones rurales mal desservies)
- Impact environnemental de la production papier

### 2.2 Opportunité de marché

Plusieurs facteurs convergent pour rendre cette digitalisation viable :

- **Pénétration mobile money** : Plus de 40% de la population utilise Orange Money ou MTN MoMo, créant une infrastructure de paiement digital mature
- **Adoption smartphone** : Le taux de pénétration des smartphones atteint 45% au Cameroun, en croissance rapide
- **Volonté politique** : Le gouvernement camerounais encourage la transformation digitale des services
- **Absence de concurrence directe** : Aucune solution spécialisée n'existe sur ce segment au Cameroun
- **Taille du marché** : Plus de 1 200 stations-service dans le pays, dont environ 400 dans les zones urbaines de Douala et Yaoundé

---

## 3. Objectifs du projet

### 3.1 North Star Metric

**Volume mensuel de transactions carburant traitées via Fusy (en FCFA)**

Cette métrique unique reflète la valeur créée pour tous les acteurs : plus le volume transactionnel est élevé, plus les utilisateurs font confiance à la plateforme, plus les stations ont intérêt à y participer, et plus le modèle économique est viable.

### 3.2 Objectifs SMART

| Objectif | Indicateur | Cible MVP (M4) | Cible M8 | Cible M12 |
|---|---|---|---|---|
| Adoption utilisateurs | Utilisateurs actifs mensuels (MAU) | 2 000 | 8 000 | 15 000 |
| Volume transactionnel | FCFA traités/mois | 25 M FCFA | 150 M FCFA | 500 M FCFA |
| Couverture stations | Stations partenaires actives | 15 | 50 | 120 |
| Adoption B2B | Entreprises clientes actives | 5 | 25 | 60 |
| Satisfaction | NPS utilisateurs | > 30 | > 40 | > 50 |
| Fiabilité | Taux de succès des transactions | > 95% | > 98% | > 99% |
| Micro-crédit | Taux de remboursement | > 90% | > 92% | > 95% |

### 3.3 KPIs opérationnels

- **Temps moyen d'une transaction à la pompe** : < 60 secondes (scan QR + OTP)
- **Délai de réconciliation financière** : Temps réel (vs. 30 jours en mode papier)
- **Coût d'acquisition utilisateur (CAC)** : < 1 500 FCFA
- **Lifetime Value (LTV) moyen** : > 15 000 FCFA sur 12 mois
- **Taux de rétention M1** : > 60%
- **Taux de rétention M3** : > 40%

---

## 4. Périmètre du projet

### 4.1 Dans le périmètre (In Scope)

**MVP (Mois 1-4)**
- Application mobile Android et iOS (Flutter)
- Inscription et authentification (téléphone + OTP)
- Portefeuille numérique avec recharge via Orange Money et MTN MoMo
- Achat de carburant et paiement en station
- Validation à la pompe par QR Code + OTP
- Application pompiste (scan QR et validation)
- Dashboard web B2B : gestion de flotte, plafonds, attribution crédits
- Module micro-crédit simplifié (avance carburant avec scoring basique)
- Dashboard admin (supervision, rapports, gestion stations)
- Notifications push et SMS

**Phase 2 (Mois 5-8)**
- Canal USSD pour téléphones basiques
- Micro-crédit avancé (scoring enrichi, paliers progressifs)
- Géolocalisation des stations partenaires (carte interactive)
- Fonctionnalité d'épargne carburant
- Rapports B2B avancés (export PDF/Excel, analytics)
- Programme de fidélité

**Phase 3 (Mois 9-12)**
- Expansion zone CEMAC (Gabon, Congo, Tchad)
- Partenariats institutionnels (fonction publique, ONG)
- Analytics avancés et intelligence tarifaire
- API ouverte pour intégrations tierces
- Carte physique liée au compte digital

### 4.2 Hors périmètre (Out of Scope)

- Vente directe de carburant (Fusy est un intermédiaire de paiement)
- Gestion des stocks de carburant des stations
- Maintenance des équipements de station
- Paiement par carte bancaire Visa/Mastercard (pas pertinent pour le marché cible au MVP)
- Application desktop native
- Livraison de carburant à domicile

### 4.3 Contraintes

| Contrainte | Description |
|---|---|
| Réglementaire | Conformité aux régulations CEMAC/COBAC pour les opérations de paiement et de micro-crédit |
| Technique | Fonctionnement en zones de connectivité réduite (mode offline partiel requis) |
| Infrastructure | Dépendance aux APIs des opérateurs Mobile Money (Orange Money, MTN MoMo) |
| Monétaire | Toutes les transactions en FCFA (XAF), pas de conversion de devises |
| Linguistique | Interface en français (langue officielle), avec préparation pour le bilinguisme (anglais) dans les régions anglophones |

### 4.4 Hypothèses

- Les opérateurs Orange Money et MTN MoMo mettent à disposition des APIs d'intégration stables
- Les stations-service partenaires disposent d'un minimum de connectivité (2G/3G suffisant)
- Le cadre réglementaire camerounais permet l'opération d'un portefeuille numérique intermédiaire sans licence bancaire complète (agrément EME ou partenariat avec un établissement agréé)
- Les pompistes ont accès à un smartphone Android (fourni ou personnel) pour l'application pompiste
- Le taux de pénétration smartphone dans la cible B2C est suffisant pour atteindre les objectifs MVP

---

## 5. Acteurs et parties prenantes

### 5.1 Rôles utilisateurs

#### Particulier (B2C)
- Crée un compte, recharge son portefeuille via Mobile Money
- Achète du carburant en station via QR Code + OTP
- Consulte son historique de transactions et son solde
- Peut demander un micro-crédit carburant
- Reçoit des notifications (solde bas, remboursement micro-crédit, promotions)

#### Entreprise / Administrateur B2B
- Crée un compte entreprise avec vérification (RCCM, NIU)
- Gère une flotte de véhicules et de conducteurs
- Attribue des crédits carburant aux conducteurs avec plafonds (journalier, hebdomadaire, mensuel)
- Définit des restrictions (type de carburant, stations autorisées, horaires)
- Consulte des rapports détaillés par véhicule, conducteur ou département
- Recharge le compte entreprise via Mobile Money ou virement

#### Pompiste
- Se connecte à l'application pompiste (compte lié à une station)
- Scanne le QR Code présenté par le client
- Confirme le montant et le type de carburant
- Reçoit la confirmation de validation de la transaction
- Consulte l'historique des transactions traitées dans sa session

#### Administrateur de station
- Gère les comptes pompistes de sa station
- Consulte les transactions et le chiffre d'affaires généré via Fusy
- Valide les réconciliations financières
- Gère les horaires et les affectations des pompistes

#### Super Administrateur (Fusy)
- Supervise l'ensemble de la plateforme
- Gère les stations partenaires (onboarding, suspension, paramétrage)
- Configure les paramètres système (commissions, plafonds micro-crédit, etc.)
- Accède aux analytics globaux et aux rapports financiers
- Gère les litiges et le support niveau 2
- Administre les utilisateurs et les rôles

### 5.2 Matrice RACI

| Activité | Particulier | Entreprise B2B | Pompiste | Admin Station | Super Admin |
|---|---|---|---|---|---|
| Inscription & KYC | R | R | I | R | A |
| Recharge portefeuille | R | R | — | — | I |
| Achat carburant | R | I | R | I | I |
| Validation à la pompe | C | — | R | I | I |
| Gestion flotte | — | R | — | — | I |
| Attribution crédits | — | R | — | — | I |
| Demande micro-crédit | R | — | — | — | A |
| Réconciliation financière | — | I | — | R | A |
| Supervision plateforme | — | — | — | — | R |
| Gestion litiges | C | C | C | C | R |
| Paramétrage système | — | — | — | — | R |

*R = Responsable, A = Approbateur, C = Consulté, I = Informé*

---

## 6. Modèle économique

### 6.1 Modèle hybride : Commission + Abonnement

Fusy adopte un modèle économique hybride combinant revenus transactionnels et revenus récurrents.

#### Sources de revenus

| Source | Description | Tarification |
|---|---|---|
| **Commission sur transactions** | Prélevée sur chaque achat de carburant via la plateforme | 1.5% du montant (B2C) / 2% du montant (B2B) |
| **Abonnement B2B** | Accès au dashboard de gestion de flotte, rapports et fonctionnalités avancées | 25 000 FCFA/mois (Starter, 1-10 véhicules) / 75 000 FCFA/mois (Business, 11-50 véhicules) / 150 000 FCFA/mois (Enterprise, 50+ véhicules) |
| **Intérêts micro-crédit** | Frais appliqués sur les avances carburant | 5% du montant emprunté (remboursement sous 30 jours) |
| **Services premium** | Rapports personnalisés, intégrations API, support dédié | Sur devis |

#### Gratuité pour les particuliers
- Inscription gratuite
- Recharge du portefeuille gratuite
- Consultation de l'historique et du solde gratuite
- Seule la commission de 1.5% sur l'achat de carburant s'applique

### 6.2 Flux financiers

```
┌─────────────┐     Recharge (Mobile Money)      ┌──────────────┐
│ Utilisateur │ ──────────────────────────────────▶│  Portefeuille │
│  (ou B2B)   │                                    │   Fusy    │
└─────────────┘                                    └──────┬───────┘
                                                          │
                                              Achat carburant
                                              (montant - commission)
                                                          │
                                                          ▼
                                                   ┌──────────────┐
                                                   │   Station     │
                                                   │  Partenaire   │
                                                   └──────────────┘

Commission Fusy = 1.5% à 2% par transaction
Reversement station = montant transaction - commission
Cycle de reversement = J+1 (quotidien) ou hebdomadaire selon contrat
```

### 6.3 Projections financières simplifiées (Année 1)

| Trimestre | MAU estimés | Volume transactionnel | Revenus commissions | Revenus abonnements B2B | Revenus micro-crédit | Total revenus |
|---|---|---|---|---|---|---|
| T1 (M1-M3) | 500 | 10 M FCFA | 175 000 | 0 | 0 | 175 000 |
| T2 (M4-M6) | 3 000 | 75 M FCFA | 1 312 000 | 375 000 | 200 000 | 1 887 000 |
| T3 (M7-M9) | 8 000 | 300 M FCFA | 5 250 000 | 1 125 000 | 750 000 | 7 125 000 |
| T4 (M10-M12) | 15 000 | 750 M FCFA | 13 125 000 | 2 250 000 | 1 500 000 | 16 875 000 |
| **Total Année 1** | — | **1 135 M FCFA** | **19 862 000** | **3 750 000** | **2 450 000** | **26 062 000** |

*Note : Ces projections sont des estimations conservatrices basées sur un panier moyen de 15 000 FCFA par transaction et une fréquence de 3 transactions/mois par utilisateur actif.*

---

## 7. Exigences fonctionnelles détaillées

### 7.1 Module Authentification & Profils

**Phase : MVP**

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité |
|---|---|---|---|---|
| AUTH-01 | Visiteur | m'inscrire avec mon numéro de téléphone et un OTP | créer mon compte rapidement | P1 |
| AUTH-02 | Utilisateur | me connecter avec mon numéro et un code PIN à 4 chiffres | accéder à mon compte de manière sécurisée | P1 |
| AUTH-03 | Utilisateur | compléter mon profil (nom, prénom, CNI, photo) | valider mon identité pour le KYC | P1 |
| AUTH-04 | Entreprise | créer un compte entreprise avec vérification RCCM/NIU | accéder aux fonctionnalités B2B | P1 |
| AUTH-05 | Admin station | créer des comptes pompistes rattachés à ma station | permettre la validation des transactions | P1 |
| AUTH-06 | Utilisateur | réinitialiser mon code PIN via OTP | récupérer l'accès à mon compte | P1 |
| AUTH-07 | Utilisateur | activer l'authentification biométrique (empreinte/face) | me connecter plus rapidement | P2 |

#### Critères d'acceptation — AUTH-01

- L'utilisateur saisit un numéro de téléphone camerounais valide (format +237 6XX XXX XXX)
- Un OTP à 6 chiffres est envoyé par SMS dans un délai < 30 secondes
- L'OTP expire après 5 minutes
- Après 3 tentatives échouées, le compte est temporairement bloqué (15 minutes)
- Après validation de l'OTP, l'utilisateur définit un code PIN à 4 chiffres
- Le compte est créé avec le statut "non vérifié" jusqu'à complétion du KYC

#### Critères d'acceptation — AUTH-04

- L'entreprise fournit : raison sociale, RCCM, NIU, adresse, contact du responsable
- Les documents sont uploadés (photo/scan du RCCM, attestation NIU)
- Le compte entreprise passe en statut "en attente de vérification"
- Le Super Admin valide manuellement les documents sous 48h maximum
- Après validation, l'entreprise accède au dashboard B2B

### 7.2 Module Portefeuille & Recharge

**Phase : MVP**

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité |
|---|---|---|---|---|
| WAL-01 | Utilisateur | consulter mon solde en temps réel | savoir combien je peux dépenser | P1 |
| WAL-02 | Utilisateur | recharger mon portefeuille via Orange Money | alimenter mon compte Fusy | P1 |
| WAL-03 | Utilisateur | recharger mon portefeuille via MTN MoMo | alimenter mon compte Fusy | P1 |
| WAL-04 | Utilisateur | voir l'historique complet de mes transactions | suivre mes dépenses carburant | P1 |
| WAL-05 | Entreprise B2B | recharger le portefeuille entreprise | alimenter les crédits de la flotte | P1 |
| WAL-06 | Utilisateur | recevoir une notification quand mon solde est bas | anticiper une recharge | P1 |
| WAL-07 | Utilisateur | consulter le détail d'une transaction | vérifier les informations d'un achat | P1 |

#### Critères d'acceptation — WAL-02 (Recharge Orange Money)

- L'utilisateur sélectionne "Recharger" et choisit Orange Money
- Il saisit le montant (minimum 500 FCFA, maximum 500 000 FCFA par transaction)
- L'application initie une requête de paiement via l'API Orange Money
- L'utilisateur reçoit un prompt USSD sur son téléphone pour confirmer le paiement
- Il saisit son code PIN Orange Money
- En cas de succès : le solde est crédité en temps réel, une notification push confirme la recharge, la transaction apparaît dans l'historique
- En cas d'échec : un message d'erreur explicite est affiché, aucun montant n'est débité, l'utilisateur peut réessayer
- Un reçu numérique est généré pour chaque recharge réussie

#### Critères d'acceptation — WAL-03 (Recharge MTN MoMo)

- Fonctionnement identique à WAL-02 mais via l'API MTN Mobile Money
- Mêmes plafonds et mêmes règles de gestion

### 7.3 Module Achat Carburant

**Phase : MVP**

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité |
|---|---|---|---|---|
| FUEL-01 | Utilisateur | acheter du carburant pour un montant précis | payer à la pompe avec mon solde Fusy | P1 |
| FUEL-02 | Utilisateur | choisir le type de carburant (Super, Gasoil) | spécifier ce que je veux acheter | P1 |
| FUEL-03 | Utilisateur | générer un QR Code de paiement | présenter mon paiement au pompiste | P1 |
| FUEL-04 | Utilisateur | recevoir un reçu numérique après achat | garder une preuve de ma transaction | P1 |
| FUEL-05 | Conducteur B2B | acheter du carburant avec le crédit attribué par mon entreprise | faire le plein du véhicule de fonction | P1 |
| FUEL-06 | Utilisateur | annuler une transaction non finalisée | corriger une erreur avant validation | P1 |

#### Critères d'acceptation — FUEL-01

- L'utilisateur sélectionne "Acheter du carburant"
- Il saisit le montant souhaité (doit être ≤ solde disponible)
- Il sélectionne le type de carburant (Super ou Gasoil)
- Un QR Code est généré contenant : ID transaction, montant, type carburant, horodatage, ID utilisateur (chiffré)
- Le QR Code est valide pendant 10 minutes
- Le montant est provisionné (bloqué) sur le portefeuille
- Si le QR Code expire sans scan, le montant est libéré automatiquement
- Après validation complète, le montant est débité définitivement

### 7.4 Module Validation à la Pompe (QR Code + OTP)

**Phase : MVP**

Ce module est le coeur de l'expérience Fusy. Il garantit la sécurité des transactions grâce à une double validation.

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité |
|---|---|---|---|---|
| PUMP-01 | Pompiste | scanner le QR Code du client | initier la validation de la transaction | P1 |
| PUMP-02 | Client | recevoir un OTP pour confirmer la transaction | valider que je suis bien l'auteur de l'achat | P1 |
| PUMP-03 | Pompiste | voir la confirmation de la transaction validée | servir le carburant en toute confiance | P1 |
| PUMP-04 | Pompiste | consulter l'historique de mes transactions du jour | suivre mon activité | P1 |
| PUMP-05 | Client | être notifié de la finalisation de la transaction | avoir la confirmation de mon achat | P1 |

#### Flux de validation détaillé

```
ÉTAPE 1 — Génération (Client)
├── Le client ouvre l'app Fusy
├── Sélectionne "Acheter du carburant"
├── Saisit le montant et le type de carburant
├── Un QR Code unique est généré (validité : 10 min)
└── Le montant est provisionné sur le portefeuille

ÉTAPE 2 — Scan (Pompiste)
├── Le pompiste ouvre l'app Pompiste Fusy
├── Scanne le QR Code avec la caméra du smartphone
├── L'écran affiche : montant, type carburant, prénom du client
└── Le pompiste confirme les informations

ÉTAPE 3 — Confirmation OTP (Client)
├── Un OTP à 6 chiffres est envoyé au client par SMS
├── Le client communique l'OTP au pompiste OU le saisit dans son app
├── L'OTP expire après 3 minutes
└── Maximum 3 tentatives, sinon transaction annulée

ÉTAPE 4 — Finalisation
├── La transaction est validée des deux côtés
├── Le montant est débité du portefeuille client
├── Le pompiste reçoit la confirmation à l'écran ("Transaction validée ✓")
├── Le client reçoit une notification push + reçu numérique
└── La station est créditée (montant - commission Fusy)
```

#### Critères d'acceptation — PUMP-01

- Le pompiste est connecté et son compte est actif et rattaché à une station
- L'appareil photo s'ouvre pour scanner le QR Code
- Le scan détecte et décode le QR Code en < 2 secondes
- Les informations sont affichées : montant (ex: "15 000 FCFA"), type carburant (ex: "Super"), prénom client (ex: "Jean")
- Le pompiste peut confirmer ou refuser la transaction
- Si le QR Code est expiré, un message "QR Code expiré" s'affiche

#### Critères d'acceptation — PUMP-02

- L'OTP est envoyé par SMS au numéro de téléphone du client
- L'OTP arrive dans un délai < 15 secondes
- L'OTP est composé de 6 chiffres numériques
- L'OTP est à usage unique et expire après 3 minutes
- Après 3 saisies incorrectes, la transaction est annulée et le montant libéré
- L'OTP peut aussi être saisi directement dans l'app client (alternative au verbal)

### 7.5 Module Gestion de Flotte B2B

**Phase : MVP**

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité |
|---|---|---|---|---|
| B2B-01 | Admin B2B | ajouter des véhicules à ma flotte | gérer mon parc automobile | P1 |
| B2B-02 | Admin B2B | ajouter des conducteurs et les associer à des véhicules | contrôler qui utilise quel véhicule | P1 |
| B2B-03 | Admin B2B | attribuer un crédit carburant mensuel à chaque conducteur | définir le budget carburant par personne | P1 |
| B2B-04 | Admin B2B | définir un plafond journalier de dépense par conducteur | limiter les abus | P1 |
| B2B-05 | Admin B2B | restreindre les types de carburant autorisés par véhicule | éviter les erreurs de carburant | P1 |
| B2B-06 | Admin B2B | consulter un tableau de bord avec les dépenses en temps réel | piloter mon budget carburant | P1 |
| B2B-07 | Admin B2B | générer un rapport mensuel par conducteur/véhicule/département | faciliter la comptabilité | P1 |
| B2B-08 | Admin B2B | recevoir une alerte quand un conducteur atteint 80% de son plafond | anticiper les dépassements | P1 |
| B2B-09 | Admin B2B | suspendre temporairement le crédit d'un conducteur | réagir en cas d'abus ou de départ | P1 |
| B2B-10 | Admin B2B | créer des départements et y affecter véhicules/conducteurs | organiser la gestion par service | P2 |

#### Critères d'acceptation — B2B-03

- L'admin sélectionne un conducteur dans la liste
- Il définit un montant de crédit (en FCFA) et une période (mensuel)
- Le crédit est immédiatement disponible pour le conducteur
- Le conducteur reçoit une notification de crédit attribué
- Le crédit non utilisé en fin de période peut être : reporté, perdu, ou paramétré au choix de l'admin
- L'historique des attributions est consultable

#### Critères d'acceptation — B2B-07

- L'admin sélectionne la période (mois, semaine, personnalisée)
- Il peut filtrer par conducteur, véhicule, département, type de carburant
- Le rapport affiche : total dépensé, nombre de transactions, détail par entrée
- Le rapport peut être visualisé en ligne ou exporté (PDF)
- Les données sont à jour en temps réel

### 7.6 Module Micro-Crédit Carburant

**Phase : MVP (version simplifiée) puis Phase 2 (version avancée)**

#### Cadre réglementaire

Le micro-crédit carburant doit respecter le cadre réglementaire de la COBAC (Commission Bancaire de l'Afrique Centrale) et de la CEMAC. Pour le MVP, Fusy opère soit :
- En partenariat avec un établissement de micro-finance agréé (EMF de catégorie 1 ou 2)
- Sous un régime de crédit commercial (avance sur achat) avec un montant plafonné à 50 000 FCFA

La conformité juridique sera validée avec un cabinet d'avocats spécialisé avant le lancement.

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité | Phase |
|---|---|---|---|---|---|
| CRED-01 | Utilisateur | consulter mon éligibilité au micro-crédit | savoir si je peux obtenir une avance | P1 | MVP |
| CRED-02 | Utilisateur | demander une avance carburant | acheter du carburant quand mon solde est insuffisant | P1 | MVP |
| CRED-03 | Utilisateur | voir les conditions de l'avance (montant, frais, échéance) | prendre une décision éclairée | P1 | MVP |
| CRED-04 | Utilisateur | rembourser mon avance (total ou partiel) | solder ma dette | P1 | MVP |
| CRED-05 | Utilisateur | recevoir des rappels avant l'échéance | ne pas oublier de rembourser | P1 | MVP |
| CRED-06 | Système | calculer un score de crédit basé sur l'historique | évaluer le risque de non-remboursement | P1 | MVP |
| CRED-07 | Utilisateur | accéder à des paliers de crédit progressifs | emprunter davantage à mesure que je rembourse | P2 | Phase 2 |

#### Règles de scoring MVP (simplifié)

| Critère | Poids | Détail |
|---|---|---|
| Ancienneté du compte | 20% | > 30 jours d'activité requis |
| Fréquence de recharge | 25% | Minimum 3 recharges dans les 30 derniers jours |
| Volume transactionnel | 25% | Minimum 20 000 FCFA de transactions dans les 30 derniers jours |
| Historique de remboursement | 30% | Aucun retard de plus de 7 jours sur les crédits précédents |

#### Paliers de crédit MVP

| Palier | Montant max | Condition d'accès | Frais |
|---|---|---|---|
| Palier 1 | 5 000 FCFA | Score ≥ 50/100 + compte > 30 jours | 5% (250 FCFA) |
| Palier 2 | 15 000 FCFA | Score ≥ 65/100 + 2 remboursements à temps | 5% (750 FCFA) |
| Palier 3 | 30 000 FCFA | Score ≥ 80/100 + 5 remboursements à temps | 5% (1 500 FCFA) |
| Palier 4 | 50 000 FCFA | Score ≥ 90/100 + 10 remboursements à temps | 5% (2 500 FCFA) |

#### Critères d'acceptation — CRED-02

- L'utilisateur accède à la section "Avance carburant"
- Son score de crédit est calculé et affiché (éligible ou non)
- S'il est éligible, le montant maximum disponible est affiché
- Il saisit le montant souhaité (≤ montant max du palier)
- Les conditions sont clairement affichées : montant, frais (5%), montant total à rembourser, date d'échéance (30 jours)
- L'utilisateur accepte les conditions (case à cocher + confirmation)
- Le montant est crédité sur son portefeuille Fusy immédiatement
- Un rappel automatique est programmé à J-7, J-3 et J-1 avant l'échéance
- En cas de non-remboursement à l'échéance : blocage du compte après 7 jours de grâce, frais de retard de 2% par semaine de retard

### 7.7 Module Administration

**Phase : MVP**

#### User Stories

| ID | En tant que... | Je veux... | Afin de... | Priorité |
|---|---|---|---|---|
| ADM-01 | Super Admin | voir un tableau de bord global en temps réel | superviser l'activité de la plateforme | P1 |
| ADM-02 | Super Admin | gérer les stations partenaires (ajouter, suspendre, configurer) | maintenir le réseau de distribution | P1 |
| ADM-03 | Super Admin | consulter et traiter les demandes de vérification KYC | valider les nouveaux comptes entreprises | P1 |
| ADM-04 | Super Admin | configurer les paramètres système (commissions, plafonds) | adapter la plateforme aux besoins business | P1 |
| ADM-05 | Super Admin | consulter les logs de transactions et les auditer | détecter et résoudre les anomalies | P1 |
| ADM-06 | Super Admin | gérer les litiges (remboursements, contestations) | maintenir la confiance des utilisateurs | P1 |
| ADM-07 | Super Admin | générer des rapports financiers (revenus, commissions, reversements) | piloter la rentabilité | P1 |
| ADM-08 | Admin station | voir les transactions de ma station | suivre l'activité Fusy dans ma station | P1 |
| ADM-09 | Super Admin | bloquer/débloquer un compte utilisateur | réagir en cas de fraude ou d'abus | P1 |
| ADM-10 | Super Admin | envoyer des notifications ciblées (push/SMS) | communiquer avec les utilisateurs | P2 |

#### Critères d'acceptation — ADM-01

- Le dashboard affiche en temps réel : nombre d'utilisateurs actifs, volume de transactions du jour/semaine/mois, revenus (commissions + abonnements + micro-crédit), nombre de stations actives, taux de succès des transactions
- Des graphiques montrent les tendances (courbes, histogrammes)
- Les données se rafraîchissent automatiquement toutes les 60 secondes
- Le dashboard est accessible via navigateur web (responsive)

---

## 8. Exigences non fonctionnelles

### 8.1 Performance

| Exigence | Cible |
|---|---|
| Temps de réponse API (P95) | < 500ms |
| Temps de génération d'un QR Code | < 2 secondes |
| Temps d'envoi OTP (SMS) | < 15 secondes |
| Temps de chargement de l'app (cold start) | < 3 secondes |
| Capacité de transactions simultanées | 500 transactions/minute au MVP |
| Taille de l'APK Android | < 30 Mo |

### 8.2 Sécurité

| Exigence | Description |
|---|---|
| Chiffrement des données en transit | TLS 1.2 minimum pour toutes les communications |
| Chiffrement des données au repos | AES-256 pour les données sensibles (PIN, données financières) |
| Authentification API | JWT avec refresh token, expiration access token : 15 minutes |
| Protection contre la fraude | Rate limiting sur les endpoints sensibles (login, OTP, transactions) |
| Stockage des mots de passe/PIN | Hachage bcrypt avec salt |
| QR Code | Contenu chiffré et signé, non falsifiable, à usage unique |
| Logs d'audit | Toutes les opérations sensibles sont loguées avec horodatage, IP et identifiant utilisateur |
| Protection OWASP | Application des recommandations OWASP Top 10 (injection, XSS, CSRF, etc.) |
| RGPD / Protection des données | Conformité avec la loi camerounaise sur la protection des données personnelles |

### 8.3 Disponibilité et fiabilité

| Exigence | Cible |
|---|---|
| Disponibilité de la plateforme | 99.5% (hors maintenance planifiée) |
| Fenêtre de maintenance | Mardi 2h-4h (heure de Yaoundé), hebdomadaire si nécessaire |
| RTO (Recovery Time Objective) | < 2 heures |
| RPO (Recovery Point Objective) | < 15 minutes (sauvegardes fréquentes) |
| Mode dégradé | L'app doit fonctionner en mode lecture seule si le backend est indisponible (consultation solde, historique en cache) |

### 8.4 Scalabilité

- Architecture conçue pour supporter 100 000 utilisateurs sans refonte majeure
- Base de données et cache dimensionnés pour la croissance
- Possibilité de mise à l'échelle horizontale des serveurs applicatifs

### 8.5 Compatibilité

| Plateforme | Version minimale |
|---|---|
| Android | 6.0 (Marshmallow) — couvre > 95% du parc camerounais |
| iOS | 13.0 |
| Navigateurs web (dashboard) | Chrome 80+, Firefox 75+, Safari 13+, Edge 80+ |

### 8.6 Conformité réglementaire

| Régulation | Exigence |
|---|---|
| COBAC | Respect des normes sur les opérations de paiement électronique en zone CEMAC |
| CEMAC | Conformité aux règlements sur les services financiers numériques |
| Micro-crédit | Partenariat avec un EMF agréé ou opération sous le régime de crédit commercial plafonné |
| KYC/AML | Vérification d'identité obligatoire, détection des transactions suspectes |
| Protection des données | Conformité à la loi n°2010/012 sur la cybersécurité et la protection des données au Cameroun |

---

## 9. Architecture technique

### 9.1 Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENTS                                 │
├──────────────┬──────────────┬───────────────────────────────┤
│  App Mobile  │ App Pompiste │   Dashboard Web               │
│  (Flutter)   │  (Flutter)   │   (Vue.js / React)            │
│  Android/iOS │  Android     │   B2B + Admin                 │
└──────┬───────┴──────┬───────┴───────────┬───────────────────┘
       │              │                   │
       └──────────────┼───────────────────┘
                      │ HTTPS / REST API
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    API GATEWAY                               │
│              (Nginx / Load Balancer)                         │
├─────────────────────────────────────────────────────────────┤
│                 BACKEND — Laravel (PHP 8.2+)                │
│  ┌───────────┬───────────┬───────────┬───────────────────┐  │
│  │   Auth    │  Wallet   │  Fuel     │  Admin            │  │
│  │  Module   │  Module   │  Module   │  Module           │  │
│  ├───────────┼───────────┼───────────┼───────────────────┤  │
│  │  B2B      │  Credit   │  Station  │  Notification     │  │
│  │  Module   │  Module   │  Module   │  Module           │  │
│  └───────────┴───────────┴───────────┴───────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   SERVICES TRANSVERSAUX                      │
│  ┌────────────┬────────────┬────────────┬────────────────┐  │
│  │  Queue     │  Cache     │  Storage   │  Scheduler     │  │
│  │  (Redis)   │  (Redis)   │  (S3)      │  (Cron)        │  │
│  └────────────┴────────────┴────────────┴────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    BASE DE DONNÉES                           │
│                PostgreSQL 15+                                │
└─────────────────────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│ Orange Money │ │ MTN MoMo │ │  SMS Gateway │
│     API      │ │   API    │ │  (Twilio/    │
│              │ │          │ │   local)     │
└──────────────┘ └──────────┘ └──────────────┘
```

### 9.2 Stack technologique

| Couche | Technologie | Justification |
|---|---|---|
| **Mobile** | Flutter 3.x (Dart) | Cross-platform Android/iOS, performances natives, écosystème riche |
| **Backend** | Laravel 11 (PHP 8.2+) | Framework mature, écosystème Laravel robuste, large communauté de développeurs au Cameroun |
| **Base de données** | PostgreSQL 15+ | ACID compliant, fiable pour les transactions financières, extensions riches (JSON, géospatial) |
| **Cache / Queue** | Redis 7+ | Cache haute performance, file d'attente pour les jobs asynchrones (notifications, réconciliation) |
| **API** | REST (JSON) | Standard simple, bien supporté par Flutter et les partenaires Mobile Money |
| **Dashboard Web** | Blade (Laravel) ou Vue.js 3 | Intégration naturelle avec Laravel, rendu côté serveur ou SPA selon les besoins |
| **Serveur web** | Nginx | Reverse proxy performant, SSL termination |
| **CI/CD** | GitHub Actions | Automatisation des tests, du déploiement et des vérifications de qualité |
| **Hébergement** | VPS Cloud (OVH, AWS ou DigitalOcean) | Flexibilité, datacenter proche (Europe/Afrique), scaling progressif |
| **SMS** | Fournisseur local (ex: Infobip, Africa's Talking) + fallback Twilio | Couverture SMS optimale au Cameroun, coûts maîtrisés |
| **Stockage fichiers** | S3-compatible (AWS S3 ou MinIO) | Stockage des documents KYC, rapports générés, reçus |

### 9.3 Intégrations externes

| Service | Usage | Priorité |
|---|---|---|
| **Orange Money API** | Recharge portefeuille, paiement | MVP |
| **MTN MoMo API** | Recharge portefeuille, paiement | MVP |
| **SMS Gateway** | Envoi OTP, notifications, rappels micro-crédit | MVP |
| **Push Notifications** | FCM (Firebase Cloud Messaging) pour Android/iOS | MVP |
| **Google Maps / OpenStreetMap** | Géolocalisation des stations | Phase 2 |

### 9.4 Sécurité de l'architecture

- **Rate limiting** : Limitation des requêtes par IP et par utilisateur (Laravel Throttle)
- **Validation des entrées** : Validation stricte côté backend (Laravel Form Requests)
- **CORS** : Configuration stricte, seuls les domaines autorisés
- **Secrets** : Variables d'environnement, jamais en dur dans le code
- **Sauvegardes** : PostgreSQL — backup automatisé quotidien + WAL archiving pour le point-in-time recovery
- **Monitoring** : Laravel Telescope (dev), Sentry (erreurs production), alertes sur les métriques critiques

---

## 10. Parcours utilisateurs

### 10.1 Parcours : Première utilisation (Particulier)

```
1. Téléchargement de l'app sur Play Store / App Store
2. Écran d'accueil → "Créer un compte"
3. Saisie du numéro de téléphone (+237 6XX XXX XXX)
4. Réception et saisie de l'OTP (6 chiffres)
5. Création du code PIN (4 chiffres) + confirmation
6. Écran de bienvenue avec tutoriel rapide (3 slides)
7. Suggestion de compléter le profil (nom, prénom, CNI)
8. Dashboard principal : solde (0 FCFA), bouton "Recharger", bouton "Acheter carburant"
9. L'utilisateur clique sur "Recharger"
10. Choix du moyen de paiement : Orange Money ou MTN MoMo
11. Saisie du montant (ex: 10 000 FCFA)
12. Confirmation via prompt USSD Mobile Money
13. Solde mis à jour → 10 000 FCFA
14. Notification push : "Recharge de 10 000 FCFA effectuée avec succès"
```

### 10.2 Parcours : Achat de carburant en station

```
1. L'utilisateur ouvre l'app et se connecte (PIN ou biométrie)
2. Clique sur "Acheter du carburant"
3. Saisit le montant : 15 000 FCFA
4. Sélectionne le type : Super
5. Confirme → un QR Code s'affiche à l'écran (compte à rebours de 10 min)
6. Se rend à la pompe et présente le QR Code au pompiste
7. Le pompiste scanne le QR Code avec l'app Pompiste
8. L'écran pompiste affiche : "15 000 FCFA — Super — Jean"
9. Le pompiste confirme
10. Le client reçoit un SMS avec un OTP à 6 chiffres
11. Le client communique l'OTP au pompiste (ou le saisit dans l'app)
12. Le pompiste saisit l'OTP dans son app
13. Écran pompiste : "Transaction validée ✓ — Servir 15 000 FCFA de Super"
14. Le client reçoit une notification push : "Achat de 15 000 FCFA de Super confirmé"
15. Le pompiste sert le carburant
16. Un reçu numérique est disponible dans l'historique du client
```

### 10.3 Parcours : Gestion de flotte B2B

```
1. L'admin B2B se connecte au dashboard web
2. Menu "Flotte" → "Ajouter un véhicule"
3. Saisit : immatriculation, marque, modèle, type de carburant (Gasoil)
4. Menu "Conducteurs" → "Ajouter un conducteur"
5. Saisit : nom, prénom, numéro de téléphone, véhicule associé
6. Le conducteur reçoit un SMS d'invitation à télécharger l'app
7. Le conducteur s'inscrit avec son numéro → automatiquement rattaché au compte B2B
8. L'admin attribue un crédit mensuel de 100 000 FCFA au conducteur
9. Il définit un plafond journalier de 20 000 FCFA et restreint au Gasoil
10. Le conducteur voit dans son app : crédit disponible 100 000 FCFA, plafond 20 000 FCFA/jour
11. Le conducteur effectue un achat en station (cf. parcours 10.2)
12. L'admin voit la transaction en temps réel dans le dashboard
13. En fin de mois, l'admin génère un rapport : dépenses par conducteur, par véhicule
```

### 10.4 Parcours : Demande de micro-crédit

```
1. L'utilisateur consulte son solde : 500 FCFA (insuffisant pour un plein)
2. Clique sur "Avance carburant"
3. Le système calcule son score de crédit (ex: 72/100 — Palier 2)
4. Écran affiché : "Vous pouvez emprunter jusqu'à 15 000 FCFA"
5. L'utilisateur saisit 10 000 FCFA
6. Conditions affichées :
   - Montant emprunté : 10 000 FCFA
   - Frais (5%) : 500 FCFA
   - Total à rembourser : 10 500 FCFA
   - Date d'échéance : 19 mars 2026
7. L'utilisateur coche "J'accepte les conditions" et confirme
8. Son solde passe à 10 500 FCFA (500 + 10 000)
9. Il peut maintenant acheter du carburant normalement
10. À J-7 : notification "Rappel : 10 500 FCFA à rembourser avant le 19 mars"
11. À J-3 : notification de rappel
12. L'utilisateur recharge son portefeuille de 15 000 FCFA
13. Il clique sur "Rembourser l'avance" → 10 500 FCFA sont débités
14. Solde restant : 5 000 FCFA. Score de crédit augmente.
```

### 10.5 Parcours : Onboarding d'une station partenaire

```
1. Le Super Admin reçoit une demande de partenariat d'une station
2. Il crée la station dans le dashboard : nom, adresse, contact gérant, types de carburant
3. Un compte "Admin station" est créé pour le gérant
4. Le gérant reçoit ses identifiants par SMS
5. Le gérant se connecte au dashboard station
6. Il crée les comptes de ses pompistes (nom, téléphone)
7. Chaque pompiste reçoit un SMS avec un lien pour télécharger l'app pompiste
8. Les pompistes se connectent et sont rattachés à la station
9. La station est marquée "Active" dans le système
10. Les utilisateurs Fusy peuvent désormais effectuer des achats dans cette station
11. Le gérant consulte les transactions quotidiennes sur son dashboard
12. Les reversements sont effectués selon le contrat (J+1 ou hebdomadaire)
```

---

## 11. Modèle de données

### 11.1 Entités principales

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │       │   wallets    │       │ transactions │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ id           │──┐    │ id           │──┐    │ id           │
│ phone        │  │    │ user_id (FK) │  │    │ wallet_id(FK)│
│ pin_hash     │  │    │ balance      │  │    │ station_id   │
│ first_name   │  ├───▶│ currency     │  ├───▶│ attendant_id │
│ last_name    │  │    │ status       │  │    │ amount       │
│ cni_number   │  │    │ created_at   │  │    │ commission   │
│ role         │  │    └──────────────┘  │    │ fuel_type    │
│ kyc_status   │  │                      │    │ type         │
│ status       │  │    ┌──────────────┐  │    │ status       │
│ created_at   │  │    │   companies  │  │    │ qr_code      │
└──────────────┘  │    ├──────────────┤  │    │ otp_hash     │
                  │    │ id           │  │    │ validated_at │
                  │    │ admin_id(FK) │  │    │ created_at   │
                  ├───▶│ name         │  │    └──────────────┘
                  │    │ rccm         │  │
                  │    │ niu          │  │    ┌──────────────┐
                  │    │ status       │  │    │   credits    │
                  │    │ plan         │  │    ├──────────────┤
                  │    └──────────────┘  │    │ id           │
                  │                      │    │ user_id (FK) │
                  │    ┌──────────────┐  │    │ amount       │
                  │    │   stations   │  │    │ fee          │
                  │    ├──────────────┤  │    │ total_due    │
                  │    │ id           │  │    │ score        │
                  │    │ name         │  │    │ tier         │
                  │    │ address      │  │    │ status       │
                  │    │ latitude     │  │    │ due_date     │
                  │    │ longitude    │  │    │ repaid_at    │
                  │    │ manager_id   │  │    │ created_at   │
                  │    │ status       │  │    └──────────────┘
                  │    │ fuel_types   │
                  │    └──────────────┘
                  │
                  │    ┌──────────────┐       ┌──────────────┐
                  │    │   vehicles   │       │  fleet_      │
                  │    ├──────────────┤       │  allocations │
                  │    │ id           │       ├──────────────┤
                  │    │ company_id   │       │ id           │
                  ├───▶│ plate_number │       │ company_id   │
                       │ brand        │       │ driver_id    │
                       │ model        │       │ vehicle_id   │
                       │ fuel_type    │       │ monthly_limit│
                       │ status       │       │ daily_limit  │
                       └──────────────┘       │ fuel_type    │
                                              │ balance      │
                                              │ period_start │
                                              │ period_end   │
                                              │ status       │
                                              └──────────────┘
```

### 11.2 Description des entités

| Entité | Description | Relations clés |
|---|---|---|
| **users** | Tous les utilisateurs de la plateforme (particuliers, admins B2B, pompistes, admins station, super admins). Le champ `role` détermine le type. | 1 wallet, N transactions, 0..1 company |
| **wallets** | Portefeuille numérique en FCFA. Chaque utilisateur possède un wallet. Les entreprises ont un wallet dédié. | 1 user, N transactions |
| **transactions** | Toute opération financière : recharge, achat carburant, commission, reversement, remboursement crédit. | 1 wallet, 0..1 station, 0..1 attendant |
| **companies** | Entreprises clientes B2B avec leurs informations légales et leur plan d'abonnement. | 1 admin (user), N vehicles, N fleet_allocations |
| **stations** | Stations-service partenaires avec leur localisation et configuration. | 1 manager (user), N attendants (users), N transactions |
| **vehicles** | Véhicules de la flotte d'une entreprise. | 1 company, N fleet_allocations |
| **fleet_allocations** | Attribution de crédit carburant d'une entreprise à un conducteur pour un véhicule. Contient les plafonds et restrictions. | 1 company, 1 driver (user), 1 vehicle |
| **credits** | Avances micro-crédit avec scoring, montant, frais et suivi de remboursement. | 1 user |

### 11.3 Tables complémentaires

| Table | Rôle |
|---|---|
| **departments** | Départements au sein d'une entreprise B2B (pour organiser véhicules et conducteurs) |
| **notifications** | Historique des notifications envoyées (push, SMS) |
| **audit_logs** | Journal d'audit de toutes les opérations sensibles |
| **settings** | Paramètres système configurables (commissions, plafonds, durées OTP, etc.) |
| **kyc_documents** | Documents KYC uploadés (CNI, RCCM) avec statut de vérification |
| **settlement_batches** | Lots de reversement aux stations (réconciliation financière) |

---

## 12. Roadmap et phasage

### Phase MVP — Mois 1 à 4

**Objectif** : Lancer une version fonctionnelle complète couvrant le cycle d'achat carburant digital pour les particuliers et les entreprises.

| Mois | Livrables |
|---|---|
| **Mois 1** | Architecture technique, setup CI/CD, modèle de données, authentification (inscription, login, PIN, OTP), structure de l'app Flutter, intégration SMS Gateway |
| **Mois 2** | Module portefeuille, intégration Orange Money, intégration MTN MoMo, module achat carburant (génération QR Code), application pompiste (scan + validation), module OTP transactionnel |
| **Mois 3** | Dashboard B2B (gestion flotte, véhicules, conducteurs, plafonds, rapports), module micro-crédit simplifié (scoring, demande, remboursement), dashboard admin (supervision, gestion stations, KYC) |
| **Mois 4** | Tests d'intégration, tests utilisateurs (beta fermée avec 2-3 stations pilotes), corrections de bugs, optimisation des performances, préparation au lancement, documentation utilisateur |

**Jalons MVP** :
- M1 : Demo technique (auth + wallet en environnement de test)
- M2 : Demo fonctionnelle (cycle complet d'achat carburant en test)
- M3 : Beta fermée (test avec stations pilotes)
- M4 : Lancement public (Play Store + App Store)

### Phase 2 — Mois 5 à 8

| Livrable | Description |
|---|---|
| **Canal USSD** | Accès aux fonctions de base (consultation solde, achat carburant) pour téléphones basiques |
| **Micro-crédit avancé** | Scoring enrichi (données Mobile Money si partenariat), paliers progressifs automatiques, tableau de bord de suivi pour le Super Admin |
| **Géolocalisation** | Carte interactive des stations partenaires, itinéraire, prix du carburant (si disponible) |
| **Épargne carburant** | Fonctionnalité de "mise de côté" avec objectif et blocage temporaire d'un montant |
| **Rapports B2B avancés** | Export PDF/Excel, rapports personnalisés, analytics de consommation par période |
| **Programme de fidélité** | Points de fidélité sur les achats, paliers de récompenses |

### Phase 3 — Mois 9 à 12

| Livrable | Description |
|---|---|
| **Expansion CEMAC** | Adaptation pour le Gabon, le Congo et le Tchad (régulations locales, opérateurs locaux) |
| **Partenariats institutionnels** | Intégration avec les systèmes de paie de la fonction publique et des grandes entreprises pour le versement automatique des primes carburant |
| **Analytics avancés** | Dashboards prédictifs, tendances de consommation, alertes intelligentes |
| **API ouverte** | API REST documentée pour les intégrations tierces (ERP, comptabilité, etc.) |
| **Carte physique** | Carte NFC/QR liée au compte Fusy pour les utilisateurs sans smartphone |

---

## 13. Analyse des risques

### 13.1 Matrice des risques

| # | Risque | Probabilité | Impact | Niveau | Mitigation |
|---|---|---|---|---|---|
| R1 | Instabilité des APIs Mobile Money (Orange/MTN) | Élevée | Critique | **Critique** | Intégrer les deux opérateurs dès le MVP pour fallback mutuel. Implémenter un mécanisme de retry avec queue. Prévoir un mode dégradé (mise en attente des transactions). Tester régulièrement les APIs en production. |
| R2 | Faible adoption par les stations-service | Élevée | Critique | **Critique** | Lancer avec 2-3 stations pilotes motivées. Proposer une commission attractive et un onboarding clé en main. Minimiser le changement pour les pompistes (simple scan QR). Voir section 15 (stratégie d'acquisition). |
| R3 | Non-remboursement des micro-crédits | Moyenne | Élevé | **Élevé** | Scoring strict avec paliers progressifs. Plafonds bas au démarrage (5 000 FCFA). Blocage du compte en cas de retard > 7 jours. Provision financière pour les impayés. |
| R4 | Problèmes de conformité réglementaire (COBAC) | Moyenne | Critique | **Élevé** | Consulter un cabinet juridique spécialisé dès le mois 1. Opérer en partenariat avec un EMF agréé. Maintenir les plafonds micro-crédit sous les seuils réglementaires. |
| R5 | Connectivité réseau insuffisante en station | Moyenne | Élevé | **Élevé** | L'app pompiste fonctionne en 2G minimum. Implémenter un mode offline partiel (cache local, synchronisation différée). Tester sur les réseaux camerounais (MTN, Orange, Nexttel). |
| R6 | Fraude (QR codes falsifiés, comptes multiples) | Faible | Élevé | **Moyen** | QR Codes chiffrés et signés (non reproductibles). Double validation QR + OTP. KYC obligatoire pour les montants élevés. Détection des anomalies (transactions inhabituelles). |
| R7 | Concurrence d'un acteur majeur (opérateur télécom ou banque) | Faible | Élevé | **Moyen** | Avantage du premier arrivant. Se concentrer sur l'UX et la valeur ajoutée B2B. Construire un réseau de stations partenaires difficilement duplicable. |
| R8 | Indisponibilité du service SMS (envoi OTP) | Moyenne | Élevé | **Élevé** | Multi-fournisseur SMS (principal + fallback). Alternative : OTP in-app (push notification). Monitoring en temps réel du taux de délivrance SMS. |
| R9 | Turnover des pompistes / résistance au changement | Moyenne | Moyen | **Moyen** | App pompiste ultra-simple (une seule action : scanner). Formation sur site lors de l'onboarding. Support hotline dédié aux pompistes. |
| R10 | Dépassement du budget ou du délai | Moyenne | Moyen | **Moyen** | Phasage strict avec MVP minimal. Sprints de 2 semaines avec review. Priorisation rigoureuse (P1 d'abord, P2 ensuite). Buffer de 4 semaines intégré au planning. |

### 13.2 Plan de contingence

- **Si les APIs Mobile Money sont instables** : basculer temporairement vers un système de recharge manuelle (virement bancaire avec confirmation admin) le temps de résoudre
- **Si l'adoption stations est lente** : concentrer les efforts sur 5-10 stations à Douala et Yaoundé, offrir les premiers mois sans commission
- **Si le micro-crédit génère trop d'impayés** : réduire les plafonds, durcir les critères de scoring, suspendre temporairement la fonctionnalité si nécessaire

---

## 14. Critères de recette

### 14.1 Conditions de validation du MVP

Le MVP sera considéré comme prêt au lancement lorsque **tous** les critères suivants seront remplis :

#### Fonctionnels

| # | Critère | Méthode de validation |
|---|---|---|
| CR-01 | Un utilisateur peut s'inscrire, se connecter et compléter son profil | Test end-to-end sur Android et iOS |
| CR-02 | Un utilisateur peut recharger son portefeuille via Orange Money | Transaction réelle en environnement de pré-production |
| CR-03 | Un utilisateur peut recharger son portefeuille via MTN MoMo | Transaction réelle en environnement de pré-production |
| CR-04 | Un utilisateur peut générer un QR Code d'achat carburant | Test fonctionnel sur l'app mobile |
| CR-05 | Un pompiste peut scanner un QR Code et déclencher l'envoi d'OTP | Test end-to-end avec app pompiste |
| CR-06 | La validation OTP finalise la transaction et met à jour les soldes | Test end-to-end avec vérification des montants |
| CR-07 | Un admin B2B peut créer une flotte, ajouter véhicules et conducteurs | Test fonctionnel sur le dashboard web |
| CR-08 | Un admin B2B peut attribuer des crédits avec plafonds et restrictions | Test fonctionnel + vérification des contraintes |
| CR-09 | Un conducteur B2B ne peut pas dépasser son plafond journalier | Test de validation des règles métier |
| CR-10 | Un utilisateur éligible peut demander et rembourser un micro-crédit | Test du cycle complet de crédit |
| CR-11 | Le Super Admin peut superviser la plateforme via le dashboard admin | Test fonctionnel du dashboard |
| CR-12 | Les notifications push et SMS sont envoyées correctement | Test de réception sur appareil réel |

#### Non fonctionnels

| # | Critère | Cible | Méthode de validation |
|---|---|---|---|
| CR-13 | Temps de réponse API (P95) | < 500ms | Test de charge (50 utilisateurs simultanés) |
| CR-14 | Temps de génération QR Code | < 2 secondes | Mesure sur appareil réel (Android entrée de gamme) |
| CR-15 | Taux de succès des transactions (hors erreurs opérateur) | > 95% | Monitoring sur les transactions de test |
| CR-16 | Disponibilité de la plateforme | > 99% sur 7 jours de test | Monitoring uptime |
| CR-17 | Sécurité — aucune vulnérabilité critique (OWASP) | 0 critique, 0 haute | Audit de sécurité (scan automatisé + revue manuelle) |
| CR-18 | Compatibilité Android 6.0+ | Fonctionne sans crash | Test sur 3 appareils Android (entrée de gamme, milieu de gamme, haut de gamme) |
| CR-19 | Compatibilité iOS 13+ | Fonctionne sans crash | Test sur iPhone SE (2ème gén) et iPhone récent |

#### Opérationnels

| # | Critère | Méthode de validation |
|---|---|---|
| CR-20 | Au moins 2 stations-service pilotes sont actives et fonctionnelles | Visite terrain + transactions de test réelles |
| CR-21 | Les pompistes des stations pilotes sont formés et opérationnels | Formation dispensée + test pratique |
| CR-22 | Le processus de réconciliation financière fonctionne | Vérification du reversement correct aux stations pilotes |
| CR-23 | Le support technique est opérationnel (email + téléphone) | Procédure documentée et testée |
| CR-24 | La documentation utilisateur est disponible (guide in-app + FAQ) | Revue du contenu |

---

## 15. Stratégie d'acquisition des stations partenaires

Aucun partenariat concret n'étant établi à ce stade, une stratégie d'acquisition structurée est indispensable.

### 15.1 Phase pilote (Mois 3-4)

**Objectif** : 2-3 stations partenaires à Douala et/ou Yaoundé

| Action | Détail |
|---|---|
| Ciblage | Stations indépendantes (pas de réseau majeur), gérants accessibles et ouverts à l'innovation |
| Proposition de valeur | Zéro coût d'installation, zéro commission pendant 3 mois, formation gratuite des pompistes |
| Équipement | Fusy fournit 1-2 smartphones Android d'entrée de gamme par station pour les pompistes |
| Engagement | Contrat pilote de 3 mois, résiliable à tout moment |
| Support | Accompagnement terrain dédié pendant les 2 premières semaines |

### 15.2 Phase de croissance (Mois 5-8)

**Objectif** : 50 stations partenaires

| Action | Détail |
|---|---|
| Témoignages | Utiliser les résultats des stations pilotes comme preuve sociale |
| Commission réduite | 1% pendant les 6 premiers mois (vs. 1.5-2% standard) |
| Approche réseaux | Démarcher les réseaux de stations (Total Energies, Tradex, Neptune Oil) avec un partenariat cadre |
| Valeur ajoutée | Dashboard station gratuit avec analytics, outil de gestion des réconciliations |

### 15.3 Phase d'expansion (Mois 9-12)

**Objectif** : 120 stations partenaires

| Action | Détail |
|---|---|
| Programme de parrainage | Les stations existantes reçoivent un bonus pour chaque nouvelle station qu'elles recommandent |
| Partenariats institutionnels | Accords avec les grandes entreprises qui conditionnent leurs primes carburant à l'usage de Fusy — les stations devront rejoindre le réseau pour ne pas perdre de clients |
| Couverture géographique | Extension progressive vers les villes secondaires (Bafoussam, Bamenda, Garoua, Maroua) |

---

## 16. Annexes

### 16.1 Glossaire

| Terme | Définition |
|---|---|
| **CEMAC** | Communauté Économique et Monétaire de l'Afrique Centrale (6 pays : Cameroun, Gabon, Congo, Tchad, RCA, Guinée Équatoriale) |
| **COBAC** | Commission Bancaire de l'Afrique Centrale — régulateur bancaire de la zone CEMAC |
| **EMF** | Établissement de Micro-Finance — institution agréée par la COBAC pour les opérations de micro-crédit |
| **FCFA (XAF)** | Franc CFA d'Afrique Centrale — monnaie officielle des pays de la CEMAC |
| **KYC** | Know Your Customer — processus de vérification d'identité des utilisateurs |
| **AML** | Anti-Money Laundering — lutte contre le blanchiment d'argent |
| **RCCM** | Registre du Commerce et du Crédit Mobilier — document d'immatriculation des entreprises |
| **NIU** | Numéro d'Identifiant Unique — identifiant fiscal des entreprises au Cameroun |
| **CNI** | Carte Nationale d'Identité |
| **OTP** | One-Time Password — code à usage unique envoyé par SMS |
| **QR Code** | Quick Response Code — code-barres 2D scannable par smartphone |
| **MAU** | Monthly Active Users — utilisateurs actifs mensuels |
| **NPS** | Net Promoter Score — indicateur de satisfaction et de recommandation |
| **MVP** | Minimum Viable Product — version minimale fonctionnelle du produit |
| **B2B** | Business to Business — services destinés aux entreprises |
| **B2C** | Business to Consumer — services destinés aux particuliers |
| **USSD** | Unstructured Supplementary Service Data — protocole de communication pour téléphones basiques |
| **CAC** | Coût d'Acquisition Client |
| **LTV** | Lifetime Value — valeur vie client |

### 16.2 Références

- Régulation COBAC sur les établissements de micro-finance en zone CEMAC
- Loi n°2010/012 du 21 décembre 2010 relative à la cybersécurité et à la cybercriminalité au Cameroun
- Règlement CEMAC n°04/18 relatif aux services de paiement en zone CEMAC
- Documentation API Orange Money Cameroun
- Documentation API MTN Mobile Money Cameroun
- OWASP Top 10 (2021) — Guide de sécurité des applications web

### 16.3 Historique du document

| Version | Date | Auteur | Modifications |
|---|---|---|---|
| 0.1 | 07/02/2026 | Client | Brouillon initial — vision et analyse |
| 1.0 | 17/02/2026 | Équipe Projet | Rédaction complète du CDC Final |

---

*Document généré le 17 février 2026 — Fusy v1.0*
*Ce document est confidentiel et destiné uniquement aux parties prenantes du projet.*

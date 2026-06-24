# Fusy — Design MVP B2B V3

Date : 2026-06-23  
Statut : design validé en session, en attente de relecture documentaire  
Durée cible : 4 mois, 8 sprints de 2 semaines  
Marché initial : Cameroun

## 1. Vision

Fusy est une plateforme B2B de gestion et paiement carburant pour entreprises et stations partenaires.

Une entreprise alimente un compte carburant, crée ses chauffeurs et leur attribue des budgets. Une station crée ses pompes et ses pompistes. À la pompe, le chauffeur scanne un QR, vérifie les informations, saisit le montant et confirme avec son PIN. Le paiement est débité immédiatement. Le pompiste vérifie ensuite la transaction dans son historique avant de servir.

Le MVP doit aussi démontrer aux entreprises et aux opérateurs télécoms le futur parcours de recharge Orange Money/MTN MoMo et le secours USSD, sans effectuer d'intégration opérateur réelle avant partenariat direct.

## 2. Principes MVP

- Une seule application mobile Flutter Android/iOS.
- Une seule application web Laravel + Inertia React.
- Interfaces et permissions déterminées par le rôle et le type d'organisation.
- Aucune inscription publique entreprise ou station.
- Entreprises payantes après pilote ; stations gratuites au MVP.
- Aucune commission transactionnelle au MVP.
- Financement réel manuel hors plateforme.
- Orange Money, MTN MoMo et USSD simulés pour démonstration.
- Intégrations réelles conditionnées par des accords directs avec MTN et Orange.

## 3. Organisations

### 3.1 Types

Une entité commune `organization` représente :

- une entreprise partenaire ;
- une station partenaire.

Chaque organisation possède :

- un identifiant interne ;
- un code organisation unique globalement ;
- un type `enterprise` ou `station` ;
- un statut ;
- ses coordonnées ;
- ses paramètres métier.

Deux organisations ne peuvent jamais partager le même code.

### 3.2 Code organisation

Le code est généré automatiquement par Fusy.

Format recommandé :

- 6 caractères alphanumériques en majuscules ;
- caractères ambigus exclus, notamment `O/0` et `I/1` ;
- index unique en base de données ;
- non modifiable par l'organisation au MVP.

### 3.3 Onboarding

Fusy :

1. valide commercialement l'organisation ;
2. crée l'entreprise ou la station ;
3. génère son code organisation ;
4. crée son premier administrateur.

Après onboarding :

- l'admin entreprise gère ses chauffeurs ;
- l'admin station gère ses pompistes et ses pompes.

## 4. Comptes Et Authentification

### 4.1 Administrateurs web

Connexion avec :

- code organisation ;
- email ou téléphone ;
- mot de passe fort.

Le PIN à 4 chiffres n'est pas utilisé pour l'administration web.

### 4.2 Chauffeurs et pompistes

Création :

- l'admin organisation crée le compte ;
- il renseigne téléphone ou matricule ;
- il définit un PIN temporaire à 4 chiffres ;
- l'utilisateur doit remplacer ce PIN au premier accès.

Première connexion :

1. code organisation ;
2. téléphone ou matricule ;
3. PIN temporaire ;
4. définition du PIN personnel ;
5. confirmation SMS ;
6. enregistrement de l'appareil.

Connexions suivantes sur l'appareil enregistré :

- PIN personnel uniquement.

### 4.3 Réinitialisation PIN

- L'admin ne voit jamais le PIN personnel.
- Il peut générer un nouveau PIN temporaire.
- L'utilisateur doit le remplacer au prochain accès.
- Créations et réinitialisations sont auditées.

### 4.4 Tentatives et appareil

- 5 tentatives PIN incorrectes maximum.
- Blocage temporaire de 15 minutes.
- Récidive : réinitialisation requise par l'admin organisation.
- Un seul appareil actif par compte au MVP.
- Un changement d'appareil exige code organisation, identifiant, PIN et confirmation SMS.
- L'ancienne session est révoquée.

### 4.5 Multi-organisation

L'unicité d'un compte mobile est définie par `organisation + téléphone/matricule`.

Le même téléphone peut avoir plusieurs comptes dans des organisations différentes. Chaque compte conserve :

- son rôle ;
- son PIN ;
- son appareil actif ;
- ses données isolées.

Pas de cumul chauffeur + pompiste dans le même compte au MVP.

## 5. Application Mobile Unifiée

Une seule application Flutter est publiée sur Android et iOS.

Le rôle du compte détermine automatiquement l'interface. L'utilisateur ne choisit pas son rôle manuellement.

### 5.1 Interface chauffeur

Fonctions :

- consultation du budget personnel ;
- scan QR pompiste ou pompe ;
- choix du carburant ;
- saisie du montant FCFA ;
- confirmation par PIN ;
- historique ;
- reçus.

Le chauffeur ne voit jamais :

- le solde global entreprise ;
- les budgets des autres chauffeurs ;
- les données financières internes de l'entreprise.

### 5.2 Protection du budget affiché

Sur l'accueil chauffeur :

- le budget est flouté par défaut ;
- un clic demande le PIN personnel ;
- après validation, le budget est visible 15 secondes ;
- il est reflouté après ce délai ;
- il est aussi reflouté si l'utilisateur quitte l'écran ou met l'app en arrière-plan.

Le chauffeur voit également :

- la date du prochain reset, si applicable ;
- un statut générique du compte entreprise : opérationnel ou recharge nécessaire.

### 5.3 Interface pompiste

Fonctions :

- ouverture/fermeture de session de travail ;
- sélection de la pompe ;
- affichage du QR dynamique ;
- réception des alertes de paiement ;
- historique du jour ;
- recherche d'une transaction par code court.

Le pompiste ne valide pas et ne refuse pas le paiement.

## 6. Dashboard Web Multi-Organisation

Une seule application Laravel + Inertia React fournit trois expériences.

### 6.1 Interface entreprise

- compte carburant réel ;
- chauffeurs ;
- création et suspension des comptes ;
- PIN temporaire et reset ;
- budgets manuel, hebdomadaire et mensuel ;
- sur-allocation ;
- stations autorisées ;
- dépenses et reçus ;
- exports CSV/PDF ;
- financement manuel réel ;
- démonstration Orange Money/MTN MoMo.

### 6.2 Interface station

- pompistes ;
- création et suspension des comptes ;
- PIN temporaire et reset ;
- pompes ;
- carburants disponibles par pompe ;
- QR fixes de secours ;
- paiements reçus ;
- historique par pompiste, pompe et entreprise ;
- ventes Fusy du jour ;
- montant en attente de reversement ;
- lots hebdomadaires ;
- demandes de remboursement total.

### 6.3 Interface admin Fusy

- organisations ;
- codes organisation ;
- premiers administrateurs ;
- financements manuels ;
- stations autorisées par entreprise ;
- supervision des transactions ;
- remboursements ;
- reversements station ;
- audit ;
- suspensions ;
- séparation des environnements démo et pilote.

## 7. Pompes Et Carburants

L'admin station crée ses pompes.

Pour chaque pompe, il configure les carburants disponibles.

Au début de son service, le pompiste sélectionne une pompe dans l'app. Cette affectation :

- est attachée à sa session ;
- apparaît dans son QR dynamique ;
- peut être modifiée ;
- est auditée.

Plusieurs pompistes peuvent être affectés à la même pompe si la station le permet.

## 8. QR De Paiement

### 8.1 QR dynamique pompiste

Parcours principal.

Le QR :

- est affiché dans l'app pompiste ;
- identifie station, pompiste, pompe et session ;
- contient un jeton signé ;
- est renouvelé toutes les 60 secondes.

### 8.2 QR fixe pompe

Parcours de secours.

Le QR :

- est imprimé par la station ;
- identifie station et pompe ;
- ne contient aucun montant ;
- peut être désactivé ou remplacé.

## 9. Parcours De Paiement

1. Le chauffeur scanne le QR dynamique pompiste ou le QR fixe pompe.
2. Fusy vérifie l'organisation, le chauffeur, la station, la pompe et le QR.
3. Fusy vérifie le budget chauffeur et le solde réel entreprise.
4. L'app affiche station, pompe et pompiste éventuel.
5. Le chauffeur choisit un carburant disponible sur la pompe.
6. Il saisit le montant en FCFA.
7. Il vérifie le récapitulatif.
8. Il confirme avec son PIN.
9. Fusy débite atomiquement le compte entreprise et le budget chauffeur.
10. La transaction passe immédiatement à `paid`.
11. Un reçu est généré.
12. Le pompiste reçoit l'alerte et vérifie le paiement avant de servir.

Le paiement est uniquement exprimé en FCFA. Le calcul de litres est hors MVP.

## 10. Alertes Et Preuve Pompiste

Après paiement :

- alerte sonore et vibration ;
- montant ;
- carburant ;
- pompe ;
- référence chauffeur ;
- entreprise ;
- code transaction ;
- statut `Payé`.

Le pompiste peut rechercher la transaction par code court.

Si l'app n'accuse pas réception de l'alerte, Fusy envoie un SMS de secours contenant les informations minimales nécessaires.

La source de vérité reste l'historique serveur, jamais une capture d'écran présentée par le chauffeur.

## 11. Délais

- QR dynamique : 60 secondes.
- Session de paiement après scan : 5 minutes.
- Aucun débit si la session expire avant confirmation PIN.
- Après confirmation, la transaction est définitive sauf remboursement approuvé.

## 12. Budgets Et Solde Entreprise

Modes budget chauffeur :

- manuel ;
- hebdomadaire ;
- mensuel.

Un reset périodique remplace le solde budget restant. Il ne l'ajoute pas.

La sur-allocation reste autorisée : la somme des budgets chauffeurs peut dépasser le solde entreprise. Le paiement est néanmoins bloqué si le solde réel entreprise ne couvre pas le montant.

## 13. Données Visibles Par La Station

La station voit :

- entreprise payeuse ;
- prénom ou identifiant chauffeur ;
- pompiste ;
- pompe ;
- carburant ;
- montant ;
- date/heure ;
- code transaction ;
- statut ;
- reversement.

La station ne voit jamais :

- téléphone complet du chauffeur ;
- PIN ;
- budget chauffeur restant ;
- solde entreprise ;
- autres dépenses de l'entreprise.

## 14. Remboursements

- Le pompiste ne peut pas annuler un paiement.
- L'admin station crée une demande de remboursement total.
- L'admin Fusy approuve ou refuse.
- Si approuvée, le compte entreprise et le budget chauffeur sont recrédités.
- La somme est retirée du prochain reversement station.
- L'historique initial est conservé.
- Le remboursement partiel est hors MVP.

## 15. Recharges Et Partenariats Opérateurs

### 15.1 Financement réel du pilote

Pour les organisations pilotes réelles :

- dépôt, virement ou transfert hors plateforme ;
- vérification manuelle par Fusy ;
- crédit manuel du compte carburant.

### 15.2 Démonstration Orange Money/MTN MoMo

Pour les organisations démo :

- choix Orange Money ou MTN MoMo ;
- simulation des états `pending`, `successful`, `failed` ;
- crédit d'un solde fictif ;
- aucune incidence sur les comptes ou reversements réels.

Les données démo sont isolées des données pilotes.

Objectif : négocier ensuite une intégration directe avec MTN et Orange, sans intermédiaire.

### 15.3 USSD simulé

Parcours démontré :

1. numéro chauffeur identifié ;
2. saisie code pompe/pompiste ;
3. saisie montant ;
4. choix carburant ;
5. confirmation PIN ;
6. confirmation SMS chauffeur et pompiste.

La vraie intégration USSD dépend d'un accord opérateur.

## 16. Reversements Station

Le dashboard station distingue :

- ventes Fusy du jour ;
- montant en attente de reversement ;
- montant déjà reversé ;
- prochain lot hebdomadaire ;
- remboursements.

Le reversement réel est effectué hors plateforme. L'admin Fusy marque ensuite le lot hebdomadaire comme payé.

## 17. Modèle Économique MVP

- entreprises : abonnement payant après pilote ;
- stations : accès gratuit ;
- aucune commission transactionnelle ;
- services premium station éventuels hors MVP.

## 18. Gestion Des Erreurs

Aucun débit si :

- organisation, utilisateur, station ou pompe inactive ;
- QR invalide, révoqué ou expiré ;
- carburant indisponible ;
- budget chauffeur insuffisant ;
- solde entreprise insuffisant ;
- session expirée ;
- PIN incorrect.

Garanties :

- clé d'idempotence par tentative ;
- double clic sans double débit ;
- débit compte entreprise + budget chauffeur atomique ;
- rollback intégral en cas d'échec ;
- audit des opérations sensibles.

Si le serveur est injoignable, l'app ne présente jamais un paiement comme réussi.

## 19. Découpage Des Sprints

| Sprint | Objectif | Jalon |
|---|---|---|
| 1 | Fondations Laravel/Inertia/Flutter, organisations, rôles, ledger | Socle multi-organisation |
| 2 | Auth, codes organisation, appareils, audit, admin Fusy | Onboarding contrôlé |
| 3 | Dashboard entreprise | Entreprise autonome |
| 4 | Dashboard station | Station autonome |
| 5 | App mobile unifiée et interfaces par rôle | App Android/iOS fonctionnelle |
| 6 | QR, paiement immédiat, alertes et reçus | Flux carburant complet |
| 7 | Remboursements, reversements, exports, simulations Orange/MTN/USSD | Exploitation et démonstration |
| 8 | QA, staging/production, formation et pilote | Go/No-Go MVP |

## 20. Stratégie De Tests

Tests prioritaires :

- isolation des organisations ;
- unicité code organisation ;
- permissions entreprise/station/Fusy ;
- création/reset PIN ;
- changement obligatoire au premier accès ;
- tentatives incorrectes et blocage ;
- appareil unique et changement confirmé par SMS ;
- budget masqué/révélé ;
- pompes et carburants ;
- QR dynamique expiré ;
- QR fixe révoqué ;
- session paiement expirée ;
- débit atomique ;
- idempotence ;
- alerte pompiste et SMS de secours ;
- remboursement total ;
- lots hebdomadaires ;
- séparation démo/pilote ;
- exports CSV/PDF.

## 21. Critères De Succès MVP

- 3 entreprises pilotes minimum, cible idéale 5.
- 3 stations pilotes minimum, cible idéale 5.
- 5 à 15 chauffeurs par entreprise, jusqu'à 30 si pilote maîtrisé.
- Paiements réels exécutés avec financement manuel.
- Pompistes capables de vérifier les paiements avant service.
- Démonstrations Orange Money, MTN MoMo et USSD présentables aux opérateurs.
- Au moins une entreprise accepte de payer après le pilote.

## 22. Hors MVP

- intégration réelle Orange Money/MTN MoMo ;
- intégration réelle USSD ;
- intermédiaire de paiement ;
- inscription publique ;
- B2C public ;
- micro-crédit ;
- paiement en litres ;
- remboursement partiel ;
- commission transactionnelle ;
- abonnement station ;
- multi-app mobile ;
- fonctionnement offline avec validation locale.

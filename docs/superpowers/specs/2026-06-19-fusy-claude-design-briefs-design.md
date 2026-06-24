# Fusy — Dossiers de conception pour Claude Design

Date : 2026-06-19  
Statut : structure validée, contenu à produire  
Périmètre : MVP B2B fermé uniquement

## 1. Objectif

Créer quatre dossiers de conception autonomes qui permettent à Claude Design de concevoir chaque interface Fusy avec un contexte métier, fonctionnel et visuel suffisant.

Les dossiers ne remplacent pas le cahier des charges. Ils traduisent le périmètre MVP en instructions de design : utilisateurs, parcours, écrans, états, données, contraintes et critères de qualité.

## 2. Structure cible

```text
design-briefs/
├── README.md
├── 00-shared/
│   ├── product-foundation.md
│   ├── brand-and-ui-system.md
│   ├── accessibility-and-content.md
│   └── assets-index.md
├── 01-driver-app/
├── 02-attendant-app/
├── 03-company-dashboard/
└── 04-fusy-admin-dashboard/
```

Les quatre dossiers d'interface utilisent le même contrat documentaire :

```text
{application}/
├── README.md
├── 01-product-and-user-context.md
├── 02-scope-and-information-architecture.md
├── 03-user-flows.md
├── 04-screen-specifications.md
├── 05-components-states-and-errors.md
├── 06-content-and-sample-data.md
├── 07-responsive-accessibility-and-quality.md
└── CLAUDE-DESIGN-PROMPT.md
```

## 3. Socle partagé

### `product-foundation.md`

Ce document explique :

- le problème des bons papier et avances cash ;
- le positionnement B2B fermé du MVP ;
- les acteurs et responsabilités ;
- la différence entre solde entreprise et budget chauffeur ;
- le fonctionnement QR station, validation pompiste et confirmation PIN ;
- les états d'une transaction ;
- la règle d'expiration de cinq minutes ;
- les exclusions du MVP.

### `brand-and-ui-system.md`

Ce document reprend la charte approuvée :

- direction Clarté opérationnelle ;
- Manrope comme police unique ;
- couleurs et tokens ;
- espacement, rayons et élévation ;
- boutons, champs, cartes, badges et navigation ;
- règles d'iconographie ;
- usages du logo et limites des sources PNG.

### `accessibility-and-content.md`

Ce document impose :

- interface en français ;
- vocabulaire direct et non bancaire ;
- format `15 000 FCFA` ;
- dates et heures adaptées au Cameroun ;
- contraste WCAG AA ;
- cible tactile de 48 px ;
- statut jamais transmis uniquement par la couleur ;
- états réseau, permission, chargement, vide et erreur ;
- données d'exemple plausibles sans données personnelles réelles.

### `assets-index.md`

Ce document inventorie :

- les variantes de logo existantes ;
- les icônes et fontes autorisées ;
- les fichiers de tokens ;
- les assets disponibles et leurs limites ;
- les chemins à fournir avec chaque prompt Claude Design.

## 4. Contrat commun d'un dossier d'application

### `README.md`

Résumé en une page : cible, plateforme, objectif principal, documents à lire et ordre recommandé d'utilisation avec Claude Design.

### `01-product-and-user-context.md`

Décrit l'utilisateur principal, son environnement, ses tâches, ses contraintes, son niveau de maîtrise numérique et les décisions qu'il doit prendre.

### `02-scope-and-information-architecture.md`

Liste les fonctions MVP, les exclusions, la navigation, la hiérarchie des contenus et la relation entre les écrans.

### `03-user-flows.md`

Décrit chaque parcours sous forme d'étapes, avec préconditions, chemin nominal, branches d'erreur, résultat attendu et retour possible.

### `04-screen-specifications.md`

Chaque écran contient :

- objectif ;
- point d'entrée ;
- informations affichées ;
- actions ;
- hiérarchie visuelle ;
- états et variantes ;
- règles métier visibles ;
- destination après action ;
- critères d'acceptation UX.

### `05-components-states-and-errors.md`

Inventorie les composants spécifiques, leurs états et les messages associés. Il couvre notamment chargement, vide, hors ligne, permission refusée, expiration, session expirée et action interdite.

### `06-content-and-sample-data.md`

Fournit des libellés français prêts à utiliser et un jeu de données cohérent partagé entre les écrans : entreprises, chauffeurs, stations, pompistes, montants, transactions et identifiants.

### `07-responsive-accessibility-and-quality.md`

Fixe les tailles cibles, points de rupture, règles tactiles, ordre de lecture, contrastes, focus, clavier, tableaux, petits écrans et checklist de contrôle visuel.

### `CLAUDE-DESIGN-PROMPT.md`

Prompt autonome qui :

- identifie le produit et l'interface ;
- impose le périmètre MVP ;
- référence le socle partagé et le logo ;
- résume la charte et les règles non négociables ;
- liste les écrans et parcours à concevoir ;
- demande tous les états utiles ;
- fournit les données d'exemple ;
- interdit l'ajout de fonctions hors périmètre ;
- définit le format de sortie attendu de Claude Design.

## 5. Dossier App Chauffeur

Plateforme : Flutter Android et iOS, mobile-first.  
Utilisateur : chauffeur ou agent terrain créé par son entreprise.

Écrans à documenter :

1. saisie du téléphone ;
2. code d'activation ;
3. création du PIN ;
4. connexion téléphone et PIN ;
5. accueil avec budget, entreprise, état du compte et dernier reçu ;
6. permission caméra ;
7. scan du QR station ;
8. station reconnue ou station non autorisée ;
9. saisie montant, carburant et champ libre véhicule/mission ;
10. vérification et création de la demande ;
11. attente de validation pompiste avec expiration ;
12. demande refusée ou expirée ;
13. confirmation finale par PIN ;
14. succès et reçu ;
15. historique ;
16. détail d'une transaction.

Les blocages budget insuffisant, solde entreprise insuffisant, compte suspendu, station inactive, QR invalide et absence de réseau sont spécifiés explicitement.

## 6. Dossier App Pompiste

Plateforme : Flutter Android en priorité.  
Utilisateur : pompiste rattaché à une seule station.

Écrans à documenter :

1. connexion téléphone et PIN ;
2. accueil avec station et état réseau ;
3. demandes en attente ;
4. recherche par code court ;
5. détail d'une demande ;
6. confirmation de validation ;
7. motif ou confirmation de refus ;
8. demande validée, refusée ou expirée ;
9. attente de la confirmation chauffeur ;
10. historique du jour ;
11. détail d'une transaction.

Le montant et le type de carburant sont en lecture seule. La limite de cinq minutes, l'isolation par station et le statut incomplet avant confirmation du chauffeur sont toujours visibles.

## 7. Dossier Dashboard Entreprise

Plateforme : web desktop responsive.  
Utilisateur : responsable financier, flotte ou opérations.

Écrans à documenter :

1. connexion ;
2. tableau de bord avec solde réel, budgets, consommation et alertes ;
3. liste des chauffeurs ;
4. création d'un chauffeur ;
5. détail et modification d'un chauffeur ;
6. configuration du budget manuel, hebdomadaire ou mensuel ;
7. suspension, réactivation et relance d'activation ;
8. stations autorisées en lecture seule ;
9. liste filtrable des transactions ;
10. détail et reçu d'une transaction ;
11. export CSV ou PDF ;
12. reporting simple par période, chauffeur, station, statut et carburant.

L'interface explique que le budget chauffeur est une autorisation, que le solde entreprise est l'argent réel et que la sur-allocation est permise.

## 8. Dossier Dashboard Admin Fusy

Plateforme : web desktop responsive, usage interne.  
Utilisateur : opérateur ou administrateur Fusy.

Écrans à documenter :

1. connexion ;
2. vue d'ensemble du pilote ;
3. liste, création et détail des entreprises ;
4. création de l'admin entreprise ;
5. crédit manuel du compte carburant ;
6. suspension et réactivation d'une entreprise ;
7. liste, création et détail des stations ;
8. génération, téléchargement, remplacement et désactivation du QR ;
9. liste, création et gestion des pompistes ;
10. association des stations autorisées à une entreprise ;
11. liste globale et détail des transactions ;
12. audit minimal ;
13. reporting global ;
14. lots hebdomadaires de reversement ;
15. revue et marquage d'un lot comme payé.

Les actions sensibles affichent leur impact, demandent confirmation et créent une trace d'audit visible.

## 9. Jeu de données commun

Les quatre dossiers partagent des exemples cohérents, notamment :

- entreprise : `TransLog Cameroun SARL` ;
- chauffeur : `Jean Mballa`, téléphone masqué, budget hebdomadaire `50 000 FCFA` ;
- station : `Tradex Bonamoussadi` ;
- pompiste : `Armand Etoa` ;
- transaction réussie : `15 000 FCFA`, Super, code court `6821` ;
- identifiant : `TX-8F21K9` ;
- compte entreprise : `1 850 000 FCFA` ;
- états de transaction : en attente, validée par le pompiste, terminée, refusée, expirée, annulée et bloquée.

Les noms et numéros servent uniquement de données fictives de conception.

## 10. Format attendu de Claude Design

Chaque prompt demande :

1. une architecture d'écrans cohérente ;
2. les écrans principaux en haute fidélité ;
3. les états critiques et d'erreur ;
4. la navigation entre écrans ;
5. la réutilisation stricte des tokens Fusy ;
6. une justification courte des décisions importantes ;
7. aucune fonctionnalité absente du MVP.

Claude Design ne doit pas inventer de wallet grand public, Mobile Money automatisé, microcrédit, carte complexe des stations, géolocalisation, KYC self-service, règles horaires, départements, approbation multi-niveau ou analytics avancés.

## 11. Vérification

La livraison est conforme lorsque :

- les quatre dossiers suivent le même contrat ;
- chaque fonction du MVP apparaît dans un écran ou un parcours ;
- chaque écran possède au moins un état nominal et ses états critiques ;
- les rôles et permissions ne se mélangent pas ;
- le vocabulaire, les données et les statuts concordent entre dossiers ;
- les prompts sont utilisables seuls avec leur dossier et le socle partagé ;
- les prompts interdisent explicitement le hors-périmètre ;
- les liens relatifs entre documents sont valides ;
- aucun fichier existant n'est modifié hors `design-briefs/` et de la présente spécification.

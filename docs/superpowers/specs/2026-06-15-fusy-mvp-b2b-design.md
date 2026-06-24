# Fusy — Cadrage MVP B2B

Date : 2026-06-15  
Statut : validé en cadrage produit  
Périmètre : MVP B2B fermé pour entreprises et flottes

## 1. Résumé

Fusy MVP est une plateforme B2B fermée de gestion carburant pour entreprises. Le produit remplace les bons papier et les avances cash par un compte carburant entreprise prépayé, des budgets chauffeurs, des stations autorisées et une validation obligatoire à la pompe.

Le MVP ne cherche pas à lancer un wallet carburant grand public. Il valide d'abord que des entreprises acceptent de payer un abonnement pour contrôler leurs dépenses carburant et que des stations acceptent un flux QR + validation pompiste.

## 2. Cibles Prioritaires

Le MVP vise deux segments avec le même produit.

### 2.1 PME Avec Équipes Terrain

Exemples : commerciaux, techniciens, sécurité, ONG, maintenance, agences terrain.

Douleur principale : petites dépenses carburant fréquentes, avances cash, bons papier difficiles à contrôler.

Message commercial : "Donnez un budget carburant à chaque agent et suivez chaque dépense sans cash ni bon papier."

### 2.2 Transport, Logistique Et BTP

Exemples : chauffeurs, livraison, véhicules de chantier, transport local ou interurbain.

Douleur principale : montants carburant plus élevés, fraude, dépenses difficiles à justifier, manque de preuve par passage en station.

Message commercial : "Contrôlez les achats carburant par chauffeur, station et transaction avec validation à la pompe."

## 3. Modèle Économique MVP

Le MVP fonctionne par abonnement uniquement.

- Pas de commission sur transaction.
- Pas de commission prélevée aux stations.
- Stations gratuites pendant le pilote.
- Entreprises créées manuellement par Fusy après signature commerciale.
- Abonnement suivi manuellement au départ.

Offres indicatives :

| Offre | Taille indicative | Prix MVP |
|---|---:|---:|
| Pilot | 1 à 10 chauffeurs | 25 000 FCFA/mois |
| Team | 11 à 30 chauffeurs | 50 000 FCFA/mois |
| Fleet | 31 à 75 chauffeurs | 100 000 FCFA/mois |
| Enterprise | 75+ chauffeurs | Sur devis |

Une offre pilote peut être proposée aux premiers clients : 30 jours gratuits, puis abonnement mensuel.

## 4. Surfaces Produit

### 4.1 App Chauffeur

Technologie cible : Flutter Android + iOS.

Fonctions MVP :

- connexion par téléphone et PIN ;
- activation du compte chauffeur après création par l'admin entreprise ;
- affichage du budget disponible ;
- statut du compte entreprise : opérationnel, solde insuffisant ou suspendu ;
- scan du QR fixe station ;
- saisie du montant et du type carburant ;
- confirmation finale par PIN ;
- suivi du statut de transaction ;
- historique personnel ;
- reçu de transaction.

Exclus de l'app chauffeur MVP :

- recharge du compte entreprise ;
- micro-crédit ;
- portefeuille B2C ;
- promotions ;
- gestion d'entreprise ;
- gestion avancée des véhicules ;
- carte complexe des stations.

### 4.2 App Pompiste

Technologie cible : Flutter, Android prioritaire pour le MVP.

Fonctions MVP :

- connexion pompiste par téléphone et PIN ;
- rattachement à une station ;
- liste des demandes en attente ;
- recherche ou vérification par code court ;
- affichage du montant, type carburant et chauffeur ;
- validation ou refus ;
- historique des transactions du jour ;
- état réseau simple.

Le pompiste ne peut pas modifier le montant. Si le montant est incorrect, il refuse la demande et le chauffeur recrée une transaction.

### 4.3 Dashboard Entreprise

Fonctions MVP :

- consulter le solde du compte carburant ;
- créer et suspendre des chauffeurs ;
- attribuer un budget chauffeur ;
- choisir le mode budget : manuel, hebdomadaire ou mensuel ;
- consulter les stations autorisées ;
- consulter les transactions ;
- exporter les transactions en CSV ou PDF simple ;
- voir les alertes principales : solde bas, budget chauffeur épuisé, transaction refusée.

Exclus du dashboard entreprise MVP :

- inscription publique ;
- KYC self-service ;
- départements ;
- multi-niveaux d'approbation ;
- règles horaires ;
- règles par chauffeur pour les stations ;
- intégration comptable ;
- analytics avancés.

### 4.4 Dashboard Admin Fusy

Fonctions MVP :

- créer les entreprises après signature commerciale ;
- créer les comptes admin entreprise ;
- créditer manuellement le compte carburant après preuve de dépôt ou virement ;
- créer les stations ;
- générer et télécharger les QR fixes station ;
- créer les comptes pompistes ;
- rattacher les pompistes aux stations ;
- définir les stations autorisées par entreprise ;
- consulter toutes les transactions ;
- suspendre entreprises, chauffeurs, stations ou pompistes ;
- consulter un audit log minimal ;
- préparer les reversements station.

Exclus du dashboard admin MVP :

- automatisation Mobile Money ;
- scoring crédit ;
- micro-crédit ;
- campagnes marketing ;
- BI avancée ;
- support ticketing complet.

## 5. Onboarding

### 5.1 Entreprise

Les entreprises ne s'inscrivent pas elles-mêmes au MVP.

Flux :

1. Fusy prospecte et signe l'entreprise hors plateforme.
2. Fusy collecte les informations de base : nom, contact principal, téléphone, email, adresse optionnelle, documents si nécessaires.
3. Admin Fusy crée l'entreprise.
4. Admin Fusy crée le compte admin entreprise.
5. Fusy configure les stations autorisées.
6. L'entreprise fait un dépôt ou virement.
7. Admin Fusy valide le dépôt et crédite le compte carburant.
8. L'admin entreprise crée ses chauffeurs et budgets.

### 5.2 Chauffeur

Les chauffeurs sont créés manuellement par l'admin entreprise.

Flux :

1. Admin entreprise crée le chauffeur avec nom, téléphone, mode budget et montant.
2. Le chauffeur reçoit un SMS ou un code d'activation.
3. Il ouvre l'app chauffeur.
4. Il saisit son numéro.
5. Il confirme l'activation.
6. Il définit son PIN.
7. Il voit son budget disponible.

L'admin entreprise ne définit pas le PIN du chauffeur.

### 5.3 Station Et Pompiste

Flux :

1. Admin Fusy crée la station.
2. Admin Fusy génère le QR fixe station.
3. Le QR est imprimé et affiché dans la station.
4. Admin Fusy crée les comptes pompistes.
5. Chaque pompiste est rattaché à la station.
6. La station peut recevoir et valider les demandes des entreprises qui l'ont autorisée.

## 6. Compte Carburant Et Budgets

### 6.1 Compte Carburant Entreprise

Le compte carburant entreprise représente l'argent réellement disponible pour payer les transactions carburant.

Au MVP, le rechargement est manuel :

1. L'entreprise fait un dépôt, virement ou transfert hors plateforme.
2. Elle transmet la preuve à Fusy.
3. Admin Fusy vérifie la preuve.
4. Admin Fusy crédite le compte carburant.

L'intégration Orange Money ou MTN MoMo automatique est hors périmètre MVP.

### 6.2 Budget Chauffeur

Le budget chauffeur est une autorisation de dépense individuelle. Il ne crée pas d'argent.

Modes supportés :

- manuel : l'admin entreprise recharge le budget au besoin ;
- hebdomadaire : le budget est réinitialisé chaque semaine ;
- mensuel : le budget est réinitialisé chaque mois.

La réinitialisation remplace le solde restant. Elle ne l'ajoute pas.

Exemple :

- budget mensuel configuré : 100 000 FCFA ;
- solde restant avant reset : 18 000 FCFA ;
- solde après reset : 100 000 FCFA.

Chaque reset crée une entrée d'audit avec ancien solde, nouveau solde, reliquat expiré, date et type de reset.

### 6.3 Sur-Allocation

La sur-allocation est autorisée.

La somme des budgets chauffeurs peut dépasser le solde réel de l'entreprise. Une transaction ne passe que si les deux conditions suivantes sont vraies :

- budget chauffeur disponible supérieur ou égal au montant ;
- solde entreprise disponible supérieur ou égal au montant.

Si le solde entreprise est insuffisant, la transaction est bloquée avant création. Un événement d'audit peut être enregistré pour expliquer le refus.

## 7. Stations Autorisées

Les stations autorisées sont définies par entreprise uniquement au MVP.

Règles :

- une entreprise possède une liste de stations autorisées ;
- tous les chauffeurs de l'entreprise utilisent la même liste ;
- si un chauffeur scanne une station non autorisée, le paiement est bloqué immédiatement ;
- les règles par chauffeur, par ville, par horaire ou par zone GPS sont hors MVP.

## 8. QR Station Fixe

Chaque station possède un QR fixe imprimé.

Le QR ne contient pas de montant. Il contient :

- identifiant public de station ;
- token ou identifiant non devinable ;
- URL ou deeplink Fusy.

Garde-fous :

- l'app chauffeur affiche le nom de la station avant saisie du montant ;
- la station doit être autorisée pour l'entreprise ;
- validation pompiste obligatoire ;
- demande expirant après 5 minutes ;
- possibilité de suspendre ou remplacer un QR.

Même si un QR est copié, une transaction ne peut pas être finalisée sans validation d'un pompiste rattaché à la station.

## 9. Parcours De Paiement

Parcours principal :

1. Le chauffeur ouvre l'app Fusy.
2. Il scanne le QR fixe de la station.
3. L'app affiche la station.
4. Fusy vérifie que la station est autorisée pour l'entreprise.
5. Le chauffeur saisit le montant et le type carburant.
6. Fusy vérifie le budget chauffeur, le solde entreprise, le statut chauffeur, le statut entreprise et le statut station.
7. Si une vérification échoue, la transaction n'est pas créée.
8. Si tout est valide, Fusy crée une demande en attente pour 5 minutes.
9. La demande apparaît dans l'app pompiste de la station.
10. Le pompiste vérifie le code court, le montant et le type carburant.
11. Le pompiste valide ou refuse.
12. Si le pompiste valide, le chauffeur confirme par PIN.
13. Fusy débite le compte entreprise et le budget chauffeur.
14. La transaction passe en statut `completed`.
15. Un reçu est généré.

Ordre de confirmation retenu : pompiste d'abord, chauffeur ensuite par PIN.

## 10. États De Transaction

États MVP :

- `pending_attendant_validation` : demande créée, en attente du pompiste ;
- `attendant_approved` : pompiste a validé, en attente du PIN chauffeur ;
- `completed` : transaction finalisée et débitée ;
- `rejected` : pompiste a refusé ;
- `expired` : délai de 5 minutes dépassé ;
- `cancelled` : chauffeur a annulé avant finalisation ;
- `blocked` : tentative bloquée avant création transactionnelle, par exemple station non autorisée ou solde insuffisant.

Expiration :

- délai unique : 5 minutes ;
- si le pompiste ne valide pas dans le délai, la demande expire ;
- si le pompiste valide mais que le chauffeur ne confirme pas par PIN dans le délai, la demande expire ;
- aucune somme n'est débitée en cas d'expiration.

## 11. Reçu MVP

Le reçu contient :

- entreprise ;
- chauffeur ;
- station ;
- pompiste ;
- montant ;
- type carburant ;
- date et heure ;
- ID transaction ;
- statut ;
- code de référence court.

Le reçu est visible côté chauffeur, entreprise, station et admin Fusy.

## 12. Reporting MVP

### 12.1 Entreprise

Rapports minimaux :

- transactions par période ;
- transactions par chauffeur ;
- transactions par station ;
- total consommé ;
- transactions refusées ou expirées ;
- export CSV ou PDF simple.

### 12.2 Station

Rapports minimaux :

- transactions du jour ;
- transactions par période ;
- montant total à reverser ;
- transactions par pompiste ;
- export simple.

### 12.3 Fusy

Rapports minimaux :

- entreprises actives ;
- stations actives ;
- volume de transactions ;
- solde des comptes carburant ;
- transactions échouées ;
- montants dus aux stations.

## 13. Out Of Scope MVP

Sont explicitement exclus :

- B2C public ;
- micro-crédit ;
- intégration Mobile Money automatique ;
- paiement carte bancaire ;
- inscription self-service entreprise ;
- KYC automatisé ;
- commission sur transaction ;
- commission station ;
- fidélité ;
- géolocalisation avancée ;
- véhicule obligatoire ;
- départements ;
- règles horaires ;
- règles par chauffeur pour les stations ;
- import Excel chauffeur ;
- intégration comptable ;
- API publique ;
- USSD ;
- analytics avancés ;
- scoring fraude avancé.

## 14. Critères De Validation MVP

Le MVP est considéré validé si :

- 2 entreprises pilotes utilisent le produit avec des chauffeurs réels ;
- 2 stations pilotes valident des transactions via l'app pompiste ;
- un chauffeur peut scanner un QR station fixe, saisir un montant, obtenir validation pompiste et confirmer par PIN ;
- une transaction réussie débite correctement le solde entreprise et le budget chauffeur ;
- une transaction échouée ne débite rien ;
- une transaction expire après 5 minutes ;
- une station non autorisée bloque la transaction avant création ;
- un solde entreprise insuffisant bloque la transaction avant création ;
- les reçus sont visibles dans les surfaces concernées ;
- Fusy peut créditer manuellement un compte entreprise ;
- l'entreprise peut exporter ses transactions.

## 15. Risques Principaux

### 15.1 Risque Réglementaire

Le compte carburant prépayé implique collecte, conservation d'un solde et paiement à des stations. Le MVP doit être validé juridiquement et, si nécessaire, opéré avec un partenaire de paiement agréé.

Mitigation MVP : démarrage fermé, rechargement manuel, pas de micro-crédit, pas de lancement grand public, pas de promesse bancaire.

### 15.2 Risque Terrain Station

Les pompistes peuvent résister si le flux est trop long.

Mitigation MVP : app pompiste dédiée avec seulement demandes en attente, validation/refus et historique du jour.

### 15.3 Risque Solde Entreprise

Avec la sur-allocation, un chauffeur peut avoir un budget individuel mais être bloqué par un solde entreprise insuffisant.

Mitigation MVP : blocage avant création de transaction, statut compte entreprise visible dans l'app chauffeur, alertes solde bas côté entreprise.

### 15.4 Risque QR Copié

Un QR fixe peut être photographié.

Mitigation MVP : validation pompiste obligatoire, station affichée dans l'app, QR suspendable, transaction impossible sans pompiste rattaché.

## 16. Prochaine Étape

Après validation de ce document, produire un plan d'exécution MVP découpé en lots :

1. fondations backend et rôles ;
2. compte carburant et ledger ;
3. dashboard admin Fusy ;
4. dashboard entreprise ;
5. app chauffeur ;
6. app pompiste ;
7. parcours transaction QR station ;
8. reporting et exports ;
9. tests pilote et durcissement.

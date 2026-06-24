# Prompt Claude Design — App Chauffeur Fusy

Conçois l'application mobile **Chauffeur Fusy** pour le **MVP B2B fermé** de gestion des budgets carburant au Cameroun.

Lis et respecte tous les documents joints dans `design-briefs/00-shared/` et `design-briefs/01-driver-app/`. Utilise le logo fourni dans `assets/primary-logo.png` sans le redessiner.

## Direction visuelle non négociable

- Style : Clarté opérationnelle, sérieux B2B mais accessible.
- Police unique : **Manrope**.
- Bleu principal `#003362`, vert accent `#00B473`, fond `#F6F8FA`, surfaces blanches.
- Interface claire uniquement, sans gradients décoratifs, glassmorphism ni grandes ombres.
- Montants au format `15 000 FCFA` avec chiffres tabulaires.
- Cibles tactiles de 48 px minimum.
- Chaque statut combine couleur et texte.

## Produit

Le chauffeur ne possède pas un wallet. Son entreprise lui attribue un budget de dépense. Une transaction exige le scan du QR fixe d'une station autorisée, la validation du pompiste, puis la confirmation finale du chauffeur avec son PIN. La demande expire cinq minutes après sa création. Aucun débit n'a lieu après blocage, refus ou expiration.

## Écrans à concevoir

Activation par téléphone, code d'activation, création/confirmation PIN, connexion, accueil, permission caméra, scanner QR, résultat station autorisée/non autorisée, saisie montant/carburant/champ libre, récapitulatif, attente pompiste avec code court et minuterie, refus, expiration, confirmation PIN après validation pompiste, succès/reçu, historique et détail transaction.

## États obligatoires

Chargement, vide, hors ligne, réseau instable, permission caméra refusée, QR invalide, station non autorisée, budget insuffisant, compte entreprise insuffisant ou suspendu, PIN incorrect, pompiste refuse, expiration avant et après validation pompiste, confirmation en cours empêchant le double envoi, reprise de l'app avec demande active.

## Données à utiliser

Jean Mballa, TransLog Cameroun SARL, budget hebdomadaire 50 000 FCFA, Tradex Bonamoussadi, Armand Etoa, Super, transaction 15 000 FCFA, code 6821, ID TX-8F21K9, 19 juin 2026 à 14:32.

## Sortie attendue

1. Architecture et navigation mobile.
2. Maquettes haute fidélité en 390 × 844 px, vérifiées aussi à 360 × 800 px.
3. Tous les écrans principaux et variantes critiques.
4. Composants réutilisables avec états normal, pressé, focus, chargement, désactivé et erreur.
5. Courte annotation des décisions importantes et des transitions.

N'ajoute ni recharge, Mobile Money, wallet B2C, microcrédit, promotions, carte des stations, itinéraire, géolocalisation, KYC ou gestion d'entreprise. N'invente pas de nouvelle couleur, police ou variante du logo.

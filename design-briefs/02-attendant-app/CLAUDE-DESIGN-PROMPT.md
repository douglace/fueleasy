# Prompt Claude Design — App Pompiste Fusy

Conçois l'application Android **Pompiste Fusy** pour le **MVP B2B fermé**. Lis tous les documents joints de `design-briefs/00-shared/` et `design-briefs/02-attendant-app/`. Utilise `assets/primary-logo.png` sans le modifier.

## Direction imposée

Manrope uniquement ; bleu `#003362`, vert accent `#00B473`, fond `#F6F8FA`, surfaces blanches ; thème clair ; style opérationnel, rapide et très lisible au soleil ; cibles tactiles de 48 px ; montants au format FCFA ; aucun effet décoratif inutile.

## Règle métier essentielle

Le pompiste voit uniquement les paiements **déjà effectués** de sa station. Chaque paiement est réglé par le PIN du chauffeur au moment où il apparaît : le pompiste ne valide pas, ne refuse pas et ne modifie jamais. Son rôle est de **consulter** le paiement (code, chauffeur, entreprise, montant, carburant) pour servir le bon volume, puis d'en **accuser réception**. Il ouvre une session de travail sur une pompe en début de service et la ferme à la fin.

## Concevoir

Connexion, ouverture de session (choix de la pompe), session en cours avec QR de la pompe et état réseau, liste des paiements du jour (badge `À accuser` / `Accusé`), recherche par code court, détail de paiement en lecture seule avec action `Accuser réception`, confirmation d'accusé, historique du jour et total, détail transaction, profil avec fermeture de session.

Inclure chargement, liste vide, réseau instable, nouveau paiement à accuser, paiement déjà accusé sur un autre appareil, accusé au statut inconnu, aucune session ouverte et compte suspendu.

Utiliser Armand Etoa, Tradex Bonamoussadi, Pompe 1, Jean Mballa, TransLog Cameroun SARL, Super, 15 000 FCFA, code 6821 et ID TX-8F21K9.

## Sortie

Architecture mobile, maquettes haute fidélité 360 × 800 px, variantes critiques, composants et annotations de transition. N'ajoute ni validation/refus de transaction, scan QR, modification de montant, stock carburant, prix, encaissement, reversement, reporting multi-stations, création de compte ou fonctions Admin Fusy.

# Prompt Claude Design — App Pompiste Fusy

Conçois l'application Android **Pompiste Fusy** pour le **MVP B2B fermé**. Lis tous les documents joints de `design-briefs/00-shared/` et `design-briefs/02-attendant-app/`. Utilise `assets/primary-logo.png` sans le modifier.

## Direction imposée

Manrope uniquement ; bleu `#003362`, vert accent `#00B473`, fond `#F6F8FA`, surfaces blanches ; thème clair ; style opérationnel, rapide et très lisible au soleil ; cibles tactiles de 48 px ; montants au format FCFA ; aucun effet décoratif inutile.

## Règle métier essentielle

Le pompiste voit uniquement les demandes de sa station. Il vérifie code, chauffeur, entreprise, montant et carburant. Il peut valider ou refuser, mais jamais modifier. Après validation, la transaction reste incomplète jusqu'au PIN du chauffeur. La demande expire cinq minutes après sa création.

## Concevoir

Connexion, accueil station/état réseau, file des demandes, recherche code court, détail en lecture seule, confirmation de validation, confirmation de refus, attente PIN chauffeur, résultat terminé/refusé/expiré, historique du jour et détail transaction.

Inclure chargement, liste vide, réseau instable, demande expirée pendant lecture, demande déjà traitée, validation au statut inconnu et compte suspendu.

Utiliser Armand Etoa, Tradex Bonamoussadi, Jean Mballa, TransLog Cameroun SARL, Super, 15 000 FCFA, code 6821 et ID TX-8F21K9.

## Sortie

Architecture mobile, maquettes haute fidélité 360 × 800 px, variantes critiques, composants et annotations de transition. N'ajoute ni scan QR, modification de montant, stock carburant, prix, encaissement, reversement, reporting multi-stations, création de compte ou fonctions Admin Fusy.

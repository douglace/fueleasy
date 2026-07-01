# Composants, états et erreurs — Pompiste

## Composants spécifiques

- Carte de paiement : code court dominant, montant, chauffeur, carburant, heure, badge `À accuser` / `Accusé`.
- Liste chronologique : le plus récent en tête, sans animation agressive.
- Recherche code court : quatre chiffres, clavier numérique.
- Détail en lecture seule : aucune apparence de champ éditable.
- Bouton unique `Accuser réception` (aucun bouton de validation ou de refus).
- Carte session de travail : station, pompe, QR, action `Fermer la session`.
- Bandeau réseau : connecté, instable, hors ligne, synchronisation.

## États critiques

- liste en chargement ;
- liste vide ;
- nouveau paiement reçu (à accuser) ;
- paiement déjà accusé sur un autre appareil ;
- accusé envoyé mais statut inconnu (réseau) ;
- aucune session de travail ouverte ;
- session ou compte suspendu.

## Messages

- `Aucun paiement avec le code 6821 aujourd'hui dans cette station.`
- `Réception accusée.`
- `Ce paiement a déjà été accusé. Actualisez la liste.`
- `Connexion instable. Nous vérifions si votre accusé a été enregistré.`
- `Ouvrez une session de travail sur une pompe pour commencer.`

Le bouton ne doit jamais devenir `Servir le carburant` ni `Valider` : l'app sert à consulter les paiements effectués et à en accuser réception, pas à autoriser ni à gérer physiquement le service.

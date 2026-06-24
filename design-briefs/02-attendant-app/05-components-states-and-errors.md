# Composants, états et erreurs — Pompiste

## Composants spécifiques

- Carte de demande : code, minuterie, montant, chauffeur, carburant.
- File priorisée : expiration proche en premier, sans animation agressive.
- Recherche code court : quatre chiffres, clavier numérique.
- Détail en lecture seule : aucune apparence de champ éditable.
- Actions séparées : validation bleue, refus rouge moins dominant mais explicite.
- Bandeau réseau : connecté, instable, hors ligne, synchronisation.

## États critiques

- liste en chargement ;
- liste vide ;
- nouvelle demande reçue ;
- demande déjà traitée sur un autre appareil ;
- demande expirée pendant la lecture ;
- validation envoyée mais statut inconnu ;
- attente chauffeur ;
- chauffeur confirme ;
- chauffeur ne confirme pas avant expiration ;
- session ou compte suspendu.

## Messages

- `Aucune demande active avec le code 6821 dans cette station.`
- `Cette demande vient d'expirer. Elle ne peut plus être validée.`
- `Validation enregistrée. Le chauffeur doit maintenant confirmer avec son PIN.`
- `Demande refusée. Aucun montant n'a été débité.`
- `Connexion instable. Nous vérifions si votre validation a été enregistrée.`
- `Cette demande a déjà été traitée. Actualisez la liste.`

Le bouton ne doit jamais devenir `Servir le carburant` : l'app valide une demande, elle ne gère pas physiquement le service.

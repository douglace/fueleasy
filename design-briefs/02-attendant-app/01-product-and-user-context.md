# Contexte produit et utilisateur — Pompiste

## Utilisateur

Armand est pompiste à Tradex Bonamoussadi. Son compte a été créé par Admin Fusy et rattaché à cette station. Il doit traiter une demande en quelques secondes sans ralentir le service.

## Objectifs

- Voir immédiatement les demandes de sa station.
- Retrouver une demande par son code court.
- Comparer code, chauffeur, entreprise, montant et carburant.
- Valider ou refuser sans ambiguïté.
- Savoir que la transaction attend encore le PIN chauffeur.
- Vérifier l'activité du jour.

## Contraintes terrain

- Forte luminosité, bruit et mains parfois occupées.
- Téléphone Android d'entrée de gamme partagé ou dédié.
- Réseau mobile instable.
- Demandes limitées à cinq minutes.
- Risque de sélectionner la mauvaise demande.
- Le pompiste ne doit jamais modifier montant ou carburant.

## Permissions

Armand voit uniquement les demandes et transactions de sa station. Il ne voit pas les soldes entreprises, budgets chauffeurs, autres stations, reversements globaux ou fonctions Admin Fusy.

## Priorités de design

Lisibilité à distance, code court dominant, minuterie claire, actions valider/refuser séparées, confirmation de la station et statut `En attente du chauffeur` après validation.

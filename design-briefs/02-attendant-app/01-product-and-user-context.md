# Contexte produit et utilisateur — Pompiste

## Utilisateur

Armand est pompiste à Tradex Bonamoussadi. Son compte a été créé par Admin Fusy et rattaché à cette station. Il doit repérer un paiement effectué en quelques secondes et servir le carburant sans ralentir le service.

## Objectifs

- Ouvrir sa session de travail sur une pompe en début de service.
- Voir immédiatement les paiements effectués du jour dans sa station.
- Être averti d'un nouveau paiement et en accuser réception.
- Retrouver un paiement par son code court.
- Lire code, chauffeur, entreprise, montant et carburant pour servir le bon volume.
- Consulter l'activité du jour.

## Contraintes terrain

- Forte luminosité, bruit et mains parfois occupées.
- Téléphone Android d'entrée de gamme partagé ou dédié.
- Réseau mobile instable.
- Risque de confondre deux paiements.
- Le pompiste ne valide, ne refuse ni ne modifie jamais un paiement : il est déjà réglé par le PIN du chauffeur.

## Permissions

Armand voit uniquement les paiements et transactions de sa station. Il ne voit pas les soldes entreprises, budgets chauffeurs, autres stations, reversements globaux ou fonctions Admin Fusy.

## Priorités de design

Lisibilité à distance, code court et montant dominants, distinction nette entre paiement `À accuser` et paiement `Accusé`, station et session de travail toujours visibles. Ne jamais présenter d'action de validation ou de refus.

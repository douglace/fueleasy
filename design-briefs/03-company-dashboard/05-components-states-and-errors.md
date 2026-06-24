# Composants, états et erreurs — Entreprise

## Composants spécifiques

- Carte Solde réel avec état et dernière mise à jour.
- Carte Budget total avec aide `Autorisations, non argent réservé`.
- Tableau Chauffeurs avec statuts Invité, Actif, Suspendu.
- Contrôle Mode budget : Manuel, Hebdomadaire, Mensuel.
- Alerte actionnable avec cause et destination.
- Barre de filtres persistante au-dessus des tableaux.
- Tableau Transactions avec montants tabulaires.
- Modal sensible pour suspension et changement de budget.
- État Export : préparation, prêt, échec.

## États à couvrir

- aucun chauffeur ;
- chauffeurs sans budget ;
- activation en attente ;
- solde bas ou insuffisant ;
- aucune station autorisée ;
- aucun résultat après filtres ;
- export en cours ;
- données temporairement indisponibles ;
- session expirée ;
- action concurrente déjà effectuée.

## Messages

- `Le solde du compte est l'argent disponible. Les budgets chauffeurs sont des autorisations de dépense.`
- `La somme des budgets dépasse le solde du compte. C'est autorisé, mais certaines transactions pourraient être bloquées si le solde devient insuffisant.`
- `Ce chauffeur choisira lui-même son PIN pendant l'activation.`
- `Les stations autorisées sont configurées par Fusy pour le pilote.`
- `Aucune transaction ne correspond à ces filtres.`
- `L'export est prêt.`

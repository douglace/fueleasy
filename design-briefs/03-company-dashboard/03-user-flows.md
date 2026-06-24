# Parcours utilisateur — Entreprise

## Créer et activer un chauffeur

1. Depuis Chauffeurs, cliquer `Ajouter un chauffeur`.
2. Saisir nom, téléphone, budget, mode et champ libre optionnel.
3. Afficher un récapitulatif expliquant le budget comme autorisation.
4. Créer le chauffeur avec statut `Invité`.
5. Afficher code ou état d'activation et action `Relancer l'activation`.
6. Après activation mobile, le statut devient `Actif`.

Branches : téléphone déjà utilisé, montant invalide, création échouée, SMS non disponible. Ne pas demander de définir le PIN du chauffeur.

## Modifier un budget

1. Ouvrir le chauffeur.
2. Choisir manuel, hebdomadaire ou mensuel.
3. Saisir le montant.
4. Pour un mode périodique, expliquer que le prochain reset remplace le solde restant.
5. Confirmer et afficher la date d'effet.

La sur-allocation déclenche une information, pas une erreur bloquante.

## Suspendre un chauffeur

Modal avec nom, impact immédiat et confirmation `Suspendre Jean Mballa`. Le budget n'est pas supprimé. Le statut devient `Suspendu`, avec action inverse `Réactiver`.

## Consulter et exporter des transactions

1. Ouvrir Transactions.
2. Filtrer période, chauffeur, station, statut et carburant.
3. Vérifier les totaux du résultat filtré.
4. Ouvrir un détail ou lancer CSV/PDF.
5. Afficher préparation, succès ou échec de l'export.

## Vérifier une alerte de solde bas

L'alerte explique le solde, l'impact possible et la procédure hors plateforme pour réalimenter. Aucun bouton Mobile Money n'est affiché.

## Voir les stations autorisées

Liste en lecture seule avec état. Une note explique que les modifications passent par Fusy. Une éventuelle action `Contacter Fusy` ne simule pas un workflow interne absent.

# Spécifications des écrans — Pompiste

## 1. Connexion

Logo, téléphone, PIN, bouton `Se connecter`, aide courte. États : erreur PIN, compte suspendu, non rattaché, hors ligne.

## 2. Accueil / station

En-tête avec station, état réseau et nombre de demandes. Action de recherche par code, liste triée par expiration la plus proche.

## 3. Demandes en attente

Chaque ligne affiche code dominant, temps restant, montant, carburant, chauffeur et entreprise. État vide : `Aucune demande en attente dans cette station`.

## 4. Recherche par code court

Clavier numérique, quatre positions, résultat exact. Autoriser correction rapide et soumission automatique après quatre chiffres sans empêcher le bouton explicite.

## 5. Détail demande

Code, minuterie, montant, carburant, chauffeur, entreprise et station. Toutes les valeurs sont en lecture seule. Bouton principal `Valider la demande`, bouton destructif secondaire `Refuser` visuellement séparé.

## 6. Confirmation validation

Modal ou feuille récapitulant code, montant, carburant et chauffeur. Actions `Confirmer la validation` et `Retour`. Aucun PIN pompiste demandé au MVP.

## 7. Confirmation refus

Explique l'absence de débit. Motif optionnel seulement s'il est prévu côté produit ; sinon confirmation simple. Action `Refuser la demande`.

## 8. Résultat

Variantes : `En attente du chauffeur`, `Transaction terminée`, `Demande refusée`, `Demande expirée`. Chaque variante indique la prochaine action.

## 9. Attente chauffeur

Montant et code visibles, texte `Demandez au chauffeur de confirmer dans son app`, minuterie restante, mise à jour automatique.

## 10. Historique du jour

Résumé : transactions terminées et montant total. Liste avec filtres simples de statut. Ne pas présenter le total comme un solde à retirer.

## 11. Détail transaction

Statut, chauffeur, entreprise, montant, carburant, date/heure, code, ID et preuve du rôle du pompiste. Une transaction non terminée n'est pas un reçu final.

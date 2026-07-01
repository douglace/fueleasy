# Spécifications des écrans — Pompiste

## 1. Connexion

Logo, téléphone, PIN, bouton `Se connecter`, aide courte. États : erreur PIN, compte suspendu, non rattaché, hors ligne.

## 2. Ouverture de session

Après connexion, choisir la pompe pour ouvrir une session de travail. Afficher la station rattachée. Bouton `Ouvrir la session`. Si une session est déjà ouverte, proposer de la reprendre.

## 3. Session en cours / QR pompe

En-tête station + pompe, état réseau, QR de la pompe affiché en grand pour le scan par les chauffeurs, accès rapide aux paiements du jour et à la recherche par code, action `Fermer la session`.

## 4. Paiements du jour

Liste des paiements effectués de la station, le plus récent en tête. Chaque ligne affiche code court dominant, montant, carburant, chauffeur, entreprise, heure et un badge `À accuser` ou `Accusé`. État vide : `Aucun paiement aujourd'hui dans cette station`.

## 5. Recherche par code court

Clavier numérique, quatre positions, résultat exact. Autoriser correction rapide et soumission automatique après quatre chiffres sans empêcher le bouton explicite.

## 6. Détail paiement

Code, montant, carburant, chauffeur, entreprise, station, heure et identifiant. Toutes les valeurs sont en **lecture seule**. Si le paiement n'est pas encore accusé, bouton principal `Accuser réception`. Aucune action de validation, de refus ou de modification.

## 7. Confirmation d'accusé

Retour léger (feuille ou bandeau) : `Réception accusée`. Le paiement passe au badge `Accusé`. Aucun débit, aucune annulation ne découle de cette action.

## 8. Historique du jour

Résumé : nombre de paiements et montant total du jour. Liste avec filtre simple (tous / à accuser / accusés). Ne pas présenter le total comme un solde à retirer.

## 9. Détail transaction

Statut, chauffeur, entreprise, montant, carburant, date/heure, code, ID et rôle du pompiste. Le reçu final appartient au paiement payé.

## 10. Profil

Identité du pompiste, station, session de travail en cours, action `Fermer la session` et `Déconnexion`.

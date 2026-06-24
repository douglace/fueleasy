# Spécifications des écrans — Admin Fusy

## 1. Connexion

Accès interne sans inscription. États erreur, session expirée, compte suspendu et récupération.

## 2. Vue d'ensemble

Entreprises, stations et chauffeurs actifs, transactions terminées/bloquées, volume traité, soldes comptes et montants dus. Alertes opérationnelles et activité récente. Pas de BI complexe.

## 3. Entreprises

Tableau recherche/filtre avec nom, contact, statut, solde, chauffeurs et stations autorisées. Action `Créer une entreprise`.

## 4. Détail entreprise

En-tête statut, solde, contact, admin, chauffeurs, stations autorisées, transactions et audit récent. Actions créditer, modifier, créer admin, suspendre/réactiver.

## 5. Création admin entreprise

Nom, téléphone, email, état d'invitation. Préciser que l'utilisateur définira ses propres accès.

## 6. Crédit manuel

Formulaire montant, référence, méthode `Dépôt/Virement/Transfert`, note, date. Récapitulatif ancien/nouveau solde et confirmation renforcée.

## 7. Stations

Liste avec statut, zone, QR, pompistes, entreprises autorisées et activité. Création et filtres.

## 8. Détail station et QR

Informations, statut QR, aperçu, téléchargement, remplacement, désactivation, pompistes, transactions et audit. Ne jamais présenter le QR comme contenant un montant.

## 9. Pompistes

Liste globale et section station : identité, téléphone masqué, station, activation et statut. Actions créer, rattacher, suspendre, relancer.

## 10. Stations autorisées

Sélection recherchable depuis l'entreprise, distinction sélection actuelle/nouvelle, impossibilité de sélectionner une station suspendue, résumé avant validation.

## 11. Transactions

Filtres complets, volume filtré, tableau et export de consultation si prévu. Les états internes sont traduits en libellés français.

## 12. Détail transaction

Acteurs, montant, carburant, horodatages, code, ID, état et chronologie. Pour `Bloquée`, afficher la vérification échouée sans données sensibles inutiles.

## 13. Audit

Tableau date/heure, opérateur, action, entité, valeur avant/après et référence. Filtres par période, opérateur, type et entité.

## 14. Reversements

Vue par station avec dû, dernier lot, période et statut. Liste des lots et action `Générer un lot`.

## 15. Détail lot

Station, période, transactions, total, statut, référence de paiement et chronologie. Actions `Marquer vérifié`, `Marquer comme payé`, `Annuler` selon état, toujours confirmées.

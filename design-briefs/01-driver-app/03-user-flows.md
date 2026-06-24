# Parcours utilisateur — Chauffeur

## 1. Activation

**Précondition :** le responsable a créé Jean et un code d'activation est disponible.

1. Jean saisit son numéro.
2. L'app indique qu'un code lui a été envoyé ou remis.
3. Jean saisit le code.
4. Il crée un PIN à quatre chiffres puis le confirme.
5. L'app confirme l'activation et ouvre l'accueil.

Branches : code invalide, code expiré, numéro inconnu, PIN non identique, réseau indisponible. Aucun parcours d'inscription libre n'est proposé.

## 2. Connexion

1. Numéro prérempli lorsque l'app le connaît.
2. Saisie du PIN.
3. Accueil si le compte est actif.

Après plusieurs erreurs, afficher une temporisation et une voie de support ou de réactivation sans révéler d'information sensible.

## 3. Transaction nominale

1. Depuis l'accueil, Jean touche `Scanner une station`.
2. Il accorde la permission caméra si nécessaire.
3. Il scanne le QR de Tradex Bonamoussadi.
4. L'app affiche la station et confirme `Station autorisée`.
5. Jean saisit `15 000 FCFA`, choisit `Super` et renseigne éventuellement `LT-482-AA`.
6. Un récapitulatif affiche station, montant, carburant et budget après opération.
7. Jean crée la demande.
8. L'écran indique `Présentez le code 6821 au pompiste` et `Expire dans 04:58`.
9. Après validation du pompiste, l'écran devient `Le pompiste a validé`.
10. Jean vérifie les détails et saisit son PIN.
11. L'app bloque le double envoi, attend le résultat et affiche le reçu.

## 4. Station non autorisée

Après scan, l'app affiche le nom de la station, le blocage, l'absence de débit et l'action `Scanner une autre station`. Aucun formulaire de montant n'est présenté.

## 5. Budget ou solde insuffisant

Le blocage intervient avant création. Le chauffeur voit la cause qu'il peut comprendre : son budget disponible ou l'indisponibilité du compte entreprise. Le solde exact de l'entreprise reste masqué.

## 6. Refus du pompiste

L'attente bascule vers `Demande refusée`. Le message précise qu'aucun montant n'a été débité. Actions : `Modifier la demande` ou `Retour à l'accueil`.

## 7. Expiration

La minuterie atteint zéro avant une des validations. L'app affiche `Demande expirée`, absence de débit et bouton `Créer une nouvelle demande`. Elle ne tente pas de prolonger silencieusement la demande.

## 8. PIN incorrect après validation

Le détail reste visible, le champ PIN est vidé et l'erreur est annoncée. La minuterie continue. Après expiration, la confirmation devient impossible.

## 9. Reprise après perte réseau

L'app conserve l'identifiant de la demande, affiche un bandeau hors ligne et resynchronise son statut. Elle ne crée jamais une deuxième demande automatiquement.

## 10. Historique et reçu

Jean filtre mentalement par date grâce à une liste récente claire. Il ouvre une transaction, voit son statut, les acteurs, le montant et le code. Seules les transactions terminées disposent d'un reçu final.

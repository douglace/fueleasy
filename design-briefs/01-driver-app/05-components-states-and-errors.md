# Composants, états et erreurs — Chauffeur

## Composants spécifiques

### Carte Budget

Libellé `Budget disponible`, montant tabulaire, mode de renouvellement et prochaine date de remise à niveau si connue. Ne jamais la présenter comme un wallet rechargeable.

### Scanner

Cadre large, contraste élevé, instruction courte et retour haptique après lecture réussie. Aucun QR décoratif.

### Sélecteur de carburant

Deux grandes options exclusives : `Super` et `Gasoil`. Afficher texte et état sélectionné ; ne pas dépendre d'une icône ou d'une couleur seule.

### Champ Montant

Clavier numérique, regroupement des milliers à l'affichage, suffixe fixe `FCFA`, validation contre budget disponible. La valeur brute saisie reste stable pendant la frappe.

### PIN

Quatre positions, saisie masquée, erreur annoncée, clavier numérique et protection contre le double envoi. Ne jamais stocker ou afficher le PIN dans un récapitulatif.

### Code court et minuterie

Code très lisible, chiffres tabulaires, libellé `Code à donner au pompiste`. Minuterie textuelle `Expire dans 04:32`, puis avertissement sans clignotement agressif sous une minute.

### Carte Transaction

Station, date, carburant, montant, badge textuel. Toute la carte peut ouvrir le détail avec une cible accessible.

## États des actions

| État | Comportement |
|---|---|
| Normal | Action claire et disponible. |
| Pressé | Retour visuel et haptique léger. |
| Chargement | Libellé conservé ou remplacé par une formulation précise ; clic bloqué. |
| Désactivé | Contraste suffisant et raison visible à proximité. |
| Succès | Confirmation textuelle, pas uniquement une coche. |
| Erreur | Message près de la source et action de reprise. |

## Réseau

- Bandeau persistant `Connexion instable` lorsqu'une demande est active.
- Bouton `Réessayer` pour une opération sûre.
- Synchronisation automatique de statut sans créer une nouvelle demande.
- Si le résultat d'une confirmation est inconnu, afficher `Vérification du statut` plutôt que déclarer un échec.

## Messages prêts à utiliser

- QR invalide : `Ce QR n'est pas reconnu par Fusy. Scannez le QR officiel affiché dans la station.`
- Station non autorisée : `Votre entreprise n'autorise pas les achats dans cette station.`
- Budget insuffisant : `Votre budget disponible est de {budget}. Saisissez un montant inférieur ou contactez votre responsable.`
- Solde entreprise : `Le compte carburant de votre entreprise est temporairement insuffisant. Contactez votre responsable.`
- Refus : `Le pompiste a refusé cette demande. Aucun montant n'a été débité.`
- Expiration : `La demande a expiré après 5 minutes. Aucun montant n'a été débité.`
- PIN incorrect : `PIN incorrect. Vérifiez puis réessayez avant l'expiration.`
- Réseau : `Connexion instable. Nous vérifions le statut de votre demande.`

## État vide

Historique vide : `Aucune transaction pour le moment` puis `Votre premier reçu apparaîtra ici après une transaction terminée.` L'action peut retourner à l'accueil, pas lancer automatiquement la caméra.

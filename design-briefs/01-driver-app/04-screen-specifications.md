# Spécifications des écrans — Chauffeur

## Gabarit mobile commun

Barre système native, en-tête simple, contenu défilable si nécessaire et action principale persistante en bas uniquement lorsqu'elle ne masque pas le clavier. Marge latérale 16 px. Afficher l'état réseau lorsqu'il influence le parcours.

## 1. Téléphone d'activation

**Objectif :** retrouver une invitation existante.  
**Contenu :** logo, titre `Activez votre compte`, indicatif `+237`, téléphone, aide.  
**Action :** `Continuer`.  
**États :** vide, numéro incomplet, numéro inconnu, chargement, hors ligne.  
**UX :** ne pas afficher `Créer un compte`.

## 2. Code d'activation

Six cases ou un champ segmenté, numéro masqué, délai et renvoi si disponible. Autoriser le collage. Erreur sans effacer inutilement tout le code.

## 3. Création du PIN

PIN à quatre chiffres, pavé numérique, explication `Ce PIN confirmera vos transactions`. Prévoir saisie puis confirmation, visibilité temporaire accessible et erreur de non-correspondance.

## 4. Connexion

Téléphone connu ou modifiable, PIN, action `Se connecter`, aide `PIN oublié ou compte non activé ?`. États : PIN incorrect, compte suspendu, session expirée, réseau.

## 5. Accueil

Afficher : `Bonjour Jean`, `TransLog Cameroun SARL`, budget `50 000 FCFA`, mode `Hebdomadaire`, état du compte entreprise, action `Scanner une station`, dernier reçu. Si le compte entreprise est suspendu ou indisponible, le bouton reste visible mais désactivé avec explication.

## 6. Permission caméra

Pré-permission claire expliquant l'usage. Après refus : illustration non obligatoire, texte, bouton `Autoriser la caméra` et lien vers réglages si refus permanent. Ne pas proposer la saisie manuelle d'un token QR au MVP.

## 7. Scanner QR

Vue caméra, cadre de scan, instruction `Placez le QR de la station dans le cadre`, lampe si disponible, retour. États : recherche, QR lu, QR invalide, caméra indisponible, hors ligne après lecture.

## 8. Résultat station

Nom, localisation textuelle courte si disponible et badge `Autorisée`. Si non autorisée, utiliser une page de blocage avec raison et action de rescan, sans afficher le formulaire.

## 9. Détails de la demande

Station verrouillée, champ montant numérique avec suffixe FCFA, choix `Super` ou `Gasoil`, champ libre optionnel véhicule/plaque/mission, budget disponible. Le bouton `Continuer` reste désactivé tant que les données sont invalides.

## 10. Récapitulatif

Répéter station, montant, carburant, information libre et budget estimé après opération. Action `Confirmer avec le PIN`, secondaire `Modifier`. Préciser que le débit intervient à la confirmation du PIN.

## 11. Confirmation PIN

Récapitulatif non modifiable (station, montant, carburant), minuterie restante `Expire dans 04:32`, saisie PIN à quatre chiffres et action `Confirmer 15 000 FCFA` (le nom du bouton inclut le montant). Anti double-envoi pendant la confirmation. Il n'existe aucun écran d'attente pompiste : la confirmation débite immédiatement.

## 12. Expiration

Page de résultat `Demande expirée`, cause lorsqu'elle est disponible, `Aucun montant n'a été débité`, et action adaptée : recommencer ou accueil.

## 13. Succès et reçu

État `Transaction payée`, montant, station, date/heure, carburant, ID, code court à présenter au pompiste, nom du pompiste et nouveau budget. Actions : `Voir le reçu` et `Retour à l'accueil`.

## 14. Historique

Liste groupée par date avec station, montant, carburant et statut. Les montants sont alignés. États : chargement, vide, erreur, pagination ou chargement progressif simple.

## 15. Détail transaction

Chronologie courte du statut, toutes les données du reçu, identifiant copiable et action de partage/téléchargement seulement si prévue par l'implémentation du reçu. Pour une transaction non payée, afficher `Ce document n'est pas un reçu final`.

## Écrans de blocage transversaux

- compte chauffeur suspendu ;
- compte entreprise suspendu ;
- budget insuffisant ;
- solde entreprise insuffisant sans afficher son montant ;
- station ou QR inactif ;
- transaction déjà traitée ;
- session expirée.

Chaque blocage nomme la cause, indique la prochaine action et confirme l'absence de débit lorsque pertinent.

# Parcours utilisateur — Pompiste

## Connexion

Armand saisit son téléphone et son PIN. Après succès, l'app affiche clairement `Tradex Bonamoussadi`. Un compte suspendu ou non rattaché bloque l'accès avec une instruction de contacter le gérant ou Fusy.

## Validation nominale

1. La demande `6821` apparaît en haut avec `Expire dans 04:12`.
2. Armand ouvre la demande et compare Jean Mballa, TransLog Cameroun SARL, Super et 15 000 FCFA.
3. Il touche `Valider la demande`.
4. Une confirmation répète code, montant et carburant.
5. Après validation, l'écran indique `En attente du PIN chauffeur`.
6. Quand Jean confirme, l'état devient `Transaction terminée`.

La validation pompiste n'est jamais présentée comme un paiement final.

## Recherche par code

Armand saisit quatre chiffres. Un résultat exact s'ouvre. Aucun résultat : message `Aucune demande active avec ce code dans cette station` et possibilité de corriger.

## Refus

Armand touche `Refuser`, voit l'impact `La demande sera annulée sans débit`, confirme éventuellement un motif simple puis obtient `Demande refusée`.

## Expiration

Une demande expirée disparaît de la file active ou reste brièvement marquée `Expirée`. Sur le détail, les actions sont désactivées et aucun débit n'est annoncé.

## Réseau instable

Une action envoyée affiche `Vérification du statut`. L'app empêche un second envoi et synchronise avant d'annoncer réussite ou échec.

## Mauvaise station

Les demandes d'une autre station ne sont jamais visibles. Un lien profond ou identifiant externe affiche une erreur d'autorisation sans révéler les détails.

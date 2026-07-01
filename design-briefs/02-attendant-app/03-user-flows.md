# Parcours utilisateur — Pompiste

## Connexion et ouverture de session

Armand saisit son téléphone et son PIN. Après succès, l'app affiche clairement `Tradex Bonamoussadi`. Il ouvre une session de travail sur une pompe (par exemple `Pompe 1`) ; l'app affiche le QR de la pompe et l'état réseau. Un compte suspendu ou non rattaché bloque l'accès avec une instruction de contacter le gérant ou Fusy.

## Consultation et accusé de réception (nominal)

1. Le paiement `6821` apparaît en tête des paiements du jour, marqué `À accuser`, avec Jean Mballa, TransLog Cameroun SARL, Super et `15 000 FCFA`.
2. Armand ouvre le paiement et lit le montant et le carburant à servir.
3. Il touche `Accuser réception`.
4. Le paiement passe au statut `Accusé` ; Armand sert le carburant correspondant.

Le paiement est déjà réglé au moment où il apparaît : il n'y a ni validation ni refus. L'accusé de réception ne débite ni n'annule rien ; il confirme seulement que le pompiste a vu la transaction.

## Recherche par code

Armand saisit quatre chiffres. Le paiement correspondant s'ouvre. Aucun résultat : message `Aucun paiement avec ce code aujourd'hui dans cette station` et possibilité de corriger.

## Nouveau paiement pendant le service

Un nouveau paiement effectué apparaît automatiquement en tête de liste, marqué `À accuser`, avec un rappel visuel discret. Si le pompiste ne l'accuse pas rapidement, Fusy envoie un SMS de secours ; l'accusé dans l'app lève ce rappel.

## Réseau instable

Un accusé envoyé affiche `Vérification du statut`. L'app empêche un second envoi et synchronise avant d'annoncer réussite ou échec.

## Mauvaise station

Les paiements d'une autre station ne sont jamais visibles. Un lien profond ou identifiant externe affiche une erreur d'autorisation sans révéler les détails.

## Fin de service

Armand ferme sa session de travail depuis le profil. La pompe n'est plus rattachée à sa session.

# Composants, états et erreurs — Admin Fusy

## Composants spécifiques

- En-tête d'entité avec statut global.
- Checklist d'onboarding entreprise/station.
- Formulaire financier avec ancien et nouveau solde.
- Sélecteur de stations multi-choix recherché.
- Aperçu QR avec statut actif/inactif.
- Chronologie transactionnelle.
- Ligne d'audit avant/après.
- Carte de montant dû par station.
- Tableau de lot et barre de statut.
- Modal de confirmation renforcée.

## Confirmation renforcée

Pour crédit, suspension, remplacement QR et paiement de lot, afficher : entité, action, impact, valeur et bouton explicite. Exemple : `Créditer 500 000 FCFA à TransLog Cameroun SARL`.

## États

- onboarding incomplet ;
- entreprise sans admin ;
- preuve ou référence manquante ;
- crédit en cours / résultat inconnu ;
- QR non généré, actif, remplacé, désactivé ;
- station sans pompiste ;
- station suspendue ;
- aucun résultat transaction ;
- lot vide, générable, vérifié, payé, annulé ;
- transaction déjà rattachée ;
- action concurrente ;
- session expirée.

## Messages

- `Vérifiez l'entreprise et le montant avant de créditer le compte. Cette action sera auditée.`
- `Le nouveau solde sera de 2 350 000 FCFA.`
- `Remplacer ce QR désactivera immédiatement l'ancien exemplaire.`
- `Cette station est suspendue et ne peut pas être autorisée.`
- `Ce lot contient 143 transactions terminées non encore reversées.`
- `Le paiement a lieu hors Fusy. Enregistrez ici sa référence après exécution.`
- `Le statut de l'opération est en cours de vérification. Ne recommencez pas maintenant.`

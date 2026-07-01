# Accessibilité et contenu

## Langue et ton

L'interface est en français. Le ton est direct, professionnel et rassurant. Préférer des phrases courtes et des verbes d'action.

Exemples :

- `Scanner une station` plutôt que `Démarrer le processus d'achat` ;
- `Budget insuffisant` plutôt que `Transaction impossible` ;
- `Aucun montant ne sera débité` après un blocage ou une expiration ;
- `Confirmez le paiement avec votre PIN.` plutôt que `Valider la transaction`.

## Terminologie stable

| Terme | Définition utilisateur |
|---|---|
| Compte carburant | Argent réellement disponible pour les dépenses de l'entreprise. |
| Budget chauffeur | Autorisation de dépense attribuée à un chauffeur. |
| Station autorisée | Station dans laquelle l'entreprise accepte les transactions. |
| Demande carburant | Transaction créée, en attente de la confirmation PIN du chauffeur. |
| Code court | Code à quatre chiffres permettant au pompiste de retrouver le paiement effectué. |
| Reçu | Preuve finale d'une transaction payée. |

Ne pas utiliser `wallet`, `crédit` ou `paiement effectué` lorsque le sens métier est budget, compte ou demande en attente.

## Formats

- Montant : `15 000 FCFA`, sans décimale.
- Téléphone affiché : `+237 6•• •• 45 89` lorsque le numéro complet n'est pas nécessaire.
- Date courte : `19 juin 2026`.
- Date avec heure : `19 juin 2026 à 14:32`.
- Identifiant : `TX-8F21K9`.
- Code court : `6821`, affiché en chiffres espacés visuellement.
- Durée : `Expire dans 04:32`.

## Messages d'erreur

Un message doit indiquer :

1. ce qui s'est passé ;
2. pourquoi lorsque l'information est sûre et utile ;
3. ce que l'utilisateur peut faire ;
4. si un débit a eu lieu.

Exemples :

- `Cette station n'est pas autorisée par votre entreprise. Choisissez une autre station. Aucun montant n'a été débité.`
- `Votre budget disponible est de 12 000 FCFA. Saisissez un montant inférieur ou contactez votre responsable.`
- `La demande a expiré. Créez une nouvelle demande pour continuer. Aucun montant n'a été débité.`
- `Connexion instable. Nous réessaierons automatiquement dès que le réseau revient.`

Ne pas exposer les codes d'erreur techniques dans le message principal. Ils peuvent apparaître dans un détail destiné au support.

## États à concevoir

Pour chaque écran concerné :

- chargement initial ;
- actualisation ;
- contenu normal ;
- liste vide avec prochaine action ;
- erreur récupérable ;
- erreur bloquante ;
- hors ligne ;
- session expirée ;
- permission refusée ;
- action en cours empêchant le double clic.

## Accessibilité

- Contraste WCAG AA pour textes et contrôles essentiels.
- Cible tactile minimale de 48 × 48 px.
- Focus clavier visible sur le web.
- Ordre de lecture logique et compatible lecteur d'écran.
- Libellé persistant pour chaque champ.
- Texte alternatif pour les images utiles ; logo annoncé comme `Fusy`.
- Statut jamais transmis uniquement par couleur.
- Erreur annoncée et liée au champ concerné.
- Modal avec focus piégé et retour du focus à la fermeture.
- Tableaux navigables au clavier avec en-têtes explicites.
- Minuterie accompagnée d'un libellé textuel et non d'une animation seule.

## Contenu fictif

Utiliser des données camerounaises plausibles sans reprendre de données personnelles réelles. Conserver les mêmes exemples entre les applications afin que les maquettes racontent une transaction cohérente.

## Checklist éditoriale

- Le sujet de l'action est clair.
- Le statut est compréhensible sans connaître les termes internes.
- `FCFA` est visible avec chaque montant critique.
- Le message précise l'absence de débit après blocage ou expiration.
- Le bouton décrit l'action, pas une réponse vague comme `Oui`.
- Les actions irréversibles nomment l'entité concernée.

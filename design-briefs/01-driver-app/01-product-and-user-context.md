# Contexte produit et utilisateur — Chauffeur

## Utilisateur principal

Jean est chauffeur ou agent terrain d'une PME camerounaise. Son compte est créé par son responsable. Il utilise Fusy quelques fois par semaine, souvent debout près d'une pompe, sous forte luminosité et avec un réseau mobile irrégulier.

Il ne gère ni le compte entreprise, ni les stations autorisées. Son besoin est simple : savoir combien il peut dépenser et terminer le passage en station sans ambiguïté.

## Objectifs utilisateur

- Activer son compte sans assistance.
- Voir immédiatement son budget disponible.
- Comprendre si le compte de son entreprise est opérationnel.
- Identifier la bonne station par scan QR.
- Saisir correctement montant et carburant.
- Savoir qui doit agir pendant l'attente.
- Confirmer sans exposer son PIN.
- Retrouver une preuve après le plein.

## Craintes et erreurs probables

- Confondre budget chauffeur et argent personnel.
- Penser qu'une demande en attente est déjà payée.
- Scanner un QR désactivé ou une station non autorisée.
- Saisir un montant supérieur au budget.
- Quitter l'écran pendant l'attente du pompiste.
- Confirmer deux fois sous réseau lent.
- Ne pas comprendre une expiration.
- Refuser la permission caméra par erreur.

## Environnement

- Android bas ou milieu de gamme prioritaire, iPhone supporté.
- Utilisation à une main.
- Soleil, bruit, interruption par le pompiste.
- Données mobiles parfois lentes.
- Clavier numérique nécessaire pour montant, téléphone et PIN.
- Le chauffeur peut être peu familier avec les applications financières.

## Priorités de design

1. Budget et état du compte visibles dès l'accueil.
2. Une action principale : `Scanner une station`.
3. Étapes courtes avec progression claire.
4. Montant et station répétés avant confirmation.
5. Statut textuel et prochaine action toujours visibles.
6. Message rassurant sur l'absence de débit en cas d'échec.

## Permissions

Le chauffeur peut consulter uniquement son budget, ses transactions et ses reçus. Il ne voit pas le solde entreprise exact, les autres chauffeurs, les reversements ou les réglages de l'entreprise.

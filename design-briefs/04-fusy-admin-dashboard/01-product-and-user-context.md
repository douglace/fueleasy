# Contexte produit et utilisateur — Admin Fusy

## Utilisateur

Un opérateur Fusy prépare et exploite le pilote. Il crée les entités après vérification hors plateforme et effectue des opérations qui ont un impact financier ou opérationnel immédiat.

## Objectifs

- Onboarder une entreprise sans intervention technique.
- Créer son administrateur et créditer son compte après preuve.
- Créer une station, générer son QR et rattacher ses pompistes.
- Définir les stations autorisées d'une entreprise.
- Suspendre ou réactiver rapidement une entité.
- Retrouver une transaction et comprendre son état.
- Voir qui a effectué une action sensible.
- Générer puis marquer payé un lot de reversement.

## Risques

- Créditer la mauvaise entreprise ou saisir un montant erroné.
- Désactiver un QR ou une station utilisée sur le terrain.
- Rattacher un pompiste à la mauvaise station.
- Confondre validation de lot et paiement bancaire effectif.
- Exécuter deux fois une action sous réseau lent.
- Perdre le contexte de l'entité en naviguant entre plusieurs écrans.

## Priorités de design

1. En-tête de dossier avec identité et statut global.
2. Actions sensibles séparées et confirmées avec impact.
3. Montants, références, dates et opérateur visibles avant validation.
4. Audit proche du contexte métier.
5. Densité maîtrisée : tableaux efficaces sans texte microscopique.

## Permissions

Le brief suppose un rôle Admin Fusy unique au MVP. Ne pas inventer une matrice complexe de rôles. Les écrans restent strictement internes et ne sont jamais exposés aux entreprises ou pompistes.

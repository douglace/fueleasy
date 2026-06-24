# Contexte produit et utilisateur — Entreprise

## Utilisateurs

### Responsable financier

Veut contrôler l'argent réellement disponible, justifier les dépenses et exporter des données fiables.

### Responsable flotte ou opérations

Veut créer les chauffeurs, attribuer les budgets, suivre les passages en station et suspendre rapidement un accès.

Une même personne peut couvrir les deux rôles au MVP. Le dashboard ne nécessite pas de permissions internes complexes.

## Décisions à soutenir

- Faut-il réalimenter le compte carburant ?
- Quels chauffeurs n'ont plus de budget ou ne sont pas activés ?
- Quelle consommation a eu lieu sur une période ?
- Quelle transaction a été refusée, bloquée ou expirée ?
- Quelles stations sont actuellement autorisées ?
- Quel export fournir à la comptabilité ?

## Risques de compréhension

- Croire que les budgets réservés diminuent le solde entreprise.
- S'inquiéter lorsque la somme des budgets dépasse le solde.
- Confondre un chauffeur invité avec un chauffeur actif.
- Interpréter une demande refusée comme une dépense.
- Chercher à modifier directement les stations autorisées alors que Fusy les gère au MVP.

## Priorités de design

1. Solde réel dominant et explicite.
2. Distinction visuelle entre argent et autorisations.
3. Actions courantes accessibles : créer chauffeur, attribuer budget, voir transactions.
4. Tableaux filtrables sans surcharge analytique.
5. Alertes actionnables, pas seulement des chiffres rouges.

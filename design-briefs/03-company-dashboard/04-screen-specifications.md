# Spécifications des écrans — Entreprise

## 1. Connexion

Email ou téléphone selon implémentation, mot de passe/PIN selon auth retenue, récupération et erreurs. Ne pas proposer d'inscription publique.

## 2. Vue d'ensemble

Solde réel `1 850 000 FCFA`, état, consommation, chauffeurs actifs, budgets configurés, alertes et transactions récentes. Ajouter une aide concise expliquant solde versus budgets.

## 3. Liste Chauffeurs

Recherche, filtres de statut et mode budget, colonnes nom, téléphone masqué, activation, budget disponible, mode, champ libre et actions. États chargement, vide, erreur et pagination.

## 4. Création Chauffeur

Formulaire en sections courtes : identité, budget, information libre. Validation en ligne, rappel que le chauffeur choisira son PIN.

## 5. Détail Chauffeur

En-tête identité/statut, budget, activation, consommation récente et historique. Actions modifier, relancer, suspendre/réactiver.

## 6. Budget Chauffeur

Sélecteur de mode, montant, explication du reset, budget disponible actuel et date d'effet. Message informatif en cas de sur-allocation.

## 7. Activation et suspension

Modales ciblées avec nom de la personne, impact et libellés d'action explicites. Ne jamais afficher ou définir son PIN.

## 8. Stations autorisées

Liste/cartes sobres avec nom, zone et statut. Lecture seule. État vide avec instruction de contacter Fusy, sans bouton `Ajouter une station`.

## 9. Transactions

Filtres visibles, total consommé filtré, tableau date, chauffeur, station, carburant, montant, statut, code et reçu. Colonnes configurables non nécessaires au MVP.

## 10. Détail et reçu

Chronologie de statut, acteurs, montant, carburant, date, code et ID. Reçu final uniquement pour `Terminée`.

## 11. Export

Choix CSV/PDF, rappel des filtres actifs, état de génération, succès et échec. L'export n'est pas un rapport avancé.

## 12. Rapports simples

Filtres partagés, indicateurs total consommé, nombre, bloquées, expirées, puis répartitions simples par chauffeur et station. Préférer tableaux et barres sobres ; pas de dashboard BI complexe.

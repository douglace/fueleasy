# Fondations produit Fusy

## Résumé

Fusy aide les entreprises camerounaises à remplacer les bons carburant papier et les avances cash par un compte carburant prépayé, des budgets attribués aux chauffeurs, une liste de stations autorisées et une double validation digitale à la pompe.

Le MVP est B2B et fermé. Fusy crée les entreprises et les stations après accord commercial. Il ne s'agit pas d'un wallet grand public.

## Problème résolu

Les entreprises gèrent aujourd'hui de nombreuses dépenses carburant avec du cash, des bons papier et des justificatifs incomplets. Elles manquent de contrôle avant la dépense et de preuve exploitable après le passage en station.

Fusy doit rendre chaque dépense :

- autorisée avant exécution ;
- limitée par le budget du chauffeur et le solde réel de l'entreprise ;
- rattachée à une entreprise, un chauffeur, une station et un pompiste ;
- confirmée par deux personnes ;
- historisée avec un reçu.

## Acteurs et responsabilités

| Acteur | Responsabilité dans le MVP |
|---|---|
| Admin Fusy | Crée les entreprises, stations et pompistes, crédite les comptes, autorise les stations et supervise les transactions. |
| Admin entreprise | Crée les chauffeurs, attribue les budgets et consulte les dépenses. |
| Chauffeur | Scanne la station, saisit le montant et confirme la transaction avec son PIN. |
| Pompiste | Vérifie la demande puis la valide ou la refuse sans modifier son contenu. |

## Modèle financier visible dans l'interface

### Solde du compte carburant

Le solde entreprise représente l'argent réellement disponible. Il est alimenté manuellement par Fusy après réception et vérification d'un dépôt, virement ou transfert effectué hors plateforme.

### Budget chauffeur

Le budget chauffeur est une autorisation individuelle de dépense. Il ne crée pas et ne réserve pas d'argent.

Modes :

- manuel ;
- hebdomadaire ;
- mensuel.

Un renouvellement hebdomadaire ou mensuel remplace le reliquat. Il ne l'additionne pas. La somme des budgets chauffeurs peut dépasser le solde entreprise : c'est la sur-allocation autorisée.

Une transaction n'est possible que si le budget chauffeur et le solde entreprise couvrent tous les deux le montant.

## Stations autorisées

Chaque entreprise possède une liste unique de stations autorisées, commune à tous ses chauffeurs. Cette liste est configurée par Admin Fusy. Au MVP, il n'existe ni règle par chauffeur, ni horaire, ni zone GPS.

## QR fixe station

Chaque station dispose d'un QR fixe imprimé. Il identifie la station avec un token non devinable et ne contient aucun montant. L'app Chauffeur affiche le nom de la station après lecture et vérifie immédiatement son autorisation.

## Parcours transactionnel nominal

```mermaid
sequenceDiagram
    participant C as Chauffeur
    participant F as Fusy
    participant P as Pompiste
    C->>F: Scanne le QR station
    F-->>C: Confirme la station autorisée
    C->>F: Saisit montant et carburant
    F->>F: Vérifie statuts, budget et solde
    F-->>P: Crée une demande valable 5 minutes
    P->>F: Valide la demande
    F-->>C: Demande la confirmation PIN
    C->>F: Confirme avec son PIN
    F->>F: Débite atomiquement solde et budget
    F-->>C: Génère le reçu
    F-->>P: Confirme la transaction terminée
```

Le pompiste ne modifie jamais le montant ou le type de carburant. S'il constate une erreur, il refuse et le chauffeur recommence.

## États de transaction

| État métier | Libellé utilisateur | Sens |
|---|---|---|
| `pending_attendant_validation` | En attente du pompiste | Demande créée, aucune validation encore. |
| `attendant_approved` | À confirmer | Le pompiste a validé, le chauffeur doit saisir son PIN. |
| `completed` | Terminée | Double validation obtenue, débits effectués, reçu généré. |
| `rejected` | Refusée | Le pompiste a refusé, aucun débit. |
| `expired` | Expirée | Le délai de cinq minutes est dépassé, aucun débit. |
| `cancelled` | Annulée | Demande arrêtée avant finalisation, aucun débit. |
| `blocked` | Bloquée | Une vérification préalable a échoué, aucune transaction financière créée. |

## Vérifications avant création

- entreprise active ;
- chauffeur actif ;
- station active ;
- QR actif ;
- station autorisée pour l'entreprise ;
- montant strictement positif ;
- type de carburant valide ;
- budget chauffeur suffisant ;
- solde entreprise suffisant.

## Expiration

La fenêtre totale est de cinq minutes après création. L'expiration peut survenir avant la validation du pompiste ou après cette validation, avant le PIN chauffeur. Aucun débit n'a lieu dans les deux cas.

## Reçu MVP

Le reçu contient entreprise, chauffeur, station, pompiste, montant, carburant, date et heure, identifiant de transaction, statut et code court.

## Principes de conception

- Montrer qui doit agir maintenant.
- Expliquer clairement pourquoi une action est bloquée.
- Distinguer autorisation de dépense et argent réellement disponible.
- Montrer le délai sans créer de panique inutile.
- Ne jamais présenter une validation pompiste comme une transaction déjà payée.
- Donner une preuve exploitable après chaque transaction terminée.

## Hors périmètre

Wallet B2C, inscription publique, Mobile Money automatisé, microcrédit, carte des stations, promotions, KYC self-service, géolocalisation, départements, règles horaires, approbations multi-niveaux, gestion avancée des véhicules et BI avancée.

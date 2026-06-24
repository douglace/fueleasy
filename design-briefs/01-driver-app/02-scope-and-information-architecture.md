# Périmètre et architecture — Chauffeur

## Fonctions MVP

- Activation avec téléphone et code.
- Création puis utilisation d'un PIN à quatre chiffres.
- Connexion par téléphone et PIN.
- Budget disponible et statut du compte entreprise.
- Scan du QR fixe d'une station.
- Vérification de la station autorisée.
- Saisie du montant et du type de carburant.
- Champ libre véhicule, plaque ou mission lorsqu'il est demandé.
- Création d'une demande valable cinq minutes.
- Attente de la décision du pompiste.
- Confirmation finale avec PIN.
- Historique personnel et reçus.

## Hors périmètre

Recharge, Mobile Money, wallet personnel, microcrédit, promotions, carte des stations, itinéraire, prix du carburant, gestion d'entreprise, gestion structurée des véhicules, push FCM et modification du numéro de téléphone.

## Navigation principale après connexion

```text
Accueil
├── Scanner une station
│   ├── Station reconnue
│   ├── Détails de la demande
│   ├── Attente pompiste
│   ├── Confirmation PIN
│   └── Reçu
├── Historique
│   └── Détail transaction / reçu
└── Profil
    ├── Identité et entreprise en lecture
    ├── Aide courte
    └── Déconnexion
```

Navigation inférieure recommandée : `Accueil`, `Historique`, `Profil`. Le scan reste l'action dominante de l'accueil, pas une quatrième destination abstraite.

## Architecture de l'activation

```text
Téléphone → Code d'activation → Créer le PIN → Confirmer le PIN → Accueil
```

Au retour, le chauffeur utilise `Téléphone → PIN`. Le code d'activation ne doit pas ressembler à un écran d'inscription publique.

## Hiérarchie de l'accueil

1. Salutation, nom et entreprise.
2. Budget disponible en grand.
3. État opérationnel ou blocage du compte entreprise.
4. Bouton `Scanner une station`.
5. Dernière transaction ou dernier reçu.
6. Aide contextuelle discrète.

## Règles de retour

- Avant création de la demande : retour possible sans conséquence.
- Après création : demander confirmation avant annulation.
- Après validation pompiste : retour ne doit pas perdre l'étape de confirmation PIN.
- Une demande active doit être restaurée après fermeture ou reprise de l'app.

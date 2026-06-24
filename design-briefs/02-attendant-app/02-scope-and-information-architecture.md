# Périmètre et architecture — Pompiste

## Fonctions MVP

- Connexion téléphone et PIN.
- Affichage de la station rattachée.
- Liste des demandes en attente.
- Recherche par code court.
- Détail en lecture seule.
- Validation ou refus.
- Suivi de la confirmation chauffeur.
- Historique du jour et total indicatif.
- État réseau simple.

## Hors périmètre

Création de compte, changement de station, modification montant/carburant, encaissement, stock carburant, prix à la pompe, reversement, reporting multi-stations, QR scanner, géolocalisation et gestion d'entreprise.

## Navigation

Navigation inférieure recommandée : `En attente`, `Historique`, `Profil`.

```text
Connexion
└── En attente
    ├── Recherche code
    └── Détail demande
        ├── Valider → Attente chauffeur → Terminée/Expirée
        └── Refuser → Confirmation → Refusée
Historique
└── Détail transaction
Profil
└── Station, identité, déconnexion
```

L'écran `En attente` est toujours la destination après connexion. Une demande active doit se mettre à jour sans rechargement manuel lorsque possible.

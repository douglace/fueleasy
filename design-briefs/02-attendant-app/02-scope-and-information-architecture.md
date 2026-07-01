# Périmètre et architecture — Pompiste

## Fonctions MVP

- Connexion téléphone et PIN.
- Ouverture et fermeture d'une session de travail sur une pompe.
- Affichage de la station rattachée et du QR de la pompe en service.
- Liste des paiements effectués du jour pour la station.
- Accusé de réception d'un nouveau paiement.
- Recherche d'un paiement par code court.
- Détail en lecture seule.
- Historique du jour et total indicatif.
- État réseau simple.

## Hors périmètre

Validation ou refus d'une transaction, modification montant/carburant, création de compte, changement de station, encaissement, stock carburant, prix à la pompe, reversement, reporting multi-stations, scan QR, géolocalisation et gestion d'entreprise.

## Navigation

Navigation inférieure recommandée : `Paiements`, `Historique`, `Profil`.

```text
Connexion
└── Session de travail (choisir la pompe → QR de la pompe)
    └── Paiements du jour
        ├── Recherche code
        └── Détail paiement (lecture seule)
            └── Accuser réception → Accusé
Historique
└── Détail transaction
Profil
└── Station, session en cours, identité, fermer la session, déconnexion
```

L'écran `Paiements du jour` est la destination après ouverture de la session. La liste se met à jour sans rechargement manuel lorsque possible, et un nouveau paiement y apparaît en tête, marqué `À accuser`.

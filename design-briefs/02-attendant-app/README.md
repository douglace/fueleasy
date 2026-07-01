# App Pompiste Fusy — Brief de conception

## Mission

Permettre à un pompiste de **consulter les paiements effectués** de sa station,
de les retrouver par leur code court, et d'**accuser réception** d'un nouveau
paiement afin de servir le carburant. Le pompiste **ne valide, ne refuse ni ne
modifie jamais** une transaction : au moment où un paiement apparaît, il est déjà
réglé par le PIN du chauffeur.

## Plateforme

Flutter Android prioritaire. Usage debout, en station, au soleil, avec
interruptions fréquentes et réseau irrégulier.

## Ordre de lecture

Lire les quatre documents de [`../00-shared`](../00-shared/), puis les fichiers
numérotés de ce dossier et terminer par [`CLAUDE-DESIGN-PROMPT.md`](CLAUDE-DESIGN-PROMPT.md).

## Résultat attendu

Une app Android minimaliste couvrant connexion, ouverture/fermeture d'une session
de travail sur une pompe, liste des paiements du jour, accusé de réception,
recherche par code court, détail en lecture seule et historique du jour.

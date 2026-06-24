# Responsive, accessibilité et qualité — Chauffeur

## Viewports de conception

- Référence Android compacte : 360 × 800 px.
- Référence Android courante : 390 × 844 px.
- Référence iPhone : 393 × 852 px.
- Support minimal : largeur 320 px sans contenu tronqué.

## Règles de mise en page

- Une colonne, marge 16 px.
- Zone sûre respectée autour des encoches et barres système.
- Action principale accessible au pouce et non masquée par le clavier.
- Contenu essentiel visible en taille de texte système augmentée.
- Aucun tableau horizontal dans l'app.
- Montant et code ne se coupent pas sur deux lignes.

## Accessibilité

- Cibles de 48 × 48 px.
- Scanner avec instruction accessible au lecteur d'écran.
- PIN annoncé comme quatre positions sans lire les valeurs.
- Minuterie annoncée à intervalles raisonnables, pas chaque seconde.
- Focus déplacé vers le titre lors d'un changement d'étape.
- Erreurs liées aux champs et annoncées.
- Vibration jamais seule pour signaler une lecture ou un échec.

## Conditions terrain à montrer dans les maquettes

- permission caméra refusée ;
- réseau instable pendant l'attente ;
- texte long sur largeur 320 px ;
- clavier numérique ouvert ;
- moins d'une minute avant expiration ;
- app reprise avec demande active ;
- bouton de confirmation en chargement.

## Checklist visuelle

- Manrope uniquement.
- Bleu `#003362` comme action principale.
- Une seule action dominante par écran.
- `FCFA` visible avec les montants critiques.
- Station, montant et carburant répétés avant le PIN.
- Aucun dégradé décoratif.
- Aucun faux wallet ou action `Recharger`.
- Le vert indique succès/progression sans remplacer le texte.
- Le reçu final est clairement distinct d'une demande en attente.

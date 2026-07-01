# Marque et système UI Fusy

## Direction

La direction validée est **Clarté opérationnelle + Manrope**. Elle doit être sérieuse sans froideur, rassurante pour la finance et suffisamment directe pour un usage en station.

## Logo

Le logo combine un `F` géométrique, une flèche de progression et les couleurs bleu/vert. Ne pas redessiner, déformer, recolorer ou ajouter un effet au logo.

Sur fond clair, utiliser le logo principal. La zone de protection minimale correspond approximativement à la hauteur du jambage du `F`. Ne pas placer le logo dans une carte dense ou à proximité immédiate d'une autre marque.

Les sources disponibles sont des PNG aplatis, pas des SVG. Voir [assets-index.md](assets-index.md).

## Typographie

Famille unique : **Manrope**.

| Style | Taille / ligne | Poids | Usage |
|---|---:|---:|---|
| Display | 32 / 40 px | 700 | Solde ou montant principal |
| Titre 1 | 28 / 36 px | 700 | Titre d'écran |
| Titre 2 | 22 / 30 px | 700 | Section majeure |
| Titre 3 | 18 / 26 px | 600 | Carte ou sous-section |
| Corps large | 16 / 24 px | 400 | Message important mobile |
| Corps | 14 / 22 px | 400 | Contenu et tableaux |
| Libellé | 12 / 16 px | 600 | Champ, badge, navigation |
| Légende | 11 / 16 px | 500 | Métadonnée non critique |

Utiliser les chiffres tabulaires pour montants, dates, codes et colonnes numériques. Ne pas descendre sous 14 px pour une information critique.

## Palette

### Marque et neutres

| Token | Valeur | Usage |
|---|---|---|
| `brand.navy` | `#003362` | Bouton principal, navigation active |
| `brand.green` | `#00B473` | Accent et progression |
| `brand.greenDark` | `#007A4F` | Texte de succès |
| `neutral.900` | `#172B3A` | Texte principal |
| `neutral.700` | `#465B69` | Texte secondaire fort |
| `neutral.600` | `#5E6D78` | Texte secondaire |
| `neutral.500` | `#71808C` | Aide et métadonnée |
| `neutral.300` | `#9EAFBC` | Bordure forte |
| `neutral.200` | `#DCE4EA` | Bordure courante |
| `neutral.100` | `#EDF1F4` | Séparateur léger |
| `neutral.50` | `#F6F8FA` | Fond global |
| `white` | `#FFFFFF` | Surface |

### États

| État | Texte | Fond |
|---|---|---|
| Succès | `#007A4F` | `#E5F7EF` |
| Information | `#00598F` | `#E8F2F9` |
| Avertissement | `#915600` | `#FFF3DA` |
| Erreur | `#A52E2E` | `#FDECEC` |
| Destructif | `#C53939` | `#FDECEC` |

Le vert vif ne sert pas de petit texte sur blanc. Un état combine toujours couleur et libellé.

## Espacement et formes

Grille : `4`, `8`, `12`, `16`, `24`, `32`, `48`, `64` px.

- champs et boutons : rayon 8 px ;
- cartes : rayon 12 px ;
- modales : rayon 16 px ;
- feuilles mobiles : rayon supérieur 24 px ;
- bordure courante : 1 px `#DCE4EA` ;
- ombres réservées aux éléments flottants.

## Composants

### Boutons

- Principal : fond bleu, texte blanc, une seule action dominante par zone.
- Secondaire : fond blanc, bordure, texte bleu.
- Discret : texte bleu sans forte surface.
- Destructif : rouge, séparé des actions de validation.
- États obligatoires : normal, pressé, focus, chargement, désactivé.

### Champs

Libellé persistant, aide sous le contrôle, erreur près du champ. Le placeholder ne remplace pas le libellé. Montants et PIN ouvrent un clavier adapté.

### Cartes

Les cartes regroupent une seule idée. Préférer bordure et espace blanc aux ombres. Un montant principal possède un libellé explicite et `FCFA` visible.

### Statuts

Badges textuels courts alignés sur les états réels : `À confirmer` (pending), `Payée` (paid), `Expirée`, `Échouée`, `Remboursée`, plus `Bloquée` pour un échec de vérification avant création. Côté pompiste : `À accuser` / `Accusé`. Aucun badge de validation ou de refus pompiste.

### Iconographie

Icônes linéaires arrondies, trait optique de 2 px. Tailles : 20 px dans les contrôles, 24 px en navigation, 32 px en confirmation. Une icône ne remplace jamais le texte d'une action critique.

## Mobile terrain

- marge écran : 16 px ;
- cible tactile : 48 px minimum ;
- bouton principal : 48 à 52 px ;
- une action essentielle visible sans défilement lorsque possible ;
- navigation de trois à cinq destinations ;
- confirmation plein écran pour succès ou blocage critique.

## Dashboards

- navigation latérale sur grand écran ;
- grille de 12 colonnes ;
- marge de page : 24 à 32 px ;
- ligne de tableau : 48 px ;
- filtres visibles avant les données ;
- actions sensibles confirmées dans une modale ;
- état global visible dans l'en-tête du dossier.

## À éviter

Gradients décoratifs, glassmorphism, grandes ombres, cartes imbriquées, vert utilisé comme bouton principal partout, icônes seules pour les actions critiques, illustrations génériques de voitures, pompes ou billets.

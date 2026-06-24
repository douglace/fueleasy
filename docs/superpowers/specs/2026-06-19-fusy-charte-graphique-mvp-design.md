# Fusy — Charte graphique MVP

Date : 2026-06-19  
Statut : validée en cadrage visuel  
Périmètre : apps Chauffeur et Pompiste, dashboards Entreprise et Admin Fusy  
Thème : clair uniquement

## 1. Objectif

La charte doit donner aux quatre interfaces un langage commun immédiatement identifiable, lisible sur le terrain et crédible auprès des entreprises.

La direction retenue combine :

- la structure **Clarté opérationnelle** ;
- la police **Manrope** pour une expression plus ronde et accessible ;
- le bleu du logo pour la confiance et les actions principales ;
- le vert du logo pour la progression, la validation et les accents.

Le MVP privilégie la lisibilité, la cohérence et la vitesse d'implémentation. Il n'inclut ni thème sombre, ni illustrations de marque, ni animations complexes.

## 2. Sources de marque

Les fichiers existants dans `assets/` restent les sources raster du logo :

- `assets/logo-primary.png` ;
- `assets/primary-logo.png` ;
- `assets/logo-monochrome.png` ;
- `assets/logo-monochrome-noire.png` ;
- `assets/app-icon.png` ;
- `assets/app-icon-1.png`.

Ces fichiers sont des PNG RGB aplatis, sans transparence. Ils ne doivent pas être présentés comme des originaux vectoriels. La charte documentera cette limite et préservera les fichiers sans altérer le dessin du logo. Une vectorisation fidèle pourra faire l'objet d'un travail séparé à partir du fichier source du créateur du logo.

## 3. Couleurs

### 3.1 Couleurs de marque

| Token | Valeur | Usage |
|---|---|---|
| `brand.navy` | `#003362` | Action principale, navigation active, éléments de confiance |
| `brand.green` | `#00B473` | Accent, progression, confirmation visuelle |
| `brand.greenDark` | `#007A4F` | Texte de succès et éléments verts nécessitant plus de contraste |
| `brand.navySoft` | `#E8F2F9` | Fond d'information et sélection légère |
| `brand.greenSoft` | `#E5F7EF` | Fond de succès et mise en valeur positive |

Le vert vif ne porte pas de petit texte sur fond blanc. Les boutons principaux utilisent le bleu Fusy avec un libellé blanc.

### 3.2 Neutres

| Token | Valeur | Usage |
|---|---|---|
| `neutral.900` | `#172B3A` | Texte principal |
| `neutral.700` | `#465B69` | Texte secondaire fort |
| `neutral.600` | `#5E6D78` | Texte secondaire |
| `neutral.500` | `#71808C` | Aide et métadonnées |
| `neutral.300` | `#9EAFBC` | Contrôle inactif et bordure forte |
| `neutral.200` | `#DCE4EA` | Bordures et séparateurs |
| `neutral.100` | `#EDF1F4` | Séparateurs légers |
| `neutral.50` | `#F6F8FA` | Fond global de l'application |
| `white` | `#FFFFFF` | Surfaces et texte inversé |

### 3.3 Couleurs sémantiques

| État | Premier plan | Fond | Usage |
|---|---|---|---|
| Succès | `#007A4F` | `#E5F7EF` | Transaction validée, action réussie |
| Information | `#00598F` | `#E8F2F9` | En attente, information contextuelle |
| Avertissement | `#915600` | `#FFF3DA` | Expiration, solde bas, action requise |
| Erreur | `#A52E2E` | `#FDECEC` | Refus, échec, blocage |
| Destructif | `#C53939` | `#FDECEC` | Suspension et action irréversible |

Un statut associe toujours couleur, texte explicite et, lorsque pertinent, une icône. La couleur seule ne transmet jamais l'information.

## 4. Typographie

Manrope est l'unique famille typographique du MVP. Les graisses utilisées sont 400, 500, 600 et 700. La graisse 800 est réservée à des usages de marque exceptionnels et ne fait pas partie des composants courants.

| Style | Taille / ligne | Graisse | Usage |
|---|---:|---:|---|
| Display | 32 / 40 px | 700 | Solde, montant principal, succès final |
| Titre 1 | 28 / 36 px | 700 | Titre principal d'écran |
| Titre 2 | 22 / 30 px | 700 | Section majeure |
| Titre 3 | 18 / 26 px | 600 | Carte ou sous-section |
| Corps large | 16 / 24 px | 400 | Message important et lecture mobile |
| Corps | 14 / 22 px | 400 | Texte courant et tableaux |
| Libellé | 12 / 16 px | 600 | Champs, badges et navigation secondaire |
| Légende | 11 / 16 px | 500 | Métadonnées non critiques |

Les montants, identifiants, dates et colonnes numériques utilisent les chiffres tabulaires via `font-variant-numeric: tabular-nums` sur le web et l'équivalent Flutter.

## 5. Espacement, dimensions et formes

La grille d'espacement repose sur 4 px : `4`, `8`, `12`, `16`, `24`, `32`, `48` et `64`.

| Élément | Règle |
|---|---|
| Champ et bouton | Rayon 8 px |
| Carte | Rayon 12 px |
| Modal | Rayon 16 px |
| Feuille mobile | Rayon supérieur 24 px |
| Cible tactile mobile | 48 px minimum |
| Bouton mobile principal | 48 à 52 px de hauteur |
| Ligne de tableau | 48 px par défaut |
| Bordure courante | 1 px, `neutral.200` |

Les ombres restent rares. Une bordure suffit pour la majorité des cartes. Les élévations servent uniquement aux modales, menus flottants et feuilles mobiles.

## 6. Composants MVP

La bibliothèque visuelle couvre au minimum :

- boutons principal, secondaire, discret et destructif ;
- états normal, pressé, focus, chargement, désactivé et erreur ;
- champs texte, téléphone, PIN, montant, recherche et sélection ;
- badges de statut avec libellé ;
- alertes success, info, warning et error ;
- cartes de solde, budget, transaction, chauffeur et station ;
- lignes de transaction et tableaux ;
- pagination, filtres, recherche et état vide ;
- modal de confirmation et feuille mobile ;
- navigation mobile et navigation latérale web ;
- retour utilisateur pour chargement, absence de réseau, expiration et permission refusée.

Une zone ne présente qu'une seule action principale bleue. Une action destructive est visuellement séparée des actions de validation et demande confirmation.

## 7. Iconographie

Le style d'icône est linéaire et arrondi, avec un trait optique constant de 2 px. Les tailles principales sont 20 px dans les contrôles, 24 px dans la navigation et 32 px dans les confirmations.

Une icône accompagne un libellé pour les actions critiques. Elle ne remplace pas le texte pour valider, refuser, suspendre ou confirmer une transaction. Les pictogrammes propriétaires ou ambigus sont exclus du MVP.

## 8. Règles par interface

### 8.1 Apps Chauffeur et Pompiste

- marge d'écran de 16 px ;
- action principale visible sans défilement lorsque le contexte le permet ;
- boutons et champs de 48 à 52 px ;
- navigation limitée à trois à cinq destinations ;
- contenu prioritaire utilisable d'une seule main ;
- confirmation plein écran pour un succès, un refus ou un blocage critique ;
- messages simples, directs et compréhensibles sans vocabulaire bancaire complexe.

### 8.2 Dashboard Entreprise

- navigation latérale persistante sur écran large ;
- contenu sur grille de 12 colonnes ;
- marge de page de 24 à 32 px ;
- cartes KPI avec rayon de 12 px ;
- lignes de tableau de 48 px ;
- filtres visibles au-dessus des données ;
- exports et actions secondaires regroupés sans concurrencer l'action principale.

### 8.3 Dashboard Admin Fusy

- densité supérieure au dashboard Entreprise sans texte inférieur à 14 px pour les données critiques ;
- actions sensibles isolées et confirmées ;
- identifiants, montants et horodatages en chiffres tabulaires ;
- état global d'une entreprise, station, personne ou transaction visible dans son en-tête ;
- historique d'audit lisible sans dépendre uniquement d'un code couleur.

## 9. Accessibilité et robustesse terrain

- contraste WCAG AA pour le texte et les contrôles essentiels ;
- focus visible sur chaque contrôle web interactif ;
- cible tactile de 48 px minimum sur mobile ;
- messages d'erreur placés près du champ concerné ;
- libellés persistants : le placeholder n'est pas un label ;
- états réseau et chargement explicites ;
- aucune information portée uniquement par la couleur ;
- montants affichés avec séparateur de milliers et suffixe `FCFA` ;
- interfaces vérifiées sur petits écrans Android et sur desktop à partir de 1280 px.

## 10. Livrables à produire dans `assets/`

L'implémentation créera une structure non destructive :

```text
assets/
├── README.md
├── brand/
│   ├── sources/
│   └── usage.md
├── fonts/
│   └── manrope/
│       ├── Manrope-VariableFont_wght.ttf
│       └── OFL.txt
├── tokens/
│   ├── fusy.tokens.json
│   ├── fusy-theme.css
│   └── fusy_theme.dart
├── guidelines/
│   └── charte-graphique-mvp.md
└── previews/
    └── fusy-ui-foundations.png
```

Les PNG existants restent à leur emplacement actuel pour ne casser aucune référence future. `brand/sources/` recevra des copies clairement nommées, pas des remplacements silencieux.

Les trois fichiers de tokens doivent exprimer les mêmes valeurs :

- JSON comme source neutre lisible par les outils ;
- CSS pour les dashboards web ;
- Dart pour les apps Flutter.

## 11. Vérification

La livraison est considérée conforme lorsque :

1. chaque couleur, taille, graisse, espacement et rayon est identique dans les trois formats de tokens ;
2. Manrope est incluse avec sa licence et ses graisses variables ;
3. la documentation explique les usages corrects et interdits du logo ;
4. l'aperçu visuel utilise les tokens livrés ;
5. les contrastes des textes et boutons critiques respectent WCAG AA ;
6. les fichiers existants du logo n'ont pas été modifiés ;
7. aucun thème sombre, composant hors MVP ou illustration supplémentaire n'est introduit.

## 12. Hors périmètre

- vectorisation ou redessin du logo ;
- création d'un nouveau symbole ou d'une nouvelle palette ;
- thème sombre ;
- design complet des écrans métier ;
- bibliothèque de composants codée et interactive ;
- supports marketing, réseaux sociaux ou présentation commerciale.

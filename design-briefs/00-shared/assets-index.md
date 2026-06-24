# Index des assets Fusy

## Logos disponibles

Les chemins sont relatifs à la racine du projet.

| Fichier | Dimensions | Usage prévu | Limite |
|---|---:|---|---|
| `assets/primary-logo.png` | 986 × 368 | Logo horizontal principal | Fond aplati, pas de transparence |
| `assets/logo-primary.png` | 1672 × 941 | Source raster haute définition | Grandes marges blanches |
| `assets/logo-monochrome.png` | 1448 × 1086 | Version bleu monochrome | Fond aplati |
| `assets/logo-monochrome-noire.png` | 1448 × 1086 | Impression monochrome noire | Fond aplati |
| `assets/app-icon.png` | 1254 × 1254 | Référence de l'icône d'app | Export RGB, extérieur noir à retraiter avant production |
| `assets/app-icon-1.png` | 1254 × 1254 | Doublon de référence | Même limite que `app-icon.png` |

Ces fichiers ne sont pas des originaux vectoriels. Claude Design doit les placer sans les redessiner. Il ne doit pas inventer une version SVG, une nouvelle flèche ou une nouvelle géométrie.

## Charte et spécifications

- Charte validée : `docs/superpowers/specs/2026-06-19-fusy-charte-graphique-mvp-design.md`
- Structure des briefs : `docs/superpowers/specs/2026-06-19-fusy-claude-design-briefs-design.md`
- Système UI synthétique : [`brand-and-ui-system.md`](brand-and-ui-system.md)

## Police

Police cible : Manrope Variable, graisses 400 à 700. Si le fichier local n'est pas encore fourni, Claude Design doit utiliser Manrope depuis sa bibliothèque sans la remplacer par une autre famille.

## Tokens de référence

Couleurs minimales :

```text
Primary       #003362
Accent        #00B473
Success text  #007A4F
Text          #172B3A
Background    #F6F8FA
Surface       #FFFFFF
Border        #DCE4EA
Warning text  #915600
Error text    #A52E2E
```

## Règles de transmission à Claude Design

Pour une génération, joindre de préférence :

1. `assets/primary-logo.png` ;
2. les quatre documents de `design-briefs/00-shared/` ;
3. tous les documents du dossier applicatif ;
4. le prompt applicatif en dernier.

Ne pas joindre `CDC_FINAL.md` en même temps : il contient des orientations historiques hors MVP susceptibles de provoquer l'ajout de fonctionnalités interdites.

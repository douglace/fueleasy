# Bundle design — fichier unique pour Claude Design / Open Design

L'application mobile Fusy est **une seule app Flutter** dont l'interface dépend du rôle
du compte (Chauffeur ou Pompiste). Le brief complet tient donc dans **un seul fichier**.

## Le fichier à envoyer

➡️ **[`app-mobile-fusy-COMPLET.md`](app-mobile-fusy-COMPLET.md)**

Il contient, dans l'ordre : fondations partagées (produit, marque + tokens,
accessibilité, assets) → Partie A Chauffeur → Partie B Pompiste → prompt unifié.

## Mode d'emploi

1. Joindre le **logo** `assets/primary-logo.png` (à placer tel quel, ne pas le redessiner).
2. Fournir **`app-mobile-fusy-COMPLET.md`** comme contexte principal.
3. Police cible : **Manrope** (400–700). Si l'outil ne l'a pas en local, le laisser la charger depuis sa bibliothèque.
4. **Ne pas** joindre `CDC_FINAL.md` (orientations hors MVP → risque de dérive fonctionnelle).

### Claude Design
Fournir logo + fichier complet, lancer. La section « 4. Prompt unifié » sert d'instruction principale.

### Open Design (ou autre outil IA)
Mêmes contenus valables. Copier la section « 4. Prompt unifié » dans le champ prompt de
l'outil, et joindre le fichier complet comme contexte, sans modifier les contraintes
(tokens, écrans, états, périmètre MVP).

## Source de vérité & régénération

Le fichier complet est **dérivé** des briefs individuels de `design-briefs/`
(`00-shared/`, `01-driver-app/`, `02-attendant-app/`). En cas de modification d'un brief,
régénérer le fichier complet. La **source de vérité** reste les fichiers individuels.

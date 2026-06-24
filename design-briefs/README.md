# Fusy — Dossiers de conception MVP B2B

Ce répertoire contient les briefs à donner à Claude Design pour concevoir les quatre interfaces du MVP Fusy.

## Mode d'emploi

Pour une interface donnée, fournir à Claude Design :

1. les quatre documents de [`00-shared`](00-shared/) ;
2. tout le dossier de l'interface concernée ;
3. les fichiers de logo indiqués dans [`00-shared/assets-index.md`](00-shared/assets-index.md) ;
4. le contenu du fichier `CLAUDE-DESIGN-PROMPT.md` comme instruction principale.

Ne mélangez pas deux dossiers applicatifs dans une même génération. Les rôles, permissions et priorités diffèrent.

## Interfaces

| Interface | Plateforme | Utilisateur | Prompt |
|---|---|---|---|
| [App Chauffeur](01-driver-app/) | Flutter Android + iOS | Chauffeur ou agent terrain | [Prompt](01-driver-app/CLAUDE-DESIGN-PROMPT.md) |
| [App Pompiste](02-attendant-app/) | Flutter Android | Pompiste en station | [Prompt](02-attendant-app/CLAUDE-DESIGN-PROMPT.md) |
| [Dashboard Entreprise](03-company-dashboard/) | Web responsive | Finance, flotte, opérations | [Prompt](03-company-dashboard/CLAUDE-DESIGN-PROMPT.md) |
| [Dashboard Admin Fusy](04-fusy-admin-dashboard/) | Web responsive interne | Opérateur Fusy | [Prompt](04-fusy-admin-dashboard/CLAUDE-DESIGN-PROMPT.md) |

## Références partagées

- [Fondations produit](00-shared/product-foundation.md)
- [Marque et système UI](00-shared/brand-and-ui-system.md)
- [Accessibilité et contenu](00-shared/accessibility-and-content.md)
- [Index des assets](00-shared/assets-index.md)

## Limite de périmètre

Ces briefs décrivent uniquement le MVP B2B fermé : compte carburant prépayé, budgets chauffeurs, stations autorisées et validation digitale à la pompe. Ils n'autorisent pas l'ajout d'un wallet grand public, de Mobile Money automatisé, de microcrédit, de KYC self-service ou d'analytics avancés.

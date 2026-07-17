---
description: Lance le pipeline complet de release Fueleasy via l'agent release-manager (bump versions mobile/platform + PR develop -> main + tags qui déclenchent CI build & deploy).
argument-hint: '[patch|minor|major] [--branch <name>] [--notes <text>]'
---

# /release

Pipeline de release Fueleasy automatisé. Bump les versions, ouvre et merge les PRs,
pousse les tags qui déclenchent les workflows CI (`build-mobile.yml`, `deploy-production.yml`).

## Usage

```
/release                        # patch par défaut (+0.0.1) sur la branche courante
/release patch                  # explicite
/release minor                  # +0.1.0
/release major                  # +1.0.0
/release patch --notes "delivery flow + sync hardening"
/release patch --branch fix/mobile-sync
```

Arguments transmis : `$ARGUMENTS`

## Comportement

Invoque le sous-agent `release-manager` avec les inputs ci-dessous. L'agent exécute le
pipeline en 5 phases (détection -> bump+vérif -> PR develop -> PR main -> tags) avec
arrêts sur erreur.

**Ciblage automatique** : l'agent détecte quels apps ont du code modifié depuis leur
dernier tag (mobile-v*, platform-v*). Seuls les apps modifiés sont bumpés
et taggés. Les autres restent à leur version courante.

Exemple : si depuis la dernière release seul `apps/mobile` a changé, /release ne bumpe
pas platform et ne pousse pas ses tags — économise les crédits CI.

## Inputs déduits

- **Branche source** : argument `--branch` ou branche courante (`git branch --show-current`).
- **Bump** : `patch` (défaut), `minor`, `major`.
- **Notes** : argument `--notes` ou auto-généré depuis `git log --oneline origin/main..HEAD`.

## Pré-requis (vérifiés par l'agent)

- Working tree clean ou diff propre (pas de conflits).
- `gh` authentifié.
- Accès push sur `origin`.
- Versions actuelles lisibles dans les fichiers sources :
  - `apps/mobile/pubspec.yaml`
  - `apps/platform/package.json`

## Effets de bord

- Modifie les fichiers de version.
- Crée 1 commit `chore(release): bump ...` sur la branche source.
- Crée 2 PRs sur GitHub (feature -> develop, develop -> main).
- Crée et push les tags annotés (`mobile-vX.Y.Z`, `platform-vX.Y.Z`).
- Déclenche les workflows CI : Build Mobile, Deploy Production.

## Garde-fous

L'agent stoppe et demande confirmation avant tout :

- bypass de hook (`--no-verify`)
- force push
- rollback / suppression de tag
- commit malgré une vérif en échec

## Référence doc

- `.claude/agents/release-manager.md` (instructions complètes du sous-agent)

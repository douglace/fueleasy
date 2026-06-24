# Fusy Claude Design Briefs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produire un socle partagé et quatre dossiers autonomes permettant à Claude Design de concevoir les interfaces du MVP B2B Fusy sans inventer de fonctionnalités.

**Architecture:** `design-briefs/00-shared` contient les règles produit, marque, contenu et assets qui ne doivent pas diverger. Chaque interface possède ensuite huit documents ciblés et un prompt autonome, avec des exemples de données cohérents entre les quatre rôles.

**Tech Stack:** Markdown, liens relatifs, diagrammes Mermaid simples, tokens documentés depuis la charte Fusy.

## Global Constraints

- Couvrir uniquement le MVP B2B fermé validé.
- Utiliser la direction Clarté opérationnelle et Manrope.
- Concevoir en français avec montants au format `15 000 FCFA`.
- Apps Chauffeur et Pompiste : mobile Flutter, usage terrain, cible tactile minimale de 48 px.
- Dashboards Entreprise et Admin : web desktop responsive.
- Ne pas modifier les PNG de logo existants.
- Ne pas ajouter wallet B2C, Mobile Money automatisé, microcrédit, KYC self-service, géolocalisation, règles horaires, départements, approbation multi-niveau ou analytics avancés.
- Les prompts doivent imposer états nominal, chargement, vide, erreur, hors ligne et permission lorsque pertinent.
- Le dossier courant n'étant pas un dépôt Git, aucune étape de commit n'est applicable.

---

### Task 1: Socle partagé et index

**Files:**
- Create: `design-briefs/README.md`
- Create: `design-briefs/00-shared/product-foundation.md`
- Create: `design-briefs/00-shared/brand-and-ui-system.md`
- Create: `design-briefs/00-shared/accessibility-and-content.md`
- Create: `design-briefs/00-shared/assets-index.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-06-19-fusy-charte-graphique-mvp-design.md`, `docs/superpowers/specs/2026-06-19-fusy-claude-design-briefs-design.md`
- Produces: règles et chemins partagés référencés par les quatre dossiers.

- [ ] **Step 1: Créer l'index général**

Décrire l'ordre de lecture, les quatre interfaces, la règle de combinaison `00-shared + dossier d'application`, et fournir des liens relatifs vers tous les documents.

- [ ] **Step 2: Écrire le modèle produit partagé**

Documenter les acteurs, le solde entreprise, le budget chauffeur, les stations autorisées, le QR fixe, l'expiration de cinq minutes, les deux validations et les sept états transactionnels.

- [ ] **Step 3: Écrire le système visuel partagé**

Reprendre exactement Manrope, `#003362`, `#00B473`, les couleurs sémantiques, la grille de 4 px, les rayons, les composants et les règles propres aux surfaces mobile/web.

- [ ] **Step 4: Écrire les règles de contenu et d'accessibilité**

Définir le ton, les formats, les messages critiques, WCAG AA, cibles tactiles, focus, erreurs, réseau et permissions.

- [ ] **Step 5: Indexer les assets**

Référencer les six PNG existants, la charte et les futures fontes/tokens sans prétendre disposer d'un SVG.

- [ ] **Step 6: Vérifier les liens partagés**

Run: `find design-briefs/00-shared -type f -name '*.md' | sort`

Expected: quatre documents Markdown listés.

### Task 2: Dossier App Chauffeur

**Files:**
- Create: `design-briefs/01-driver-app/README.md`
- Create: `design-briefs/01-driver-app/01-product-and-user-context.md`
- Create: `design-briefs/01-driver-app/02-scope-and-information-architecture.md`
- Create: `design-briefs/01-driver-app/03-user-flows.md`
- Create: `design-briefs/01-driver-app/04-screen-specifications.md`
- Create: `design-briefs/01-driver-app/05-components-states-and-errors.md`
- Create: `design-briefs/01-driver-app/06-content-and-sample-data.md`
- Create: `design-briefs/01-driver-app/07-responsive-accessibility-and-quality.md`
- Create: `design-briefs/01-driver-app/CLAUDE-DESIGN-PROMPT.md`

**Interfaces:**
- Consumes: `design-briefs/00-shared/*`, `plan_mvp/04_SPRINT_04_app_chauffeur.md`, `plan_mvp/06_SPRINT_06_transaction_qr_station.md`
- Produces: brief autonome de l'app Chauffeur Flutter Android/iOS.

- [ ] **Step 1: Décrire utilisateur, environnement et périmètre**

Couvrir activation, PIN, budget, compte entreprise, QR, demande, confirmation, historique et reçus. Exclure recharge, wallet, carte des stations, promotions et gestion d'entreprise.

- [ ] **Step 2: Définir navigation et parcours**

Documenter activation, connexion, paiement nominal, refus, expiration et reçus avec préconditions et branches.

- [ ] **Step 3: Spécifier les seize écrans**

Chaque écran doit contenir objectif, contenu, actions, états, règles visibles et critères UX.

- [ ] **Step 4: Définir composants, messages et données**

Inclure scanner, PIN, montant, carburant, minuterie, statut, reçu, données Cameroun fictives et textes prêts à utiliser.

- [ ] **Step 5: Écrire règles qualité mobile**

Couvrir petits écrans Android, iOS, caméra, réseau instable, clavier numérique, une main et cibles de 48 px.

- [ ] **Step 6: Écrire le prompt Claude Design**

Demander une app mobile haute fidélité avec tous les écrans et états, utilisant strictement le socle partagé et sans fonction hors MVP.

### Task 3: Dossier App Pompiste

**Files:**
- Create: `design-briefs/02-attendant-app/README.md`
- Create: `design-briefs/02-attendant-app/01-product-and-user-context.md`
- Create: `design-briefs/02-attendant-app/02-scope-and-information-architecture.md`
- Create: `design-briefs/02-attendant-app/03-user-flows.md`
- Create: `design-briefs/02-attendant-app/04-screen-specifications.md`
- Create: `design-briefs/02-attendant-app/05-components-states-and-errors.md`
- Create: `design-briefs/02-attendant-app/06-content-and-sample-data.md`
- Create: `design-briefs/02-attendant-app/07-responsive-accessibility-and-quality.md`
- Create: `design-briefs/02-attendant-app/CLAUDE-DESIGN-PROMPT.md`

**Interfaces:**
- Consumes: `design-briefs/00-shared/*`, `plan_mvp/05_SPRINT_05_app_pompiste.md`, `plan_mvp/06_SPRINT_06_transaction_qr_station.md`
- Produces: brief autonome de l'app Pompiste Flutter Android.

- [ ] **Step 1: Décrire le contexte station et la tâche principale**

Mettre en avant rapidité, lecture à distance, bruit, réseau faible, isolation par station et interdiction de modifier montant ou carburant.

- [ ] **Step 2: Définir navigation, parcours et onze écrans**

Couvrir connexion, file d'attente, code court, détail, validation, refus, expiration, attente chauffeur, historique et détail.

- [ ] **Step 3: Définir composants, messages, données et qualité**

Inclure minuterie, mise à jour de file, états réseau, boutons séparés, confirmation, données partagées et petits Android.

- [ ] **Step 4: Écrire le prompt Claude Design**

Demander une app Android minimaliste, rapide, lisible au soleil et complète sur les états transactionnels.

### Task 4: Dossier Dashboard Entreprise

**Files:**
- Create: `design-briefs/03-company-dashboard/README.md`
- Create: `design-briefs/03-company-dashboard/01-product-and-user-context.md`
- Create: `design-briefs/03-company-dashboard/02-scope-and-information-architecture.md`
- Create: `design-briefs/03-company-dashboard/03-user-flows.md`
- Create: `design-briefs/03-company-dashboard/04-screen-specifications.md`
- Create: `design-briefs/03-company-dashboard/05-components-states-and-errors.md`
- Create: `design-briefs/03-company-dashboard/06-content-and-sample-data.md`
- Create: `design-briefs/03-company-dashboard/07-responsive-accessibility-and-quality.md`
- Create: `design-briefs/03-company-dashboard/CLAUDE-DESIGN-PROMPT.md`

**Interfaces:**
- Consumes: `design-briefs/00-shared/*`, `plan_mvp/03_SPRINT_03_dashboard_entreprise.md`, `plan_mvp/07_SPRINT_07_reporting_reversements.md`
- Produces: brief autonome du dashboard Entreprise web.

- [ ] **Step 1: Décrire responsables, décisions et périmètre**

Expliquer solde réel, budgets d'autorisation, sur-allocation, chauffeurs, stations en lecture, transactions, exports et reporting simple.

- [ ] **Step 2: Définir architecture, parcours et douze écrans**

Couvrir dashboard, chauffeurs, création, détail, budget, activation, stations, transactions, reçu, exports et reporting.

- [ ] **Step 3: Définir tableaux, formulaires, états et données**

Inclure filtres, pagination, alertes, confirmation, vides, erreurs, permissions et données cohérentes.

- [ ] **Step 4: Écrire règles responsive et prompt Claude Design**

Demander une conception desktop 1440 px, utilisable dès 1280 px, avec comportement tablette documenté et aucune BI avancée.

### Task 5: Dossier Dashboard Admin Fusy

**Files:**
- Create: `design-briefs/04-fusy-admin-dashboard/README.md`
- Create: `design-briefs/04-fusy-admin-dashboard/01-product-and-user-context.md`
- Create: `design-briefs/04-fusy-admin-dashboard/02-scope-and-information-architecture.md`
- Create: `design-briefs/04-fusy-admin-dashboard/03-user-flows.md`
- Create: `design-briefs/04-fusy-admin-dashboard/04-screen-specifications.md`
- Create: `design-briefs/04-fusy-admin-dashboard/05-components-states-and-errors.md`
- Create: `design-briefs/04-fusy-admin-dashboard/06-content-and-sample-data.md`
- Create: `design-briefs/04-fusy-admin-dashboard/07-responsive-accessibility-and-quality.md`
- Create: `design-briefs/04-fusy-admin-dashboard/CLAUDE-DESIGN-PROMPT.md`

**Interfaces:**
- Consumes: `design-briefs/00-shared/*`, `plan_mvp/02_SPRINT_02_admin_fusy.md`, `plan_mvp/07_SPRINT_07_reporting_reversements.md`
- Produces: brief autonome du dashboard Admin Fusy web.

- [ ] **Step 1: Décrire opérateurs, risques et périmètre**

Couvrir entreprises, crédits manuels, stations, QR, pompistes, autorisations, transactions, audit, reporting et reversements.

- [ ] **Step 2: Définir architecture, parcours et quinze écrans**

Documenter onboarding entreprise, crédit, onboarding station, gestion QR, rattachement pompiste, autorisation, audit et paiement hors plateforme.

- [ ] **Step 3: Définir composants sensibles, états et données**

Inclure confirmations renforcées, notes internes, références, statuts globaux, audit et lots de reversement.

- [ ] **Step 4: Écrire règles responsive et prompt Claude Design**

Demander une interface interne dense mais lisible, desktop 1440 px, sans exposer les actions Admin aux autres rôles.

### Task 6: Vérification transversale

**Files:**
- Verify: `design-briefs/**/*.md`

**Interfaces:**
- Consumes: tous les documents produits par Tasks 1 à 5.
- Produces: arborescence complète et cohérente prête à donner à Claude Design.

- [ ] **Step 1: Vérifier le nombre de fichiers**

Run: `find design-briefs -type f -name '*.md' | wc -l`

Expected: `41` fichiers Markdown — 1 index, 4 partagés et 9 par application.

- [ ] **Step 2: Vérifier les fichiers obligatoires par application**

Run: `for d in design-briefs/0[1-4]-*; do test -f "$d/README.md" && test -f "$d/CLAUDE-DESIGN-PROMPT.md" || exit 1; done`

Expected: code de sortie `0`.

- [ ] **Step 3: Rechercher les placeholders et termes hors périmètre non signalés**

Run: `rg -n 'TBD|TODO|à définir|Lorem ipsum' design-briefs`

Expected: aucune sortie.

- [ ] **Step 4: Vérifier la présence des règles non négociables dans les prompts**

Run: `for f in design-briefs/0[1-4]-*/CLAUDE-DESIGN-PROMPT.md; do rg -q 'Manrope' "$f" && rg -q 'MVP B2B' "$f" && rg -q 'FCFA' "$f" || exit 1; done`

Expected: code de sortie `0`.

- [ ] **Step 5: Vérifier les liens Markdown relatifs**

Run:

```bash
python3 -c "import pathlib,re,sys; files=list(pathlib.Path('design-briefs').rglob('*.md')); bad=[(str(f),x) for f in files for x in re.findall(r'\]\(([^)]+)\)',f.read_text()) if not x.startswith(('#','http://','https://','mailto:')) and not (f.parent/x.split('#')[0]).resolve().exists()]; print('All local Markdown links resolve' if not bad else bad); sys.exit(bool(bad))"
```

Expected: `All local Markdown links resolve`.

# Brief design — Dashboards web Fusy (Admin Fusy · Entreprise · Station)

> Destinataire : **Claude Design**.
> Objectif : refaire **proprement** le design de **toutes les pages web** créées (3 espaces, 15 pages), en appliquant la charte graphique Fusy, sans changer le comportement métier ni les contrats de données.
> Statut actuel : les pages sont **fonctionnelles mais brutes** (tables/inputs HTML nus, thème gris par défaut du starter-kit). Il faut leur donner une vraie identité Fusy et une UX soignée.

---

## 0. Règles d'or (à ne pas violer)

1. **Ne change aucune URL, route, nom de prop, ni payload.** Le design consomme les données telles quelles (voir §6, l'inventaire des pages).
2. **Ne change aucun endpoint POST** ni le `name` des champs de formulaire (la validation serveur en dépend). Tu peux changer le markup, pas les `name`.
3. **Réutilise les composants shadcn/ui déjà installés** (§4) plutôt que du HTML nu. N'ajoute des composants que si nécessaire via `npx shadcn@latest add <composant>`.
4. **Respecte la charte graphique Fusy** (`docs/superpowers/specs/2026-06-19-fusy-charte-graphique-mvp-design.md`) : Manrope, bleu marine `#003362`, vert `#00B473`, **thème clair uniquement**.
5. **Aucune information portée par la seule couleur** : un statut = couleur **+ libellé** (badge), idéalement + icône.
6. Le code doit rester vert : `npm run build`, `npm run types:check`, `npm run lint:check`, `npm run format:check`. Pas de `any`, pas d'`eslint-disable`.

---

## 1. Contexte produit

**Fusy** est une plateforme B2B de gestion des budgets carburant (marché Cameroun, montants en **FCFA**). Une entreprise prépaie un **compte carburant**, crée des **chauffeurs** avec des **budgets**, et ne peut payer que dans des **stations autorisées**. À la pompe, le chauffeur scanne un QR, confirme par PIN, le débit est immédiat. Trois espaces web :

| Espace | Rôle | Public | Ton |
|---|---|---|---|
| **Admin Fusy** | `fusy_admin` | opérateur Fusy (back-office) | dense, supervision, audit |
| **Entreprise** | `enterprise_admin` | gestionnaire de flotte | clair, rassurant, orienté contrôle des dépenses |
| **Station** | `station_admin` | gérant de station | opérationnel, terrain |

Distinction structurante à rendre visible : le **budget chauffeur** (enveloppe d'autorisation) n'est **pas** le **solde du compte carburant entreprise** (argent réel). Ne jamais les confondre visuellement.

---

## 2. Stack & emplacement des fichiers

- **Laravel 13 + Inertia + React 19 + TypeScript + Tailwind 4 + shadcn/ui (style "new-york")**, icônes **lucide-react**.
- Pages Inertia : `resources/js/pages/{admin,enterprise,station}/*.tsx`.
- Layout commun (sidebar) : `resources/js/layouts/app/app-sidebar-layout.tsx` ; sidebar : `resources/js/components/app-sidebar.tsx`.
- Composants UI partagés Fusy déjà créés : `resources/js/components/fusy.tsx` (`Page`, `Card`, `Stat`, `Table`, `Field`, `fcfa()`, `num()`) — **à enrichir / remplacer par de vrais composants shadcn**.
- Design tokens : `resources/css/app.css` (variables CSS `--background`, `--primary`, … + `@theme`).
- Police : configurée dans `vite.config.ts` (`bunny(...)`) et `--font-sans` dans `app.css`.
- Build : `npm run build`. Aperçu en local : conteneur Docker sur `http://localhost:8000` (voir §8 pour les accès de test).

---

## 3. Identité visuelle à appliquer (charte Fusy)

> Aujourd'hui `app.css` contient le thème **gris neutre par défaut** (oklch) + police **Instrument Sans** + un bloc `.dark`. **À remplacer** par l'identité Fusy ci-dessous. **Supprimer le thème sombre** (charte = clair uniquement) ou le neutraliser.

### 3.1 Couleurs de marque → mapping tokens

| Rôle token shadcn | Valeur Fusy | Remarque |
|---|---|---|
| `--primary` | `#003362` (navy) | action principale, nav active. `--primary-foreground` = blanc |
| `--accent` / vert de marque | `#00B473` | accent, progression, validation. Petit texte vert → utiliser `#007A4F` |
| `--background` | `#F6F8FA` (neutral.50) | fond global app |
| `--card`, surfaces | `#FFFFFF` | cartes |
| `--foreground` | `#172B3A` (neutral.900) | texte principal |
| `--muted-foreground` | `#5E6D78`–`#71808C` | texte secondaire / métadonnées |
| `--border` | `#DCE4EA` (neutral.200) | bordures 1px |
| `--ring` | navy translucide | focus visible |
| Sélection / info douce | fond `#E8F2F9` (navySoft) | |
| Succès doux | fond `#E5F7EF` (greenSoft) | |

### 3.2 Couleurs sémantiques (badges de statut)

| État | Texte | Fond |
|---|---|---|
| Succès (`paid`, `approved`, `active`) | `#007A4F` | `#E5F7EF` |
| Information (`pending`, `open`) | `#00598F` | `#E8F2F9` |
| Avertissement (`expired`, solde bas, `PIN temp`) | `#915600` | `#FFF3DA` |
| Erreur (`failed`, `rejected`) | `#A52E2E` | `#FDECEC` |
| Destructif (`suspended`, `refunded`) | `#C53939` | `#FDECEC` |

### 3.3 Typographie — **Manrope** (graisses 400/500/600/700)

| Style | Taille / interligne | Graisse | Usage |
|---|---:|---:|---|
| Display | 32/40 | 700 | solde, montant principal |
| Titre 1 | 28/36 | 700 | titre d'écran (`<h1>`) |
| Titre 2 | 22/30 | 700 | section / carte |
| Titre 3 | 18/26 | 600 | sous-section |
| Corps | 14/22 | 400 | texte courant, tableaux |
| Libellé | 12/16 | 600 | champs, badges, nav secondaire |
| Légende | 11/16 | 500 | métadonnées |

Remplacer la police par **Manrope** (via `bunny('Manrope', { weights:[400,500,600,700] })` dans `vite.config.ts` + `--font-sans`). **Chiffres tabulaires** (`font-variant-numeric: tabular-nums`, classe Tailwind `tabular-nums`) sur tous les **montants, identifiants, dates et colonnes numériques**.

### 3.4 Formes, espacement, élévation

- Grille d'espacement 4px : `4 8 12 16 24 32 48 64`.
- Rayons : **champ/bouton 8px**, **carte 12px**, **modal 16px**.
- Bordure courante 1px `#DCE4EA`. **Ombres rares** : une bordure suffit pour les cartes ; les élévations sont réservées aux modales, menus et popovers.
- Ligne de tableau ~48px. Marge de page 24–32px.
- Une zone = **une seule action principale bleue**. L'action destructive est séparée visuellement et **confirmée** (modal).

---

## 4. Composants shadcn déjà disponibles (à utiliser)

`alert · avatar · badge · breadcrumb · button · card · checkbox · collapsible · dialog · dropdown-menu · icon · input-otp · input · label · navigation-menu · select · separator · sheet · sidebar · skeleton · sonner (toasts) · spinner · toggle · toggle-group · tooltip`

Pas de composant `Table` shadcn installé → soit en ajouter un (`npx shadcn add table`), soit fournir un composant `DataTable` maison cohérent (en-tête `muted`, lignes 48px, séparateurs `border`, **état vide** soigné). Les **toasts** existent déjà (sonner) et sont câblés au flash `status` du serveur (création de compte renvoie le PIN temporaire dans un toast — **conserver ce comportement**).

### Conventions transverses à implémenter
- **KPI / Stat card** : libellé `muted` 12–14px + valeur Display/Titre, bordure 12px. Montants en `fcfa()`.
- **Badge de statut** : composant unique mappant chaque statut (`paid/pending/expired/failed/refunded`, `approved/rejected`, `open/paid`, `active/suspended`) vers les couleurs sémantiques §3.2 + libellé FR.
- **État vide** : chaque table a un état vide explicite (icône discrète + phrase), pas une ligne « Aucune donnée. » nue.
- **Chargement** : `skeleton`/`spinner` pendant les navigations Inertia ; boutons en état `processing` (déjà géré via `form.processing`).
- **Confirmation** : toute action destructive/sensible (suspendre, rembourser, approuver/refuser un remboursement, marquer un lot payé) passe par un `dialog` de confirmation.
- **Formulaires** : labels persistants (le placeholder n'est pas un label), message d'erreur près du champ (les erreurs Inertia sont dans `errors`), focus visible, cibles ≥ 40px.
- **Responsive** : desktop ≥ 1280px prioritaire ; rester utilisable jusqu'à ~768px (sidebar repliable déjà en place). Tables scrollables horizontalement sur petit écran.
- **Accessibilité** : contraste WCAG AA, focus visible, pas d'info couleur-seule, libellés ARIA sur les boutons icônes.

---

## 5. Architecture de navigation (déjà en place — à habiller)

Sidebar par rôle (`app-sidebar.tsx`), logo « Fusy ». Garder la structure, soigner le style (item actif en navy, icônes lucide 20–24px) :

- **Admin Fusy** : Tableau de bord · Organisations · Transactions · Remboursements · Reversements · Audit
- **Entreprise** : Tableau de bord · Chauffeurs · Stations autorisées · Transactions
- **Station** : Tableau de bord · Pompes · Pompistes · Paiements · Reversements

En-tête de page : titre (Titre 1) + éventuelle action principale à droite (ex. « Export CSV »). Breadcrumb optionnel.

---

## 6. Inventaire des 15 pages — données, sections, actions, états

> Pour chaque page : le **composant Inertia**, le **rôle**, les **props exactes** (forme des données — ne pas renommer), les **sections** à concevoir, les **actions** (avec endpoint), et les **statuts** à badger. Les fichiers sont dans `resources/js/pages/<...>.tsx`.

### A. Espace Admin Fusy (`fusy_admin`)

#### A1． `admin/dashboard` — Tableau de bord
- **Props** : `stats:{enterprises:number, stations:number, paidPayments:number, pendingRefunds:number, totalBalance:number}` · `recentPayments:[{id, reference, short_code, amount, status, fuel_type, station, enterprise, created_at}]` · `audit:[{id, action, organization_id, created_at}]`
- **Sections** : rangée de **5 KPI cards** (Entreprises, Stations, Paiements réglés, Remb. en attente, Soldes carburant en FCFA) ; table « Transactions récentes » ; liste « Activité récente (audit) ».
- **Mettre en avant** `pendingRefunds` (badge d'alerte si > 0, lien vers Remboursements).

#### A2． `admin/organizations` — Organisations
- **Props** : `organizations:[{id, code, type:'enterprise'|'station', name, status, is_demo:boolean, balance:number|null}]` · `enterprises` · `stations` (même forme, filtrées) · `authorizations:[{id, enterprise, station}]`
- **Sections** : 3 cartes de formulaires + table des organisations.
  1. **Créer une organisation** → `POST /admin/organizations`, champs `type` (select enterprise/station), `name`, `admin_name`, `admin_email`, `admin_password`, `is_demo` (checkbox).
  2. **Créditer un compte carburant** → `POST /admin/fuel-credits`, champs `organization_id` (select des entreprises), `amount` (FCFA), `description`.
  3. **Autoriser une station** → `POST /admin/authorized-stations`, champs `enterprise_organization_id`, `station_organization_id` ; afficher la liste `authorizations` existantes.
  - Table « Toutes les organisations » : code (mono), type (+ tag « démo » si `is_demo`), nom, statut (badge), solde (FCFA ou — pour les stations).
- **UX** : séparer clairement « créer » (action structurante) de « créditer » (action financière sensible → idéalement confirmation).

#### A3． `admin/transactions` — Transactions
- **Props** : `payments:[{id, reference, short_code, amount, status, fuel_type, station, enterprise, created_at}]`
- **Sections** : table dense (chiffres tabulaires), badges de statut, code court en mono. Prévoir un **bandeau de filtres** au-dessus (statut, recherche par référence/code) — visuel seulement si pas de backend de filtre, mais conçois l'emplacement.

#### A4． `admin/refunds` — Remboursements
- **Props** : `refunds:[{id, status:'pending'|'approved'|'rejected', reason:string|null, payment_reference, amount, station}]` · `pendingRefunds:number`
- **Actions par ligne `pending`** : **Approuver** `POST /admin/refunds/{id}/approve` (succès/vert) · **Refuser** `POST /admin/refunds/{id}/reject` (destructif/rouge), **les deux avec confirmation**.
- **UX** : action sensible (un remboursement recrédite l'entreprise et le budget) → confirmation + montant rappelé.

#### A5． `admin/settlements` — Reversements
- **Props** : `batches:[{id, reference, station, gross_sales, refunds_deducted, net_amount, status:'open'|'paid', paid_at:string|null}]`
- **Actions** : bouton principal **Générer les lots hebdomadaires** `POST /admin/settlements/generate` ; par ligne `open` : **Marquer payé** `POST /admin/settlements/{id}/paid` (confirmation, action financière).
- **UX** : montants alignés à droite, net en évidence ; bien distinguer ventes brutes / remboursements déduits / net.

#### A6． `admin/audit` — Journal d'audit
- **Props** : `audit:[{id, action, actor:string|null, organization_id:number|null, subject_type:string|null, subject_id:number|null, created_at}]`
- **UX** : table lisible **sans dépendre de la couleur** ; `action` en mono (ex. `payment.captured`), date tabulaire, sujet formaté `Type#id`. Prévoir filtre par action/organisation (emplacement).

### B. Espace Entreprise (`enterprise_admin`)

#### B1． `enterprise/dashboard` — Tableau de bord
- **Props** : `balance:number` · `stats:{drivers, authorizedStations, paidPayments, spentTotal}` · `recentTransactions:[{id, reference, amount, status, fuel_type, station, created_at}]`
- **Sections** : **carte solde** mise en avant (Display, FCFA) clairement nommée « Solde du compte carburant », distincte des KPI ; rangée KPI (Chauffeurs, Stations autorisées, Total dépensé) ; table dernières transactions.

#### B2． `enterprise/drivers` — Chauffeurs
- **Props** : `drivers:[{id, name, phone:string|null, matricule:string|null, status:'active'|'suspended', pin_is_temporary:boolean, budget:{mode:'manual'|'weekly'|'monthly', amount:number, balance:number}|null}]`
- **Sections** : formulaire « Ajouter un chauffeur » (`POST /enterprise/drivers`, champs `name`, `phone`, `matricule`) ; table des chauffeurs avec, par ligne :
  - **Budget** : affichage `balance / amount (mode)` + mini-formulaire **Définir** (`POST /enterprise/drivers/{id}/budget`, champs `mode` select, `amount`) + **Reset** (`POST /enterprise/drivers/{id}/budget/reset`).
  - **Actions** : Reset PIN (`POST .../reset-pin`) · Suspendre/Réactiver (`POST .../suspend`, confirmation pour suspendre).
  - Badge `PIN temp` si `pin_is_temporary`.
- **UX** : rendre lisible la double info **budget restant vs alloué** (barre de progression ?). Le PIN temporaire revient dans un **toast** après création/reset — bien le mettre en valeur (c'est une info à communiquer au chauffeur).

#### B3． `enterprise/stations` — Stations autorisées
- **Props** : `stations:[{id, name, code, status}]`
- **UX** : liste en lecture seule + phrase explicative (« définies par Fusy ; vos chauffeurs ne peuvent payer que dans ces stations »). État vide soigné.

#### B4． `enterprise/transactions` — Transactions
- **Props** : `transactions:[{id, reference, amount, status, fuel_type, station, created_at}]`
- **Action** : lien **Export CSV** → `GET /enterprise/export/transactions` (téléchargement, garder un `<a href>`). Filtres (emplacement).

### C. Espace Station (`station_admin`)

#### C1． `station/dashboard` — Tableau de bord
- **Props** : `stats:{todaySales:number, pendingAmount:number, pumps:number, pompistes:number}` · `recentPayments:[{id, reference, short_code, amount, status, enterprise, fuel_type, confirmed_at}]`
- **Sections** : KPI (Ventes Fusy du jour, En attente de reversement, Pompes, Pompistes) ; table derniers paiements réglés.

#### C2． `station/pumps` — Pompes
- **Props** : `pumps:[{id, label, status, fixed_qr_active:boolean, available_fuels:string[]}]` · `fuels:[{value, label}]`
- **Sections** : formulaire « Ajouter une pompe » (`POST /station/pumps`, champs `label`, `available_fuels[]` = checkboxes des `fuels`) ; table des pompes : libellé, carburants (chips), QR fixe (badge actif/désactivé) + bouton **Activer/Désactiver** (`POST /station/pumps/{id}/toggle-qr`).

#### C3． `station/pompistes` — Pompistes
- **Props** : `pompistes:[{id, name, phone:string|null, matricule:string|null, status, pin_is_temporary:boolean}]`
- **Sections** : formulaire « Ajouter un pompiste » (`POST /station/pompistes`, champs `name`, `phone`, `matricule`) ; table + actions Reset PIN (`POST .../reset-pin`) et Suspendre/Réactiver (`POST .../suspend`). PIN temporaire en toast.

#### C4． `station/payments` — Paiements
- **Props** : `payments:[{id, reference, short_code, amount, status, enterprise, fuel_type, confirmed_at}]`
- **Action** : sur un paiement `paid`, **Demander un remboursement** (`POST /station/payments/{id}/refund`, champ `reason`) → de préférence un **dialog** avec champ motif plutôt qu'un input inline.
- **UX** : le **code court** est l'élément de recherche/vérification → le mettre en valeur (mono, copiable).

#### C5． `station/settlements` — Reversements
- **Props** : `summary:{today_sales:number, pending_amount:number}` · `batches:[{id, reference, gross_sales, refunds_deducted, net_amount, status, paid_at:string|null}]`
- **Sections** : 2 KPI (ventes du jour, en attente) ; table des lots (lecture seule côté station — c'est Fusy qui marque payé). Phrase explicative.

---

## 7. Récapitulatif des statuts à badger (libellés FR)

| Domaine | Valeurs (clé → libellé) |
|---|---|
| Paiement | `pending`→En attente · `paid`→Payé · `expired`→Expiré · `failed`→Échec · `refunded`→Remboursé |
| Remboursement | `pending`→En attente · `approved`→Approuvé · `rejected`→Refusé |
| Reversement | `open`→Ouvert · `paid`→Payé |
| Organisation / Compte | `active`→Actif · `suspended`→Suspendu |
| Type org | `enterprise`→Entreprise · `station`→Station (+ tag « Démo » si `is_demo`) |
| Carburant | `gasoil`→Gasoil · `super`→Super sans plomb · `petrole`→Pétrole lampant |

Formatage : montants `=> num.toLocaleString('fr-FR') + ' FCFA'` (helper `fcfa()` existe déjà), chiffres tabulaires, dates lisibles FR.

---

## 8. Aperçu en local & accès de test

L'app tourne sur **http://localhost:8000** (conteneur Docker ; `docker compose up -d` dans `apps/platform/`). Comptes seedés (mot de passe `password`) :

| Espace | Email |
|---|---|
| Admin Fusy | `admin@fusy.test` |
| Entreprise | `entreprise@fusy.test` |
| Station | `station@fusy.test` |

Données de démonstration présentes (entreprise créditée 2 000 000 FCFA, 2 chauffeurs avec budgets, 1 station avec 1 pompe + 1 pompiste). Pour générer des transactions/paiements à visualiser, voir le parcours mobile dans la doc API (`routes/api.php`).

---

## 9. Définition de « terminé »

1. Les 15 pages sont redessinées avec les composants shadcn et la charte Fusy (couleurs, Manrope, rayons, espacements), thème **clair**.
2. Tokens Fusy appliqués dans `app.css` ; police Manrope chargée ; thème sombre retiré/neutralisé.
3. Badges de statut, KPI cards, états vides, états de chargement, confirmations destructives, toasts de flash : tous présents et cohérents entre les 3 espaces.
4. Budget chauffeur vs solde entreprise visuellement distincts ; montants en FCFA tabulaires.
5. Aucune régression fonctionnelle : routes, `name` de champs et endpoints inchangés.
6. `npm run build`, `npm run types:check`, `npm run lint:check`, `npm run format:check` **verts** ; pas de `any` ni `eslint-disable`.
7. Vérifié visuellement connecté aux 3 espaces sur ≥ 1280px et en responsive réduit.

---

## 10. Références

- Charte graphique complète : `docs/superpowers/specs/2026-06-19-fusy-charte-graphique-mvp-design.md`
- Briefs visuels existants : `design-briefs/` (`00-shared`, `03-company-dashboard`, `04-fusy-admin-dashboard`)
- Exigences produit V3 : `docs/superpowers/specs/2026-06-23-fusy-mvp-v3-design.md`
- Logos : `assets/` (PNG aplatis — usage uniquement, ne pas modifier)
- Pages à redessiner : `apps/platform/resources/js/pages/{admin,enterprise,station}/*.tsx`
- Tokens & composants : `apps/platform/resources/css/app.css`, `apps/platform/resources/js/components/ui/`, `apps/platform/resources/js/components/fusy.tsx`

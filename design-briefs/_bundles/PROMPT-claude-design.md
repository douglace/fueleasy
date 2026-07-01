# Prompt à coller dans Claude Design / Open Design

> À utiliser **avec** deux pièces jointes : le fichier `app-mobile-fusy-COMPLET.md`
> (contexte principal) et l'image `assets/primary-logo.png` (logo). Copier le bloc
> ci-dessous tel quel dans le champ de message.

---

Tu es un designer produit senior spécialisé en apps mobiles fintech B2B. Conçois le **design complet, haute fidélité** de l'application mobile **Fusy** à partir du document joint `app-mobile-fusy-COMPLET.md`, qui fait autorité. Utilise le logo joint `assets/primary-logo.png` tel quel, sans le redessiner ni le recolorer.

**Contexte produit.** Fusy est une plateforme B2B fermée de gestion des budgets carburant au Cameroun. C'est **UNE seule application Flutter** dont l'interface dépend du rôle du compte connecté : **Chauffeur** (Android + iOS) ou **Pompiste** (Android). Ce ne sont PAS deux apps : socle commun partagé (activation, connexion téléphone + PIN), puis aiguillage automatique vers l'expérience du rôle. Ne propose jamais de « choix de rôle » manuel.

**Direction visuelle non négociable.** Police unique **Manrope**. Bleu principal `#003362`, vert accent `#00B473`, fond `#F6F8FA`, surfaces blanches. Thème clair uniquement. Montants au format `15 000 FCFA` en chiffres tabulaires. Cibles tactiles ≥ 48 px. Chaque statut combine **couleur + texte**. Aucun gradient décoratif, glassmorphism, grande ombre, illustration générique ni carte imbriquée. N'invente aucune couleur, police ou variante de logo hors de ce qui est spécifié.

**Ce que je veux en sortie.**
1. Une **architecture de navigation unique** montrant le socle commun puis l'embranchement Chauffeur / Pompiste.
2. Les **maquettes haute fidélité de TOUS les écrans** des deux rôles, y compris les variantes critiques d'états (chargement, vide, hors ligne, réseau instable, permission caméra refusée, QR invalide, station non autorisée, budget/compte insuffisant ou suspendu, PIN incorrect, expiration avant confirmation, envoi en cours anti-double-envoi, reprise avec demande active ; côté pompiste : nouveau paiement à accuser, paiement déjà accusé, aucune session ouverte).
3. Format **390 × 844 px**, vérifié aussi à **360 × 800 px** (Android d'entrée de gamme).
4. Une **bibliothèque de composants réutilisables** (boutons, champs, cartes, badges de statut, minuterie 5 min, code court, saisie PIN, saisie montant) avec états normal, pressé, focus, chargement, désactivé, erreur.
5. De **courtes annotations** des décisions de design et des transitions clés.

**Règle métier à respecter absolument.** Le chauffeur n'a pas de wallet : son entreprise lui alloue un budget. Une transaction = scan du QR d'une station autorisée → saisie montant + carburant → **confirmation par PIN du chauffeur qui débite immédiatement** le compte entreprise et le budget. La demande **expire 5 minutes** après création si le PIN n'est pas saisi. **Aucun débit** après blocage ou expiration. Le **pompiste ne valide ni ne refuse rien** : au moment où un paiement apparaît dans son app il est **déjà réglé** ; il le **consulte** (code, montant, carburant) et en **accuse réception** pour servir le carburant. Il voit uniquement les paiements de SA station.

**Interdit (hors périmètre MVP).** Recharge, Mobile Money, wallet grand public, microcrédit, promotions, carte des stations, itinéraire, géolocalisation, KYC self-service, gestion d'entreprise, scan QR côté pompiste, modification de montant, stock/prix carburant, encaissement, reversement, reporting multi-stations, fonctions Admin Fusy.

**Méthode.** Commence par me proposer l'architecture de navigation et 2–3 écrans clés par rôle (accueil chauffeur, scan/demande, confirmation PIN ; paiements du jour pompiste, détail, accusé de réception) pour validation. Après mon accord, décline l'ensemble des écrans et des états. Utilise exclusivement les données d'exemple du document. Pose une question si une information manque plutôt que d'inventer une fonctionnalité.

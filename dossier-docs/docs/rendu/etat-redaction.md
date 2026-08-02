---
title: "État de la rédaction"
sidebar_position: 2
---

# État de la rédaction

**Mise à jour : 2 août 2026.**

## Échéance

Le rendu écrit est fixé à la **semaine 34, du 17 au 21 août 2026**. L'oral a
lieu en semaine 39, le jury de certification en octobre. Tout ce qui suit est
calibré sur cette date.

## Où en est le livrable

| Élément | Exigence | État |
|---|---|---|
| Volume du document Word | 60 pages minimum hors annexes | environ 13 pages montées (BC01 seul) |
| Partie 1, écrit narratif | 10 à 15 pages | **rien n'est écrit** |
| Partie 2, portefeuille | 61 compétences | 39 rédigées sur le site, 22 restantes |
| Preuves entreprise | anonymisées | 117 fichiers collectés, aucun anonymisé |

## Méthode retenue

### Rédaction par grappe

Les 50 compétences restantes sont rédigées **par grappe de preuves**, pas dans
l'ordre du référentiel, puis assemblées dans l'ordre du référentiel au moment
du montage Word. Le détail des douze grappes est sur la page
[Grappes de rédaction](/blocs/grappes).

La validation se fait **par grappe** et non compétence par compétence. À 50
compétences en quinze jours, un aller-retour par compétence coûterait plus
cher que la rédaction elle-même.

### Format imposé pour chaque compétence

1. Intitulé et critère **exacts** du référentiel, recopiés sans reformulation.
2. Origine de l'acquisition : alternance, expérience antérieure, projet
   académique, homelab.
3. Rappel bref du contexte, en renvoi à la partie 1.
4. Paragraphe rédigé à la première personne, cinq à dix lignes minimum.
5. Liste des preuves avec statut : existante, à produire, à anonymiser, ou
   orale sans annexe.

### Règles d'écriture

Français professionnel et sobre, première personne. Pas de tiret cadratin, pas
d'emoji, pas de formule creuse, pas d'introduction ni de conclusion de
politesse dans les paragraphes de compétence. Police 12, interligne 1 à 1,5,
visuels dosés.

## Règles d'honnêteté

Elles ne souffrent aucune exception.

- **Aucun chiffre sans source vérifiable.** Devant un jury de professionnels,
  un chiffre précis appelle une question précise.
- **Une étude reste une étude.** Une cible reste une cible. Une fonction
  configurée mais non testée n'est jamais présentée comme une réalisation.
- **Sans trace exploitable, c'est oral.** Un élément réel sans trace est classé
  « oral uniquement, sans annexe » et n'est jamais annoncé comme une annexe.
- **Le positionnement n'est jamais gonflé.** Contributeur reste contributeur,
  alternant reste alternant. Sur le comité de sécurité opérationnelle, le rôle
  est de déposer un rapport et de challenger, pas d'animer.
- **Toute preuve d'entreprise est anonymisée ou floutée** : raison sociale,
  noms de personnes, adresses de courriel, noms de serveurs, adresses internes,
  identifiants de tickets, logos.

## Points de vigilance à date

| Point | État au 2 août 2026 |
|---|---|
| Charte informatique | Elle **existe**, versionnée et validée par la DSI, les RH et les représentants du personnel. Nuance à lever : ses destinataires visent la DSI alors que sa diffusion est autorisée à tous. Deux critères en dépendent |
| Portfolio bilingue | **Aucune page en anglais.** Le volet anglais repose sur le niveau C1, deux réunions professionnelles et les courriels de la pièce 31, qui sont collectés. La traduction est un bonus, pas une dépendance |
| Sauvegardes | **Point levé.** La chaîne hors site est réelle depuis le 22 juillet 2026. Le texte de BC01 C11 décrit désormais le réel |
| Security Onion | **Décommissionnée le 31 juillet 2026.** À traiter au passé dans BC01 C1, C5 et C10 |
| Haute disponibilité | **Armée le 1er août, jamais testée.** Le test est reporté tant que la mémoire n'est pas rééquilibrée |
| Lien 10 Gb/s | **Non actif.** Possible à partir du 10 août, après déménagement |
| Mesure de consommation | **Non réalisée.** Possible à partir du 10 août |
| Détection réseau | Le moteur du pare-feu produit des alertes mais **son export est désactivé** : elles n'atteignent pas le SIEM. Corrigé côté dépôt, à activer côté pare-feu |
| CrowdSec | Mécanisme en place, aucune décision de blocage réelle. À présenter comme tel |
| CV-as-Code | À décrire au présent seulement une fois en production |
| Certifications | CyberOps non validée, CCNA reportée. **Aucune certification réseau n'est présentée comme acquise.** La préparation peut être mentionnée comme telle |
| Cours ITIL Ynov | Formation notée 18 sur 20, **pas une certification ITIL** |
| Projet Olympe | Retiré. Membre de l'équipe, jamais chef de projet |

## Avancement par bloc

| Bloc | Compétences | État |
|---|---|---|
| [BC01](/blocs/bc01) | 11 | Textes figés, **rafraîchissement factuel requis** |
| [BC02](/blocs/bc02) | 16 | C1 validée, C2, C3, C4, C6, C7, C15 et C16 rédigées. 8 à rédiger |
| [BC03](/blocs/bc03) | 18 | **G5, G4, G8 et G2 rédigées** (15 compétences). Restent C1, C10, C15 |
| [BC04](/blocs/bc04) | 16 | **G6, G2 et G9 rédigées** (12 compétences). Restent C4, C5, C7, C9 |
| Partie 1 | — | **Intégralement à écrire** |

## Historique

**2 août 2026.** Audit complet du dossier. Les 34 pages BC02 et BC03 du site
présentaient des intitulés et des critères **reformulés** au lieu d'être
recopiés du référentiel, et plusieurs faits fabriqués : audit Active Directory
attribué au homelab alors qu'il n'y en a pas, matériel inexistant, adressage
Corosync faux, tests de restauration et de bascule annoncés comme réalisés
alors qu'ils ne l'étaient pas, chiffres inventés. Les 50 pages ont été
régénérées depuis le référentiel comme source unique, et les grappes G6 et G11
ont été rédigées, puis **G5, la continuité**, qui couvre six compétences du
BC03. Trois preuves convergentes en sortent, par ordre de priorité : le test de
bascule contrôlé, le procès-verbal du test de restauration du 22 juillet, et le
tableau BIA. Puis **G4, supervision et détection**, dont la preuve principale
était déjà capturée, et qui a fait remonter une action technique courte :
activer l'export des alertes du moteur de détection réseau vers le SIEM, qui
est aujourd'hui désactivé. Puis **G8, sécurité, identités et cloud**, qui
achève l'essentiel du BC03 : il n'y reste que quatre compétences, rattachées à
d'autres grappes. Puis **G2, projet périphériques**, première grappe du versant
entreprise, qui a mis au jour dans les pièces le motif de mise en pause du
projet : les clés retenues n'exposent aucun numéro de série exploitable. Puis
**G9, communication et sensibilisation**, la plus grosse grappe du dossier avec
sept compétences, qui porte le BC04 à 12 sur 16.

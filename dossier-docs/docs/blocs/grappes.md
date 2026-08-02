---
title: "Grappes de rédaction"
sidebar_position: 0
---

# Grappes de rédaction

Les 50 compétences restantes ne se rédigent pas dans l'ordre du référentiel.
Cet ordre fait rouvrir la même preuve jusqu'à cinq fois : le post-mortem SOC
sert cinq compétences réparties sur trois blocs, le projet de restriction des
périphériques en sert six. Les traiter ensemble divise le temps de rédaction
par deux environ.

**Règle.** On rédige par grappe, on valide par grappe, on assemble dans l'ordre
du référentiel. L'ordre du référentiel ne compte qu'au moment de l'assemblage
dans le document Word, où il est la seule chose que le jury voit.

## Les douze grappes

| # | Grappe | Compétences | Preuve pivot | État |
|---|---|---|---|---|
| G1 | Correctifs et parc | B2C05, B2C09, B2C14, B3C10 | Tanium, WSUS, politique CVSS | À rédiger |
| G2 | Projet périphériques | B2C04, B2C06, B3C05, B4C01, B4C08 | Pièces 11 à 14 | À rédiger |
| G3 | Support et tickets | B2C12, B2C13, B4C07 | GLPI, Concentrix | À rédiger |
| **G4** | **Supervision et détection** | **B2C07, B3C08, B3C09** | **Détection est-ouest, cascade mémoire, post-mortem SOC** | **Rédigée** |
| **G5** | **Continuité** | **B3C11, B3C12, B3C13, B3C14, B3C16, B3C17** | **BIA, PV de restauration, test de bascule** | **Rédigée** |
| **G6** | **Réseau, budget, achats** | **B2C02, B2C03, B4C12, B4C15, B4C16** | **Arbitrages d'architecture, mesures de débit** | **Rédigée** |
| G7 | IaC et intégration continue | B2C08, B2C10, B2C11 | Packer, OpenTofu, Renovate, CI, corpus GRC | À rédiger |
| **G8** | **Sécurité, identités, cloud** | **B3C02, B3C03, B3C04, B3C06, B3C07, B3C18** | **OPNsense, Authentik, MDM, politique cloud** | **Rédigée** |
| G9 | Communication et sensibilisation | B4C02, B4C03, B4C06, B4C10, B4C11, B4C13, B4C14 | Campagnes, procédures, base de connaissances | À rédiger |
| G10 | Encadrement | B4C04, B4C05, B4C09 | Suivi d'alternance, successeurs, challenge OVH | À rédiger |
| **G11** | **Numérique responsable** | **B2C15, B2C16** | **Consolidation, réemploi, indicateurs** | **Rédigée** |
| G12 | Gouvernance et audit | B2C01, B3C01, B3C15 | CVE, PingCastle, ISAE 3402, Concentrix | À rédiger |

## Pourquoi ce regroupement

Chaque grappe partage soit une preuve, soit un contexte, soit une méthode. En
rédigeant G2, on ouvre une seule fois les quatre pièces du projet
périphériques et on couvre cinq compétences sur trois blocs.

Deux grappes sont volontairement placées en tête, G6 et G11, parce qu'elles
portent les quatre compétences dont les critères sont les plus étroits du
BC02 : les débits optimisés, l'adéquation des propositions, l'empreinte réduite
et les indicateurs définis. Ce sont celles où un texte flou se fait recaler.

G5 a été traitée ensuite parce qu'elle est la plus rentable du dossier : six des
dix-huit compétences du BC03 d'un seul tenant, et une convergence de trois
preuves à produire seulement, le test de bascule, le procès-verbal de
restauration et le tableau BIA.

G4 a suivi pour la raison inverse : sa preuve principale, la synthèse de
détection est-ouest, était **déjà écrite et capturée**. Elle a coûté peu et
elle a révélé une action technique courte à mener avant le rendu, l'activation
de l'export des alertes réseau vers le SIEM.

G8 a bouclé le gros du BC03 en réutilisant largement ce qui venait d'être écrit
en G4, et a fait remonter deux dernières manipulations sur le pare-feu, à
grouper avec la précédente, ainsi qu'un seul livrable manquant, la politique
cloud d'une page.

## Règle d'honnêteté commune

Elle s'applique à toutes les grappes, sans exception.

- Aucun chiffre qui ne provienne d'une source vérifiable. Un chiffre précis
  appelle une question précise à l'oral.
- Une étude reste une étude, une cible reste une cible. Une fonction configurée
  mais non testée n'est jamais présentée comme une réalisation démontrée.
- Un élément réel sans trace exploitable est classé « oral uniquement, sans
  annexe ». Il n'est jamais annoncé comme une annexe.
- Le positionnement n'est jamais gonflé. Contributeur reste contributeur,
  alternant reste alternant.

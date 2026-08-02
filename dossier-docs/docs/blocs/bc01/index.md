---
title: "BC01 — Vue d'ensemble"
sidebar_position: 1
---

# BC01 — Administrer le système d'information

**Statut : validé.** Les 11 compétences sont couvertes — une page par compétence
ci-dessous (intitulé, interprétation, réponse, preuves), et le texte complet du
rendu dans **[Rendu final](/rendu/bc01-textes)**.

## Intitulé

Bloc de compétences 1 du titre RNCP 35594 « Administrateur Systèmes, Réseaux et
Bases de Données » (certificateur IGENSIA) : **Administrer le système
d'information**. Il regroupe **11 compétences**, chacune assortie d'un critère
d'évaluation exact issu du référentiel. Le bloc n'est validé que si les onze
compétences sont acquises.

## Ce que nous en avons compris

C'est le bloc **opérationnel** : exploitation quotidienne du SI, virtualisation,
haute disponibilité, correctifs, réseau, bases de données, performance,
automatisation par scripts, analyse de journaux et sauvegardes. Le jury évalue
chaque compétence contre son critère précis (par exemple « le nombre de serveurs
physiques est diminué » pour la virtualisation), pas contre une impression
d'ensemble. Chaque affirmation doit être traçable à une preuve, ou classée
explicitement « oral uniquement, sans annexe ».

## Comment j'y réponds

Trois origines de preuves, combinées compétence par compétence :

1. **Le homelab yapserver.fr** : cluster Proxmox 3 nœuds, réseau segmenté
   (OPNsense + Cisco 3560X), supervision, IaC (Packer, OpenTofu, Ansible),
   sauvegardes chiffrées automatisées en **3-2-1-1-0** (copie hors site restic
   + copie hors ligne sur clé USB LUKS, tests de restauration réalisés).
2. **L'alternance chez Dupont Restauration** (toutes preuves anonymisées) :
   journal d'exploitation, GPO, Tanium, premier répondant EDR/SOC, scripts et
   automatisations.
3. **Les projets académiques Ynov** : ShopSecure et AccessNow (PostgreSQL,
   intégrité, optimisation, moindre privilège — AccessNow noté 20/20),
   utilisables tels quels.

Trois éléments réels restent **oral uniquement** (aucune trace exploitable) : la
panne CrowdStrike chez Concentrix (C1), l'intervention Meraki chez Concentrix
(C5) et le diagnostic du poste qui redémarrait, événement 1074 (C10).

## Les 11 compétences

| C | Intitulé abrégé | Critère d'évaluation | Origine principale |
|---|---|---|---|
| [C1](./c01.md) | Assurer l'exploitation du SI | Les systèmes et équipements installés sont constamment opérationnels | Dupont + Concentrix + homelab |
| [C2](./c02.md) | Concevoir l'infrastructure d'une plateforme virtuelle | Le nombre de serveurs physiques est diminué | Homelab |
| [C3](./c03.md) | Maintenir en conditions opérationnelles (haute disponibilité) | Le taux de disponibilité observé est conforme aux exigences | Homelab + Dupont |
| [C4](./c04.md) | Identifier les systèmes nécessitant correctifs et reconfiguration | Les correctifs sont appliqués, les paramètres ajustés et cohérents | Dupont + homelab |
| [C5](./c05.md) | Configurer les équipements réseaux (interconnexion) | Les interconnexions sont opérationnelles | Homelab + Concentrix |
| [C6](./c06.md) | Administrer les bases de données avec méthode | Les bases sont opérationnelles, une méthode a été utilisée | Ynov (ShopSecure, AccessNow) + homelab |
| [C7](./c07.md) | Mesurer et analyser les performances du stockage | Les temps de réponse sont satisfaisants | Ynov (ShopSecure) |
| [C8](./c08.md) | Améliorer les performances des BDD (emplacement des stockages) | La fluidité des accès aux données est assurée | Ynov (ShopSecure, AccessNow) |
| [C9](./c09.md) | Rationaliser les tâches par scripts et procédures automatisées | Accroissement de la productivité constaté | Concentrix + Dupont + homelab |
| [C10](./c10.md) | Faciliter la résolution des problèmes par l'analyse des journaux | Les problèmes détectés sont résolus avec agilité | Concentrix + Dupont + homelab |
| [C11](./c11.md) | Automatiser les procédures de sauvegarde | Les coûts d'exploitation sont réduits | Homelab |

:::tip Sauvegardes en 3-2-1-1-0
Le texte de la compétence 11 a été aligné le 25 juillet sur le mécanisme en
production : dumps chiffrés locaux quotidiens, **copie hors site** restic
chiffrée côté client (rétention 7/4/6 + contrôle d'intégrité du dépôt),
**copie hors ligne** sur clé USB LUKS (dernières archives + clés + manifeste
SHA-256), et **tests de restauration réels** (depuis le dépôt hors site le
22 juillet, et après sauvegarde sur la clé USB).
:::

---
title: "BC03 — Vue d'ensemble"
sidebar_position: 1
---

# BC03 — Définir la politique de sécurisation du SI

**Statut : G5 rédigée (6 compétences), 12 à rédiger.** Une page par compétence
ci-dessous, avec l'intitulé et le critère **exacts** du référentiel. La
rédaction se fait par [grappe](/blocs/grappes) : **G5 continuité (faite)**, G8
pour la sécurité et les identités, G4 pour la détection, G1 pour les correctifs,
G12 pour l'audit.

## Intitulé

Bloc de compétences 3 du titre RNCP 35594 : **Définir la politique de
sécurisation du Système d'information**. Il regroupe **18 compétences** : audit
et analyse de risques, ISO 27001, configuration des solutions de sécurité,
sécurisation des transactions et des accès, MDM, IAM, protections actives et
passives, sondes, mises à jour, continuité d'activité (BIA, sauvegardes,
restauration, redondance, PCA) et sécurité cloud.

## Ce que nous en avons compris

Ce bloc évalue la capacité à **penser et outiller la sécurité comme une
politique**, pas comme une somme d'outils : évaluer les risques pour des
décideurs, prioriser un plan de reprise avec des délais validés, prouver par des
**tests probants** (restauration, bascule, redondance) que la continuité tient.
Plusieurs critères exigent un test réel et tracé, pas une configuration en
place. Le guide accepte la projection méthodologique quand une compétence n'a
pas été pratiquée, à condition de l'assumer explicitement comme telle.

## Comment j'y réponds

- **Homelab** : le cœur du bloc. Audit existant à restructurer en rapport
  formel (histoire réelle audit → remédiation), scans OpenVAS et conformité
  Wazuh, SSO Authentik (blueprints, enrôlement TOTP, groupes), règles OPNsense
  avec refus par défaut et **isolement DMZ → production vérifié**, chiffrement
  en transit généralisé, et la chaîne de sauvegarde **3-2-1-1-0 en
  production** : dumps chiffrés locaux, copie hors site restic chiffrée côté
  client, copie hors ligne sur clé USB LUKS, et vérification quotidienne
  d'intégrité. Un **test de restauration réel a eu lieu le 22 juillet 2026**
  depuis le dépôt hors site ; son procès-verbal reste à rédiger. Restent à
  produire : le tableau BIA et le **test de bascule HA tracé**, qui n'a jamais
  été réalisé.
- **Dupont Restauration (anonymisé)** : ISAE 3402, MDM, premier répondant
  EDR/SOC (alerte traitée de bout en bout, post-mortem), fiche réflexe
  d'isolement, habilitations AD.
- **Concentrix** : contrôles d'accès physiques pour les audits ISO 27001 et
  PCI DSS, télétravail massif (200 postes, vagues de 15) porté à l'oral.
- **Acquis BC01 réutilisables** : moindre privilège AccessNow (C7), politique
  CVSS et Tanium (C10), chaîne de sauvegarde (C12, C13).

Garde-fou : **CrowdSec** est un mécanisme en place et démontrable, pas une
capacité éprouvée par une attaque réelle (homelab VPN-only, portfolio via un
tunnel distinct).

## Les 18 compétences

| C | Intitulé abrégé | Critère d'évaluation | Pronostic |
|---|---|---|---|
| [C1](./c01.md) | État des lieux méthodique des risques | Risques évalués dans un rapport d'audit validé, ou Cobit | À confirmer |
| [C2](./c02.md) | Connaître et appliquer ISO 27001, télétravail | Failles identifiées, ou certification ISO 27001 | À confirmer |
| [C3](./c03.md) | Configurer des solutions de sécurité classiques | Configurations des services réseaux conformes | Solide |
| [C4](./c04.md) | Sécuriser les transactions numériques | Des procédures contrôlent l'accès aux données | Solide |
| [C5](./c05.md) | Accès physiques et logiques, données sensibles | Évaluation des risques liés aux équipements produite | Solide |
| [C6](./c06.md) | Gestion unique des terminaux mobiles (MDM) | Une gestion unique des accès est en place | Solide |
| [C7](./c07.md) | Règles IAM, gestion des habilitations | Droits gérés par listes ou groupes | Solide |
| [C8](./c08.md) | Protections passives et actives, plan d'urgence viral | Accès contrôlés, ou attaque virale maîtrisée | Solide |
| [C9](./c09.md) | Évaluer les perturbations via les sondes | Évaluation des risques liés aux malveillances produite | Solide |
| [C10](./c10.md) | Mises à jour automatisées des outils de sécurité | Outils de sécurité mis à jour systématiquement | Solide |
| [C11](./c11.md) | Criticité de l'interruption d'activité | Le plan de reprise est priorisé, les délais d'interruption sont validés | **Rédigée** (G5) |
| [C12](./c12.md) | Chiffrer les canaux de sauvegarde | Tests de sauvegarde sécurisée validés, ou processus d'archives validé | **Rédigée** (G5) |
| [C13](./c13.md) | Plan périodique de restauration | Les tests des procédures de restauration sont probants | **Rédigée** (G5) |
| [C14](./c14.md) | Éléments critiques pour la continuité | Les rôles critiques et les ressources indispensables sont identifiés | **Rédigée** (G5) |
| [C15](./c15.md) | Approvisionnement télétravail de masse | Stocks et chaîne d'approvisionnement opérationnels | Réel Concentrix (oral) |
| [C16](./c16.md) | Ressources de continuité minimale | Les tests de redondance et de substitution sont probants | **Rédigée** (G5) |
| [C17](./c17.md) | Protections assurant la disponibilité (PCA) | Les données répliquées sont disponibles et opérationnelles | **Rédigée** (G5) |
| [C18](./c18.md) | Sécurité cohérente sur site et dans le Cloud | La politique de sécurité du Cloud est définie | À confirmer |

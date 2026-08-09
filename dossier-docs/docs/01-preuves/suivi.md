---
title: Suivi des preuves
sidebar_position: 1
---

# Suivi des preuves homelab

> État consolidé au **24 juillet 2026**. Périmètre : le **homelab**. La partie
> entreprise fait l'objet d'une page dédiée —
> [preuves Dupont Restauration](/preuves/dupont-restauration), 34 pièces
> couvrant 34 des 61 compétences.

**Légende :** ✅ Acquise · 📝 À formaliser · 🔨 À produire · ⛔ Bloquée (matériel) · 👤 À toi (entreprise/oral)

## Les 4 dettes critiques

| Dette | Statut | Détail |
|---|---|---|
| **1 · Backup hors-site** | ✅ Faite et dépassée | Restic → Drive + USB LUKS : **3-2-1-1-0** fonctionnelle (hors-site + hors-ligne). Captures du rendu à rassembler post-21 août. |
| **2 · Test restauration** | ✅ Faite | 22 juil. : snapshot restauré depuis le Drive, dumps intègres, `.enc` déchiffrés. + test post-sauvegarde sur la clé USB. PV à rédiger. |
| **3 · Bascule HA** | 🔓 Débloquée | Produisible en arrêtant un nœud ≠ pve1 (le NFS survit). À faire avec pve4 + Pi avant le 21 août. |
| **4 · Débits réseau** | ◑ À moitié | **État initial 1G mesuré le 9 août** ([pièce](/preuves/mesures-reseau-1g)) : tous les chemins à leur plafond physique. 10G toujours ⛔ (module SFP+ Cisco absent). |

## Dettes techniques

| Dette | Statut | Action | Comp. |
|---|---|---|---|
| 1 · Backup chiffré hors-site | ✅ | Rassembler config expurgée + journal + capture ntfy. | B3C12·18 |
| 2 · Test réel de restauration | 📝 | Rédiger le PV depuis `restauration-sauvegardes.md`. | B3C13 |
| 3 · Test bascule HA | 🔓 | VM témoin, arrêter un nœud ≠ pve1. À faire avec pve4 + Pi. | B3C16·17 |
| 4 · Mesures réseau 1/10G | ◑ | **1G ✅ (9 août, 9 relevés + stockage)** ; 10G ⛔ (SFP+) + capture Grafana. | B2C2·3 |
| 4b · **Rédaction BC02 complète** | ✅ | **16 compétences rédigées (C01-C16).** À relire et réécrire. | B2 |
| 5 · Portfolio en anglais | 🔨 | Ajouter locale `en` + traduire les pages structurantes. | B4C2 |
| 6 · CV-as-Code | 👤 | Code présent ; finalisation en cours. | B2C10·11 |
| 7 · Tableau BIA | 📝 | ~70 % dans l'analyse HA (criticité, RTO/RPO, dépendances). | B3C11·14 |
| 8 · Indicateurs environnementaux | 🔨 | Extinction SO + réemploi Pi. Wattmètre ⛔. | B2C15·16 |
| 9 · Rapport d'audit formel | 🔨 | Constats par risque + recommandations. OpenVAS + Wazuh en appui. | B3C1 |
| 10 · Procédure de mise à jour | 📝 | Formaliser snapshot→cible→déploiement→contrôles→rollback. | — |
| 11 · Politique cloud | 🔨 | VPN-only, MFA, chiffrement. Rédiger 1 page. | — |
| 12 · Procédures docs.yapserver.fr | 📝 | Ajouter des procédures techniques. | — |
| 13 · Comparatif mini-PC/serveur/cloud | 📝 | Arbitrage OVH vs NAS dédié vs local (capex/opex). | — |
| 14 · Étude 1→10G | 📝 | Freebox Ultra 10G, NAS 10G, goulot 1G. | — |
| 15 · Ressource dans NetBox | 🔨 | NetBox à mettre à jour + peupler. | — |

## Preuves par catégorie

### Continuité et sauvegarde

- Config expurgée du backup hors-site — 📝
- Journal d'une sauvegarde réussie — ✅
- Vérification d'intégrité + notif ntfy — ✅
- Procès-verbal du test de restauration — 📝
- Captures avant/après restauration — 📝
- Journaux + chronologie du test HA — 🔓 (au test)
- Tableau BIA avec RTO/RPO — 📝

### Réseau et sécurité

- iperf3 1G / 10G — ✅ (1G, 9 août) / ⛔ (10G)
- Graphique Grafana des essais — 🔨
- Étude d'évolution vers 10G — 📝
- 3 règles OPNsense inter-VLAN — 📝
- Test d'isolement DMZ → prod — ✅ (20 juil.)
- Liste des agents Wazuh actifs — ✅
- Extraits déploiement + règles Wazuh — ✅
- Investigation détection est-ouest (Security Onion) — ⛔ **à capturer avant décommission**
- Applications protégées par Authentik — ✅ (dont SparkyFitness OIDC)
- Preuve d'enrôlement TOTP — ✅

### Exploitation et automatisation

- Tableau Uptime Kuma + dispo — ✅
- Notification d'indisponibilité — ✅
- Incident cascade mémoire — 📝
- Journaux Proxmox d'une migration — 🔓 (au test HA)
- Pré-staging du template — ✅
- Snapshot horodaté avant MAJ — ✅
- Playbook de patch — ✅
- Config Renovate + PR — ✅ (PR mergées dans l'historique)
- Exécution réussie de la CI — ✅
- Chaîne CV-as-Code — 👤

### Documentation et démarche

- Rapport d'audit formel — 🔨
- Indicateurs environnementaux — 🔨
- Relevé du wattmètre — ⛔
- Politique cloud — 🔨
- Procédure de mise à jour — 📝
- Comparatif mini-PC/serveur/cloud — 📝
- Captures de docs.yapserver.fr — ✅
- Page portfolio FR + EN — 🔨
- Commit « veille → action » — 📝
- Préparation CyberOps — 👤 (préparation uniquement)

---
title: "Checklist des preuves homelab"
sidebar_position: 3
---

# Checklist des preuves homelab à sortir

Les 156 lignes des pages de compétences se ramènent à **environ 90 artefacts**,
et à **11 sessions de travail**. Chaque session correspond à un endroit où tu vas
une seule fois. Compte **5 à 7 heures au total**.

Trois verbes seulement :
**capturer** une copie d'écran · **extraire** un fichier ou un extrait de config ·
**expurger** un document existant (retirer IP, noms d'hôtes, versions exactes).

---

## 1. Corpus de gouvernance et notes d'architecture — expurger — 1 h

Le plus rentable : six documents servent vingt compétences.

- [ ] Cartographie du SI → 2C8, 3C1, 3C2, 3C14
- [ ] Matrice des flux autorisés → 2C8, 3C1, 3C2, 3C14
- [ ] Inventaire des actifs relevé en direct, **avec les écarts constatés** → 2C8, 2C16, 3C1, 3C2, 3C11, 3C14
- [ ] Note d'analyse HA (criticité, dépendances, SPOF, mode dégradé) → 2C3, 3C11, 3C14, 3C16, 4C12
- [ ] Note d'arbitrage décommission de la sonde → 4ᵉ nœud → 2C3, 2C6, 2C15, 4C12, 4C16
- [ ] Note d'arbitrage écartant le cloud pour le stockage vif → 3C18, 4C14

> Règle d'expurgation : garder le raisonnement et la structure, réduire les
> adresses à leur segment, retirer les versions exactes.

## 2. Proxmox — capturer — 45 min

- [ ] Vue des nœuds et allocation réelle → 2C6, 2C7
- [ ] Relevé de capacité mémoire par nœud → 2C6, 3C16
- [ ] État du quorum : voix, quorum, pannes tolérées → 2C9, 3C16, 3C17
- [ ] Service d'arbitrage listant les 4 nœuds clients → 3C16
- [ ] Ressources HA déclarées + watchdog → 3C16, 3C17
- [ ] Périmètre HA : machines éligibles / exclues + motif → 3C14, 3C16
- [ ] Stockage partagé et machines dont le disque y réside → 3C17
- [ ] Journaux des migrations réellement conduites → 2C9, 3C16
- [ ] Un snapshot horodaté pré-patch → 2C5, 2C10

## 3. OPNsense et commutateur — capturer + extraire — 45 min

- [ ] Règles inter-segments représentatives (refus par défaut) → 3C3, 3C8
- [ ] Résultat du test d'isolement DMZ → production → 3C3, 3C8, 3C18
- [ ] Test de contournement du reverse proxy (refusé depuis une VM) → 3C3
- [ ] Résolution de noms dédoublée + liste de blocage → 3C3
- [ ] Port Security du commutateur + plan de segmentation → 3C3, 3C5, 3C8
- [ ] Jeux de règles actifs du moteur de détection → 3C8
- [ ] Configuration du port miroir par segment → 3C9
- [ ] Corosync avant/après + version incrémentée, état des liens → 2C2, 2C9
- [ ] Inventaire cartes Mellanox et câbles → 2C2

## 4. Supervision — capturer — 45 min

- [ ] Uptime Kuma : taux par service + historique → 2C7, 2C13
- [ ] Grafana + vue des journaux centralisés → 2C7
- [ ] Tableau de conformité des correctifs (SIEM) → 2C7, 2C13, 3C1
- [ ] Une notification ntfy reçue → 2C7, 4C6
- [ ] Incident de surallocation mémoire, si récupérable → 2C7, 2C16
- [ ] Rapport de scan de vulnérabilités → 3C1
- [ ] État des agents du SIEM → 3C8
- [ ] Indicateurs du filtrage en bordure (mécanisme, pas attaque) → 3C8

## 5. Identités et Authentik — capturer + extraire — 30 min

- [ ] Liste des applications protégées + mode de raccordement → 3C7
- [ ] Parcours d'enrôlement imposant le second facteur → 3C7
- [ ] Descripteurs versionnés (groupes, bindings) → 3C7
- [ ] Rôle lecture seule Ansible avec ses 3 autorisations → 2C10, 3C7
- [ ] Restriction de l'auth par en-tête à l'IP du proxy → 3C7
- [ ] Conversion en empreinte du jeton d'admin du coffre → 3C4

## 6. Chiffrement et accès — extraire — 30 min

- [ ] Tunnel d'accès distant + gestion des clés → 3C4, 3C15
- [ ] Certificats et renouvellement automatique → 3C4
- [ ] Filtre d'accès interne sur adresse source réelle → 3C2, 3C4
- [ ] Tunnel sortant du service public, sans port entrant → 3C4, 3C18
- [ ] Chaîne SOPS + **absence de la clé sur les machines de service** → 3C4
- [ ] Post-mortem de l'incident du secret en clair → 3C4
- [ ] Identifiant d'application dédié chez le fournisseur de stockage → 3C18, 4C16

## 7. Sauvegarde et continuité — extraire + capturer — 45 min

- [ ] Scripts de sauvegarde + units systemd (chiffrement avant écriture) → 3C12
- [ ] Configuration du dépôt hors site (chiffrement côté client) → 3C12, 3C17, 3C18
- [ ] Journal d'une exécution réussie sur les 8 machines → 3C12
- [ ] Tâche de vérification d'intégrité + sa notification → 3C12, 3C13, 3C17, 3C18
- [ ] Tâche mensuelle de rappel de restauration → 3C13
- [ ] Trace du test de restauration des piles amont (base distribuée) → 3C13
- [ ] Runbooks sauvegarde hors site, hors ligne, restauration → 3C12, 3C13
- [ ] Fréquence quotidienne et rétention 7j/4s/3m → 3C11
- [ ] Contournement noyau du pont USB + runbook du gel du parc → 3C14, 3C17
- [ ] Procédure de sauvegarde du pare-feu par API, compte restreint → 3C12, 3C18, 4C15

## 8. IaC, CI et GitOps — extraire — 45 min

- [ ] Modèle Packer + réponse d'installation → 2C10
- [ ] OpenTofu + chiffrement natif du state → 2C10
- [ ] Inventaire dynamique Ansible → 2C10
- [ ] `validate-repo.sh` (5 types de fichiers) → 2C10
- [ ] Une exécution réussie de la CI → 2C10
- [ ] `gitops-apply` : timer, healthcheck, rollback, disjoncteur → 2C5, 2C10, 3C17
- [ ] Hook pre-commit + son test → 2C10, 4C6, 4C13
- [ ] `git-drift` et une exécution propre → 2C10, 4C6
- [ ] Dossier `deploiements-amont/` (reproduction) → 2C10
- [ ] Notes de pré-staging du template 9001 → 2C8, 2C9
- [ ] Runbook de la migration fantôme → 2C9
- [ ] Garde-fou excluant `GRC/` du dépôt public → 2C8

## 9. Mises à jour et versions — extraire — 30 min

- [ ] Renovate : config + une demande étiquetée → 2C11, 3C10
- [ ] `check-image-bumps.sh` + son branchement bloquant → 2C11, 3C10
- [ ] Contrainte `allowedVersions` + justification par les cycles de support → 2C3, 3C10, 4C15
- [ ] `migrate-postgres-major.sh` → 2C11
- [ ] Traces des 5 migrations + comparaison des compteurs de lignes → 2C11
- [ ] Note sur le point de montage PostgreSQL 18 → 2C11
- [ ] Correction du healthcheck manquant (rollback à tort) → 2C11
- [ ] Note de fin de vie du moteur de base → 4C15
- [ ] Rôle `unattended_upgrades` en socle → 3C10
- [ ] Playbook de patch + attente du quorum → 3C10
- [ ] Tâches d'entretien des outils de sécurité (feeds, agents) → 3C10

## 10. Documentation — capturer — 20 min

- [ ] Fiches de service `docs.yapserver.fr` → 2C12, 4C1, 4C2
- [ ] Parcours de démarrage en 3 étapes → 2C12, 4C2
- [ ] Page d'état des services → 2C12
- [ ] Runbooks techniques (expurger) → 4C1, 4C2
- [ ] Les 3 surfaces documentaires et leurs publics → 4C6
- [ ] Canal ntfy + une alerte reçue → 4C6
- [ ] Règles de nommage et mise en quarantaine → 4C13
- [ ] Post-mortem de l'incident de divergence git → 4C6

## 11. Divers — extraire — 15 min

- [ ] Plafonnement de journalisation + rétention → 2C15
- [ ] Filtre `DOCKER-USER` au niveau des hôtes → 3C8
- [ ] Correctif du filtre d'ingress ayant rétabli la chaîne d'alerte → 2C7
- [ ] Extension de disque à chaud du scanner → 2C7

---

## Méthode conseillée

**Un dossier par bloc, un fichier par preuve**, nommé `BxCy_objet.png`. Une même
capture servant plusieurs compétences, garde un fichier unique et référence-le
plusieurs fois plutôt que de le dupliquer.

**Commence par la session 1.** Six documents à expurger, une heure, et vingt
compétences couvertes. C'est le meilleur rapport de tout le dossier.

**Ne cherche pas la perfection graphique.** Le guide demande que la preuve
établisse la matérialité du fait, et cite explicitement la copie d'écran comme
forme acceptable.

---

## Ce que cette liste ne couvre pas

Les **7 livrables à produire** qui portent seuls un critère : test de bascule HA,
PV de restauration, rapport d'audit, tableau BIA, politique cloud, procédure de
mise à jour, note de préconisation. Ils sont sur la page *Actions à mener*.

Les **preuves d'entreprise**, qui relèvent de l'anonymisation et sont traitées à
part.

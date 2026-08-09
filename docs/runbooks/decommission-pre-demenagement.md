# Décommission avant déménagement — plan

**Rédigé le 9 août 2026. Rien n'est exécuté.** Ce document fige le périmètre
conservé, ce qui s'arrête, la donnée à sauver et l'ordre des opérations. Il se
lit avant d'éteindre quoi que ce soit.

Objectif : ramener l'actuel pve1 (futur `K8S-NODE-02`) à la production familiale
minimale, et libérer pve2, pve3 et pve4 pour le cluster Kubernetes bare metal.
Cadrage amont dans `Kubernetes/docs/03-transition-pve1.md`.

État relevé le 9 août 2026 : **93 conteneurs sur 13 VM**, 106 Go alloués pour
~122 Go physiques, pve1 sur-alloué à 42 Go pour 30 physiques.

---

## 1. Périmètre conservé

Liste arrêtée par Yanis, complétée des dépendances techniques ci-dessous.

| VM | Conservé | RAM cible |
|---|---|---:|
| `infra` 101 | Traefik, CrowdSec, **docker-socket-proxy**, Authentik (4 conteneurs), cloudflared, Talk HPB, docs utilisateurs, site du dossier | 4 Go |
| `cloud` 103 | Nextcloud (4 conteneurs), Immich (4 conteneurs), Vaultwarden | 8 Go |
| `media` 104 | Jellyfin, Navidrome | 4 Go |
| `truenas` 200 | NAS, pools `tank` et `media` | 8 Go |
| *(à replacer)* | ntfy, Uptime Kuma — voir section 2 | — |
| | **Total** | **24 Go** |

Marge restante sur pve1 : environ 6 Go, qui absorbent les imports Immich, les
caches et les sauvegardes. Elle n'est pas du gaspillage.

### Ajouts au périmètre demandé

**`docker-socket-proxy` est obligatoire.** Traefik lit ses routes par
`tcp://docker-socket-proxy:2375` (`config/traefik.yml`). Sans ce conteneur,
Traefik perd son provider Docker et toutes les routes portées par des labels
disparaissent. Il n'était pas dans la liste ; il n'est pas optionnel.

**Les piles nommées sont des groupes, pas des conteneurs isolés.** Conserver
« Authentik » signifie conserver `authentik-server`, `authentik-worker`,
`authentik-postgresql` et `authentik-redis`. Même logique pour Nextcloud
(app, cron, PostgreSQL 18, Redis) et Immich (server, machine learning,
PostgreSQL 14, Valkey). Vaultwarden est le seul autonome : base SQLite, aucune
dépendance.

**Jellyfin et Navidrome dépendent de deux sources de fichiers**, pas une : le
NFS de TrueNAS et le partage SMB du PC gaming monté en `/mnt/gaming`. Si le PC
gaming ne suit pas au déménagement, les bibliothèques seront partielles sans que
rien ne soit en panne. À décider explicitement plutôt que de le découvrir.

---

## 2. Le point de friction : ntfy et Uptime Kuma

Ces deux services vivent sur la VM `monitoring`, dimensionnée à 8 Go pour
porter Prometheus, Grafana, Loki et NetBox. Les conserver en gardant la VM
porte le total à **32 Go pour 30 Go physiques** : impossible.

**Option retenue — les déplacer sur `infra`.** Les deux sont légers et sans
dépendance vers le reste de la pile de supervision. La VM `monitoring` est alors
décommissionnée entièrement et libère ses 8 Go.

Trois références pointent l'ancienne adresse et doivent être corrigées **avant**
d'éteindre `monitoring`, sans quoi les alertes disparaissent en silence — cas
déjà vécu lors du durcissement du filtre d'ingress.

| Référence | Fichier | Correction |
|---|---|---|
| Canal d'alerte des tâches planifiées | `ansible/roles/scheduled_tasks/defaults/main.yml` | `ntfy_url` : `10.0.30.11:8082` → `10.0.30.10:8082` |
| Allowlist des sondes Uptime Kuma | `services/infra/traefik/dynamic/middlewares.yml` | `10.0.30.11/32` dans `internal-only` → à retirer ou remplacer |
| Filtre d'ingress Docker | `ansible/roles/docker_ingress_filter` | Ports ntfy et Uptime Kuma à déclarer sur `infra` |

La donnée d'Uptime Kuma (base SQLite des moniteurs et de l'historique) doit être
déplacée avec le conteneur, sinon les 28 moniteurs sont à recréer à la main.

**Option de repli**, si le déplacement paraît trop coûteux à faire maintenant :
garder la VM `monitoring` en la ramenant à 2 Go et en n'y démarrant que ntfy et
Uptime Kuma. Total 26 Go, marge réduite à 4 Go. Moins propre, mais sans
modification de configuration.

---

## 3. Périmètre décommissionné

### VM éteintes entièrement

| VM | Nœud | RAM | Services | Donnée à sauver avant extinction |
|---|---|---:|---|---|
| `monitoring` 102 | pve1 | 8 Go | Prometheus, Grafana, Loki, Promtail, node-exporter, cAdvisor, NetBox | **NetBox** : déployé hors dépôt, sa base est la seule copie de l'inventaire. Dashboards Grafana. Historique Prometheus et Loki : perte assumée |
| `firefly` 107 | pve1 | 4 Go | Firefly III, Ghostfolio | Finances personnelles (MariaDB) et portefeuille (PostgreSQL). Donnée réelle et non reconstructible |
| `security` 105 | pve3 | 8 Go | Wazuh manager, indexer, dashboard | Index des alertes, configuration des agents, règles personnalisées |
| `scanner` 106 | pve3 | 8 Go | Greenbone / OpenVAS, 7 conteneurs | Résultats de scans. Les flux SCAP (~17 Go) sont **re-téléchargeables** : ne pas encombrer la sauvegarde hors-site avec |
| `osint` 108 | pve3 | 4 Go | SpiderFoot, SearXNG, ArchiveBox | Scans SpiderFoot, archives web ArchiveBox. SearXNG est sans état |
| `ir` 109 | pve2 | 16 Go | TheHive, Cassandra, Elasticsearch, Cortex | Cassandra = base primaire des cas. Procédure à froid déjà éprouvée le 22 juillet |
| `games` 112 | pve2 | 4 Go | RomM, MariaDB | Base RomM et bibliothèque de ROMs, sur le disque local de la VM |
| `kali-exam` 110 | pve3 | 8 Go | Kali 2026.2 | Éphémère par conception, rien à sauver |
| `tarasque` 300 | pve2 | 16 Go | Backend LLM Ollama | Modèles re-téléchargeables |
| `portfolio-dmz` 111 | pve1 | 2 Go | Portfolio public, cloudflared | Construit depuis le dépôt, rien à sauver — **mais voir section 4** |

### Piles arrêtées sans éteindre leur VM

Sur `cloud`, conservée pour Nextcloud, Immich et Vaultwarden :

SplitPro, SparkyFitness, Stirling PDF, **SiYuan**, **Dawarich**, **Wanderer**,
**Home Assistant**.

Quatre méritent une décision consciente. SiYuan porte le second brain, donc des
notes personnelles. Dawarich enregistre l'historique de localisation en continu :
l'arrêter crée un trou définitif dans la série. Wanderer porte les traces GPX.
Home Assistant pilote de la domotique réelle — son arrêt a des effets physiques
dans le logement, à vérifier avant et non après.

Sur `media`, conservée pour Jellyfin et Navidrome :

gluetun, qBittorrent, Prowlarr, Radarr, Sonarr, Lidarr, Seerr, Jellystat,
Kavita, AudioBookShelf, Readeck.

Kavita et AudioBookShelf portent des **progressions de lecture et d'écoute**,
Jellystat l'historique de visionnage, Readeck les articles sauvegardés. Les
`*arr` portent leurs configurations et leur historique de téléchargement. Arrêter
la chaîne de téléchargement ne casse pas Jellyfin : la bibliothèque existante
reste servie, elle cesse simplement de s'enrichir.

Sur `infra`, conservée : **Homarr** n'est pas dans le périmètre retenu. C'est le
portail d'accueil, sans état critique.

---

## 4. Prérequis bloquants

Ces quatre points sont à traiter **avant la première extinction**.

### 4.1 Exporter les neuf clés de chiffrement — bloquant absolu

Chaque VM chiffre ses sauvegardes avec une clé locale `/etc/homelab-backup.key`.
Vérification du 9 août 2026 : les neuf clés existent et **leurs empreintes sont
toutes différentes**. Elles ne sont donc pas interchangeables.

Détruire une VM sans avoir exporté sa clé rend ses archives chiffrées
**définitivement illisibles**, y compris celles déjà poussées hors-site. La
sauvegarde existerait, mais ne servirait à rien.

C'est l'action T8 du dossier de validation, toujours ouverte. Elle passe en tête.

### 4.2 Sauvegarde fraîche et vérifiée

Contrôle du 9 août 2026 : les neuf VM portent une sauvegarde datée du jour, du
job de 01h30. Avant extinction, refaire une passe manuelle sur les VM qui
disparaissent, puis pousser hors-site, puis **vérifier le déchiffrement** — une
archive non testée n'est pas une sauvegarde.

Volumes : `scanner` 17 Go et `media` 20 Go dominent. Les flux SCAP de `scanner`
sont re-téléchargeables et n'ont pas à partir hors-site.

### 4.3 Réparer la distribution GitOps sur `infra`

La VM `infra` a son remote en HTTPS et ne peut plus s'authentifier auprès de
GitHub. Sa boucle GitOps échoue depuis au moins le 9 août 03h12 et son clone est
en retard. **Toute correction de configuration décrite ici — l'adresse ntfy en
particulier — est indéployable tant que ce n'est pas réparé.** Passer le remote
en SSH.

### 4.4 Trancher le sort du portfolio public

`portfolio-dmz` est la **seule exposition publique** du homelab.
`portfolio.yapserver.fr` tombe avec elle. Elle ne coûte que 2 Go, mais elle
occupe pve1, précisément le nœud à alléger. Trois issues : l'accepter et
l'annoncer, la basculer vers un hébergement hors homelab conformément à la
décision initiale du projet, ou la conserver et renoncer à 2 Go de marge.

---

## 5. Ordre d'extinction

L'ordre suit les dépendances et garde le canal d'alerte vivant le plus longtemps
possible.

1. **Préalables** — les quatre points de la section 4, dans l'ordre.
2. **Laboratoire et hors-production** : `kali-exam`, `tarasque`. Aucun dépendant.
3. **Chaîne sécurité et IR** : `ir`, `scanner`, `osint`, puis `security`. Wazuh
   en dernier des quatre, pour qu'il observe les extinctions précédentes.
4. **`games`**, puis **`firefly`**.
5. **Piles applicatives non retenues** sur `cloud` et `media`, conteneur par
   conteneur, sans toucher aux VM.
6. **Déplacement de ntfy et Uptime Kuma** vers `infra`, correction des trois
   références, vérification qu'une alerte arrive bien.
7. **`monitoring`**, seulement une fois l'étape 6 vérifiée.
8. **`portfolio-dmz`**, selon la décision prise en 4.4.
9. **Réduction de `media` à 4 Go** et contrôle de la marge sur pve1.

---

## 6. Ce qui casse mécaniquement

À anticiper, car ce sont des effets silencieux.

**Les agents Wazuh** installés sur les VM conservées continueront de chercher un
gestionnaire éteint. Sans conséquence fonctionnelle, mais journaux bruyants :
masquer le service sur les VM conservées.

**Les timers de tâches planifiées** des VM décommissionnées disparaissent avec
elles. Ceux des VM conservées continuent, et alertent vers ntfy — d'où l'ordre
de l'étape 6.

**Les moniteurs Uptime Kuma** des services arrêtés passeront tous au rouge. Les
désactiver avant, sinon la notification de masse noie les alertes réelles.

**L'inventaire Ansible** `ansible/inventory/hosts.yml` déclare neuf VM de
services. Les entrées mortes feront échouer les playbooks sur des hôtes
injoignables. À élaguer en même temps.

**Les routes Traefik** des services arrêtés continueront d'exister dans
`dynamic/*.yml` et répondront en erreur de passerelle. Cosmétique, mais à nettoyer
pour ne pas laisser croire à une panne.

---

## 7. Irréversibilités

Trois seulement, et elles sont toutes de la donnée.

Une **clé de chiffrement non exportée** avant destruction de sa VM rend ses
archives illisibles pour toujours. C'est la seule perte réellement définitive et
elle est entièrement évitable.

L'**historique de localisation Dawarich** ne peut pas être reconstitué a
posteriori : le trou correspond à la période d'arrêt.

Les **séries Prometheus et les journaux Loki** ne sont pas sauvegardés. Leur
perte est assumée dans le cadrage Kubernetes, qui prévoit une supervision
externe sur `SRV-RPI-01`.

Tout le reste — configurations, bases applicatives, bibliothèques — est couvert
par les sauvegardes chiffrées, à condition que la section 4.1 soit faite.

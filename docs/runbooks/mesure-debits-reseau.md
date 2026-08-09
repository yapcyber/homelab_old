# Runbook — mesure des débits réseau (avant / après 10 Gb/s)

Reproduit à l'identique la campagne de référence, pour que la comparaison
avant/après ait un sens. La mesure initiale en 1 Gb/s a été faite le
**9 août 2026** ; ce runbook sert à produire la mesure d'après.

Toute la valeur d'un avant/après tient à l'identité de la méthode : **mêmes
chemins, même durée, mêmes nombres de flux, mêmes sens**. Changer un paramètre
invalide la comparaison.

---

## 1. Protocole de référence

| Paramètre | Valeur — à ne pas modifier |
|---|---|
| Durée par essai | 20 secondes |
| Flux | 1 puis 4 flux parallèles |
| Sens | Montant, puis descendant (`-R`) |
| Sortie | JSON (`-J`), conservée horodatée |
| Port | 5201 |

Chemins mesurés :

| Repère | Chemin | Nature |
|---|---|---|
| A | VM ↔ VM, VLAN 30, portées par deux nœuds différents | commuté |
| B | Nœud VLAN 10 ↔ VM VLAN 30 | routé par OPNsense |
| C | Nœud ↔ nœud, VLAN 10 | commuté |
| D | Stockage : écriture/lecture de 512 Mio en accès direct sur le partage NFS | routé |

---

## 2. Garde-fous

Trois règles, issues de la campagne de référence.

**Ne pas saturer le nœud qui porte TrueNAS.** Il sert les disques système de
toutes les VM ; saturer son lien dégrade le parc entier. Les liens étant
identiques, mesurer depuis un nœud déchargé est représentatif. Le seul essai
mené depuis ce nœud est celui du stockage, court (≈ 6 s).

**Ne jamais mesurer le VLAN 20.** Saturer l'anneau de quorum peut faire perdre
le quorum à un nœud et déclencher son fencing. La grandeur utile y est la
latence, pas le débit.

**Vérifier la fenêtre horaire.** Éviter les tâches planifiées : sauvegarde
01h30, flux Greenbone 02h30, dérive git 07h00, agents Wazuh 07h30, certificats
08h00. Le créneau 03h00–06h30 est libre.

---

## 3. Exécution

```bash
# ===== Poste de contrôle =====
# Poser iperf3 aux extrémités (Debian et Proxmox)
ssh root@10.0.10.13 'DEBIAN_FRONTEND=noninteractive apt-get install -y -o DPkg::Lock::Timeout=300 iperf3'

# Lancer la campagne (orchestration SSH, JSON conservés)
./scripts/mesure-debits-reseau.sh
```

Le script démarre le serveur, vérifie qu'il écoute avant chaque chemin, et
l'arrête ensuite.

:::note Piège rencontré
Ne jamais arrêter le serveur avec `pkill -f "iperf3 -s"` : le motif correspond
aussi à la ligne de commande du shell SSH qui le porte, et tue la session avant
que le serveur ne démarre. Utiliser `pkill -x iperf3`, qui filtre sur le nom du
processus.
:::

Mesure du stockage, depuis un nœud :

```bash
# ===== Nœud Proxmox =====
D=/mnt/pve/truenas-vm; F="$D/.mesure-$$.tmp"
df -h "$D" | tail -1                                   # vérifier l'espace AVANT
dd if=/dev/zero of="$F" bs=1M count=512 oflag=direct conv=fsync
sync; echo 3 > /proc/sys/vm/drop_caches
dd if="$F" of=/dev/null bs=1M iflag=direct
rm -f "$F"
```

---

## 4. Résultats de référence (1 Gb/s, 9 août 2026)

Débit utile en Mbit/s.

| Chemin | 1 flux | 4 flux | 4 flux inverse |
|---|---:|---:|---:|
| A — VM ↔ VM, commuté | 937,9 | 937,3 | 938,9 |
| B — routé par OPNsense | 918,7 | 920,6 | 910,0 |
| C — nœud ↔ nœud, commuté | 941,3 | 939,2 | 940,2 |

Stockage NFS : écriture 88,1 Mo/s, lecture 104 Mo/s depuis un nœud distant ;
89,5 et 102 Mo/s depuis le nœud portant TrueNAS.

Plafond pratique d'un lien 1000 Mb/s en TCP : ≈ 941 Mbit/s. **Tous les chemins
sont donc à leur plafond physique.**

---

## 5. Préparation de la mesure 10 Gb/s

### Prérequis matériels

| Élément | État au 9 août 2026 |
|---|---|
| Cartes Mellanox SFP+ sur OPNsense et PC gaming | En place |
| Module 10G du commutateur Cisco (C3KX-NM-10G) | **Absent — c'est le bloquant** |
| Câbles DAC ou transceivers + fibre | À vérifier au déménagement |
| NAS dédié raccordé en 10 Gb/s | Non acquis (cible) |

Tant que le module du commutateur manque, seul le **lien direct entre les deux
machines déjà équipées** est mesurable — il ne traverse pas le commutateur.
C'est le premier essai à faire, et il suffit à démontrer le gain.

### Ce qui change à 10 Gb/s

Le protocole reste identique, mais quatre points deviennent déterminants et
doivent être relevés avec la mesure, sous peine de conclure à tort que le lien
sous-performe.

**Un flux unique ne saturera pas 10 Gb/s.** À ce débit, une seule connexion TCP
est souvent limitée par un cœur CPU. Conserver l'essai à 1 flux (il fait partie
du protocole) mais ne juger le lien que sur l'essai à 4 flux. Ajouter au besoin
un essai à 8 flux, en le déclarant comme un ajout et non comme un remplacement.

**Vérifier la vitesse négociée avant de conclure.** Un lien SFP+ mal apparié
retombe silencieusement à 1 Gb/s :

```bash
cat /sys/class/net/<iface>/speed        # doit afficher 10000
ethtool <iface> | grep -E 'Speed|Duplex'
```

**Relever le MTU.** Les trames étendues (MTU 9000) changent significativement le
résultat à 10 Gb/s. Le relevé doit préciser le MTU des deux extrémités, et la
comparaison avant/après n'est honnête que si l'on compare à MTU égal, ou si l'on
présente le passage aux trames étendues comme une optimisation distincte.

**Surveiller le CPU pendant l'essai.** Si un cœur sature, le chiffre mesure le
processeur et non le lien. Le noter dans le relevé.

### Capture Grafana

L'action T5 demande aussi une capture Grafana pendant les essais. Les nœuds
sont déjà porteurs de Node Exporter et remontent dans Prometheus : le débit par
interface est disponible sans instrumentation supplémentaire. Lancer la capture
sur une fenêtre encadrant largement la campagne, pour que la montée et la
redescente soient visibles.

### Ordre impératif

La mesure 1 Gb/s **précède** la consolidation des VM sur un seul nœud et le
déménagement. Une fois les nœuds vidés puis décommissionnés, les chemins A et C
n'existent plus et l'état initial est définitivement perdu.

---

## 6. Nettoyage

`iperf3` a été installé sur pve3, pve4 et les VM `security` et `ir`. Il est sans
service actif au repos (aucun démon n'est laissé en écoute). Le retirer si
souhaité :

```bash
apt-get remove -y iperf3
```

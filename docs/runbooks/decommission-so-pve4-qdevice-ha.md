# Décommission Security Onion → pve4 → QDevice → Haute disponibilité

Chantier complet, dans l'ordre. Chaque phase est vérifiable avant de passer à la
suivante ; deux points de non-retour sont signalés.

**Relevés du 31/07/2026** — les valeurs de ce document viennent de l'infrastructure
réelle, pas d'un modèle.

## Vue d'ensemble

| Phase | Objet | Point de non-retour |
|---|---|---|
| 0 | Préalables et filet de sécurité | — |
| 1 | Décommission Security Onion (machine, switch, pare-feu, parc) | ⛔ effacement du disque |
| 2 | Installation de pve4 | — |
| 3 | Jonction au cluster | ⛔ `pvecm add` |
| 4 | Raspberry Pi en arbitre de quorum | — |
| 5 | Activation de la haute disponibilité | — |
| 6 | Test de bascule (preuve RNCP) | — |

**Pourquoi cet ordre** : le QDevice n'a d'intérêt qu'à partir de 4 nœuds — à 3
nœuds il porterait le total à 4 votes, un nombre pair, sans gain de tolérance.
Et la HA ne s'active qu'une fois le quorum consolidé.

---

## Phase 0 — Préalables

### 0.1 Les preuves sont-elles bien capturées ?

    ls ~/dossier_de_validation/preuves/preuves_homelab/

Attendu : `SOCa` à `SOCd`, `WAZa` à `WAZd`, et la synthèse. **Si une manque, ne
pas continuer** — la sonde est le seul endroit d'où elles sortent.

Optionnel mais définitif : télécharger le PCAP
(`/nsm/suripcap/4/so-pcap.1785371177`, menu *PCAP* de l'interface).

### 0.2 Sauvegardes fraîches

    ~/homelab/scripts/backup-restic-drive.sh
    restic snapshots --host opnsense | tail -3

La configuration OPNsense va être modifiée en phase 1.3 : on veut un point de
retour daté d'aujourd'hui.

### 0.3 Relever la position de départ

    ssh root@10.0.10.10 'pvecm status; echo ---; ha-manager status'

Attendu : 3 nœuds, `Expected votes: 3`, `Quorum: 2`, HA `idle`, aucune ressource.

---

## Phase 1 — Décommission Security Onion

### 1.1 Arrêter la sonde

    ssh admin@10.0.50.10 'sudo shutdown -h now'

Ne pas effacer le disque tout de suite : garder la machine éteinte permet un
retour arrière tant que la phase 2 n'a pas commencé.

### 1.2 Switch — retirer le SPAN et préparer les ports de pve4

Repérer d'abord les ports concernés :

    ssh <ton-user>@10.0.10.2
    show monitor session all
    show interfaces status

Le port **destination du SPAN** (`Gi0/2`) et le port de **management** de la sonde
sont ceux à reprendre.

    configure terminal
      no monitor session 1

pve4 a besoin de **deux ports**, calqués sur les nœuds existants :

    ! Port 1 — trunk (vmbr0 : management + tous les VLAN de VM)
    interface GigabitEthernet0/<port-trunk>
      description pve4-trunk
      switchport trunk encapsulation dot1q
      switchport mode trunk
      switchport trunk native vlan 10
      switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,100
      spanning-tree portfast trunk
      no shutdown
    !
    ! Port 2 — accès VLAN 20, dédié à Corosync (vmbr1)
    interface GigabitEthernet0/<port-corosync>
      description pve4-corosync
      switchport mode access
      switchport access vlan 20
      spanning-tree portfast
      no shutdown
    end
    write memory

> ⚠️ **Vérifier `native vlan` et la liste des VLAN autorisés sur un port de nœud
> existant** avant de recopier : `show running-config interface Gi0/<port-pve3>`.
> Le management arrive en VLAN 10 non taggé sur les autres nœuds — si ce n'est pas
> le cas chez toi, adapter.

### 1.3 OPNsense — supprimer les règles devenues mortes

*Pare-feu → Règles*, deux suppressions relevées dans la matrice des flux :

| Interface | Règle | Motif |
|---|---|---|
| Production | `→ 10.0.50.0/24 : 1514-1515` — « Agent Wazuh-SOC » | Obsolète : Wazuh est en 10.0.30.14, plus en VLAN 50 |
| SOC | `→ any` — « SOC accès total » | Un VLAN vide ne doit pas conserver un droit total |

Laisser l'interface VLAN 50 en place pour l'instant (elle ne coûte rien et évite
de renuméroter) ; la retirer plus tard si le VLAN reste inutilisé.

Puis **relancer une sauvegarde** pour figer le nouvel état :

    ~/homelab/scripts/backup-restic-drive.sh

### 1.4 Nettoyer le parc

    # Override DNS : retirer soc.yapserver.fr
    #   OPNsense → Services → Unbound DNS → Overrides

    # Uptime Kuma : supprimer le moniteur de la sonde
    #   https://uptime.yapserver.fr

    # Script de vérification des MAJ : retirer le bloc Security Onion
    grep -n "SECURITY_ONION\|10.0.50.10" ~/homelab/ansible/control-node/homelab-update-check.sh

    # Runbook d'accès SSH devenu sans objet
    git rm docs/runbooks/security-onion-ssh-control-node.md

Références documentaires restantes à ajuster (`README.md`, `AUDIT-SECURITE.md`,
`docs/architecture/cloudflare-setup.md`) — à faire en fin de chantier avec la
mise à jour de `project_brief.md`.

---

## Phase 2 — Installation de pve4

### 2.1 Installation

Démarrer sur la clé Proxmox VE. Paramètres :

| Paramètre | Valeur |
|---|---|
| Disque cible | NVMe 238 Go, ext4 (défaut) |
| Nom d'hôte | `pve4.yapserver.fr` |
| Adresse IP | **10.0.10.13/24** |
| Passerelle | 10.0.10.1 |
| DNS | 10.0.10.1 |
| Interface | celle raccordée au **port trunk** |

⚠️ **Le disque de la sonde est effacé ici.** Point de non-retour.

### 2.2 Réseau — reproduire la topologie des autres nœuds

Identifier quelle carte physique est sur quel port, par adresse MAC ou en
débranchant un câble :

    ip -br link

Proxmox 9 nomme les cartes `nic0` / `nic1` de façon stable — même schéma que
pve1, pve2 et pve3, rien à configurer pour ça.

Puis `/etc/network/interfaces`, calqué sur pve3 :

    auto lo
    iface lo inet loopback

    iface nic0 inet manual
    iface nic1 inet manual

    auto vmbr0
    iface vmbr0 inet static
        address 10.0.10.13/24
        gateway 10.0.10.1
        bridge-ports nic1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094

    auto vmbr1
    iface vmbr1 inet static
        address 10.0.20.13/24
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0

    source /etc/network/interfaces.d/*

> `nic1` = trunk (vmbr0), `nic0` = Corosync (vmbr1). **Inverser si le câblage
> l'impose** — c'est le seul point à adapter.

    systemctl restart networking

### 2.3 Vérifier avant d'aller plus loin

    ping -c2 10.0.10.1        # passerelle
    ping -c2 10.0.20.10       # Corosync de pve1 — DOIT répondre
    ping -c2 10.0.60.10       # TrueNAS, pour le NFS

Si `10.0.20.10` ne répond pas, le port Corosync est mal configuré : **ne pas
tenter la jonction**, elle échouerait à mi-chemin.

### 2.4 Dépôts et mise à niveau

    cd ~/homelab/ansible
    ansible-playbook playbooks/proxmox-repos.yml --limit pve4

Ou à la main : retirer le dépôt `enterprise`, ajouter `pve-no-subscription`, puis

    apt update && apt dist-upgrade -y && reboot

> Aligner les versions : pve1 est en **9.2.5**, pve2 et pve3 en **9.2.3**. Profiter
> de ce chantier pour passer `patch.yml` sur pve2 et pve3.

---

## Phase 3 — Jonction au cluster

### 3.1 Ajouter le nœud

**Depuis pve4**, jamais depuis un autre nœud :

    pvecm add 10.0.10.10 --link0 10.0.20.13

Le mot de passe root d'un nœud existant est demandé.

> ⛔ **Ne jamais lancer cette commande sous un `timeout` court.** Le processus
> distant survit à la mort du client SSH : on obtient une jonction fantôme, des
> verrous et des disques orphelins. Incident déjà vécu sur une migration.

`--link0` est obligatoire : le cluster utilise **un seul anneau Corosync**, sur le
VLAN 20 (`ring0_addr` en 10.0.20.x dans `corosync.conf`).

### 3.2 Vérifier

    pvecm status

Attendu : `Nodes: 4`, `Expected votes: 4`, `Quorum: 3`, `Quorate: Yes`.

    pvesm status

Les trois exports NFS (`truenas-vm`, `truenas-backups`, `truenas-media`) doivent
apparaître **actifs** : la configuration de stockage est partagée par le cluster,
rien à déclarer.

### 3.3 Intégrer au parc

    # inventaire Ansible
    #   ansible/inventory/hosts.yml → groupe proxmox : pve4 { ansible_host: 10.0.10.13 }

    # agent Wazuh (les 3 autres nœuds en ont un)
    cd ~/homelab/ansible && ansible-playbook playbooks/baseline.yml --limit pve4

---

## Phase 4 — Raspberry Pi en arbitre de quorum

### 4.1 Pourquoi

4 nœuds = nombre **pair** de votes : une coupure 2-2 ne dégage aucune majorité et
le cluster se fige. Le QDevice apporte une 5ᵉ voix.

**4 nœuds + QDevice = 5 votes, quorum 3, deux pannes tolérées.**

Le Pi n'héberge **aucune machine virtuelle** : il ne fait qu'arbitrer. Un Pi 3B en
100 Mb/s suffit très largement — le trafic de quorum est minuscule.

### 4.2 Préparer le Pi

Raspberry Pi OS Lite, **raccordé au VLAN 20** (port d'accès, comme le port
Corosync de pve4).

    # IP statique 10.0.20.14/24 — pas de passerelle nécessaire
    sudo nano /etc/dhcpcd.conf     # ou /etc/network/interfaces selon la version

    sudo apt update && sudo apt install -y corosync-qnetd
    sudo systemctl enable --now corosync-qnetd

Vérifier depuis un nœud : `ping -c2 10.0.20.14`

### 4.3 Ouvrir temporairement le SSH root sur le Pi

`pvecm qdevice setup` se connecte en **root** au Pi pour y déposer les certificats.

    sudo passwd root                                    # définir un mot de passe
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sudo systemctl restart ssh

### 4.4 Installer le client sur les 4 nœuds

    for n in 10.0.10.10 10.0.10.11 10.0.10.12 10.0.10.13; do
      ssh root@$n 'apt update && apt install -y corosync-qdevice'
    done

### 4.5 Déclarer le QDevice

**Depuis un seul nœud**, une seule fois :

    ssh root@10.0.10.10
    pvecm qdevice setup 10.0.20.14

### 4.6 Refermer le Pi

    sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sudo systemctl restart ssh
    sudo passwd -l root

### 4.7 Vérifier

    pvecm status

Attendu :

    Expected votes:   5
    Total votes:      5
    Quorum:           3
    Qdevice:          Qdevice (votes 1)

---

## Phase 5 — Haute disponibilité

### 5.1 Périmètre — ce qui peut basculer, et ce qui ne le peut pas

La HA exige un **disque sur stockage partagé**. Relevé du 31/07/2026 :

**✅ Éligibles — 9 VM, disque sur `truenas-vm` (NFS)**

| VM | ID | Nœud actuel | RAM |
|---|---|---|---|
| infra | 101 | pve1 | 4 Gio |
| monitoring | 102 | pve1 | 8 Gio |
| cloud | 103 | pve1 | 8 Gio |
| media | 104 | pve1 | 8 Gio |
| firefly | 107 | pve1 | 4 Gio |
| ir | 109 | pve2 | 16 Gio |
| security | 105 | pve3 | 8 Gio |
| scanner | 106 | pve3 | 8 Gio |
| osint | 108 | pve3 | 4 Gio |

**⛔ Non éligibles — disque local ou passthrough**

| VM | ID | Motif |
|---|---|---|
| truenas | 200 | `local-lvm` + **2 périphériques USB en passthrough** |
| portfolio-dmz | 111 | `local-lvm` |
| games | 112 | `local-lvm` |
| tarasque | 300 | `local` + `local-lvm` |
| kali-exam | 110 | `local-lvm` — VM de laboratoire, hors HA par décision |

### 5.2 ⚠️ Ce que cette HA ne couvrira PAS

Les 9 VM éligibles ont leur disque sur `truenas-vm`, un export NFS servi par la
**VM TrueNAS, qui tourne sur pve1 avec des disques USB en passthrough**.

**Si pve1 tombe : TrueNAS disparaît, le NFS disparaît, et les disques des 9 VM
avec.** La HA ne pourra les redémarrer nulle part — il n'y a plus de disque à
monter.

**La HA couvre donc les pannes de pve2, pve3 et pve4.** Pas celle de pve1.

C'est une limite de conception, connue et documentée : elle ne sera levée qu'en
sortant le stockage de pve1. À énoncer telle quelle — une HA présentée comme
complète alors qu'elle ne l'est pas est un écart entre état affiché et état réel.

### 5.3 Déclarer les ressources

    for id in 101 102 103 104 107 109 105 106 108; do
      ha-manager add vm:$id --state started --max_restart 1 --max_relocate 2
    done

| Paramètre | Effet |
|---|---|
| `--state started` | La VM doit tourner ; HA la redémarre si elle s'arrête |
| `--max_restart 1` | Une tentative de redémarrage **sur place** avant de déplacer |
| `--max_relocate 2` | Jusqu'à deux nœuds différents essayés ensuite |

### 5.4 Règles de placement (facultatif, mais recommandé ici)

⚠️ En Proxmox VE **9, les « HA Groups » sont remplacés par des règles
d'affinité** — la plupart des tutoriels en ligne sont périmés.

pve3 est le maillon faible : **i5-6500T, 4 threads sans hyperthreading**, déjà
14 vCPU alloués. Éviter qu'une reprise ne lui envoie les grosses VM :

    # Préférer pve1, pve2 et pve4 pour les VM lourdes — non strict :
    # en dernier recours, pve3 reste utilisable plutôt que rien.
    ha-manager rules add node-affinity eviter-pve3 \
      --resources vm:103,vm:104,vm:109 \
      --nodes pve1,pve2,pve4

    ha-manager rules list

Ne **pas** mettre `--strict 1` : en mode strict, si aucun nœud listé n'est
disponible, la VM ne démarre nulle part.

### 5.5 Vérifier

    ha-manager status

Attendu : le `master` désigné, les 4 `lrm` en `active` (et non plus `idle`), le
watchdog actif, et les 9 ressources en `started`.

---

## Phase 6 — Test de bascule

C'est à la fois la validation du chantier et une **preuve attendue au dossier**
(`Journaux Proxmox d'une migration`).

### 6.1 Choisir la cible

**Un nœud autre que pve1** — pve3 est le bon candidat : il porte `security`,
`scanner` et `osint`, dont l'indisponibilité de quelques minutes est sans
conséquence.

### 6.2 Relever l'état de départ

    date '+%Y-%m-%d %H:%M:%S %Z'
    ssh root@10.0.10.10 'ha-manager status; pvecm status | grep -E "Total|Quorum"'

### 6.3 Provoquer la panne

Coupure franche, pour tester le vrai chemin (fencing + watchdog) :

    # Depuis l'interface Proxmox : pve3 → Arrêt brutal
    # ou physiquement : débrancher l'alimentation

> Un `shutdown` propre migre les VM au lieu de déclencher la HA : il ne teste rien.

### 6.4 Observer

    watch -n5 'ssh root@10.0.10.10 "ha-manager status"'

Compter **1 à 2 minutes** : détection de la perte de quorum du nœud, expiration
du watchdog, puis relance des VM sur les nœuds restants.

Journaux à capturer pour le dossier :

    ssh root@10.0.10.10 'journalctl -u pve-ha-crm --since "10 min ago" | tail -40'
    ssh root@10.0.10.10 'journalctl -u pve-ha-lrm --since "10 min ago" | tail -40'

### 6.5 Vérifier le service rendu

    curl -sk -o /dev/null -w "wazuh   : %{http_code}\n" https://wazuh.yapserver.fr/
    curl -sk -o /dev/null -w "openvas : %{http_code}\n" https://openvas.yapserver.fr/

### 6.6 Remettre pve3 en service

Rallumer. Les VM **ne reviennent pas automatiquement** — c'est voulu. Les
replacer à la main quand tout est stable :

    ha-manager migrate vm:105 pve3
    ha-manager migrate vm:106 pve3
    ha-manager migrate vm:108 pve3

---

## Retour arrière

| Étape | Comment revenir |
|---|---|
| Switch | Reconfigurer le SPAN : `monitor session 1 source vlan 10,20,…,100 both` + `destination interface Gi0/2` |
| Règles OPNsense | Restaurer la sauvegarde du jour : *System → Configuration → Backups → Restore* |
| Jonction cluster | `pvecm delnode pve4` depuis un nœud restant, **après** avoir retiré le QDevice |
| QDevice | `pvecm qdevice remove` |
| HA | `ha-manager remove vm:<id>` pour chaque ressource — les VM continuent de tourner |

⚠️ **Le QDevice se retire toujours AVANT un nœud.** L'ordre inverse laisse le
cluster dans un état incohérent.

---

## Après le chantier

- [ ] `project_brief.md` — corriger le matériel (pve1 est un **Lenovo Ryzen**, pve2 a **31 Go**, pve3 est un **HP ProDesk**), et n'écrire pve4, le QDevice et la HA comme faits **qu'une fois faits**
- [ ] `project_state.md` — journal du chantier, décisions, incidents
- [ ] `GRC/A1-cartographie-si.md` et `A3-actifs-materiels.md` — ajouter pve4 et le Pi
- [ ] `GRC/A2-matrice-flux.md` — solder les constats **F-03** et **F-04**
- [ ] `dossier-docs` — les journaux de bascule pour la preuve « Journaux Proxmox d'une migration »
- [ ] Suricata sur OPNsense — la détection réseau n'est pas encore reprise

# Capturer les preuves Security Onion avant décommission

**À faire avant d'installer quoi que ce soit sur la machine SOC.** Trois preuves
du dossier de validation en dépendent, et elles deviendront inproduisibles une
fois la sonde effacée.

> **Exécution guidée** : `./scripts/preuves-security-onion.sh` enchaîne les
> déclencheurs, horodate chaque étape et s'arrête le temps des captures.
> `--check` vérifie seulement les prérequis. Ce document reste la référence
> pour le détail des captures et la checklist finale.

| Preuve attendue | Fichier concerné |
|---|---|
| Une investigation complète (alerte → contexte → PCAP) | `dossier-docs/docs/blocs/bc01/c10.md` |
| Une détection vue par SO **et absente** de Wazuh | `dossier-docs/docs/blocs/bc03/c09.md` |
| Une investigation de détection **est-ouest** | `dossier-docs/docs/01-preuves/suivi.md` |

Le trafic généré ici est **totalement bénin** : on télécharge un fichier texte
contenant la chaîne `uid=0(root) gid=0(root) groups=0(root)`, que les règles
ET/GPL reconnaissent comme la réponse typique d'un `id` exécuté à distance.
Aucun exploit, aucun binaire, rien de destructif.

## Étape 0 — Que voit réellement le SPAN ? (détermine la suite)

C'est le point qui décide de la forme du test est-ouest. Sur le switch :

    ssh <ton-user>@10.0.10.2
    show monitor session all

La ligne qui décide est le **type de source**, pas la liste qui suit :

| Ce que tu lis | Nature | Ce que la sonde voit | Variante |
|---|---|---|---|
| **`Source VLANs`** … contient `30` | SPAN par VLAN (VSPAN) | Tout le VLAN, y compris le trafic **commuté** entre VM | **A** (intra-VLAN) |
| **`Source Ports`** … `Gi0/1` (le trunk) uniquement | SPAN par port | Uniquement ce qui monte vers OPNsense | **B** (inter-VLAN) |

> Configuration relevée le 29/07/2026 : `Source VLANs — Both : 10,20,30,…,100`,
> destination `Gi0/2`, encapsulation `Replicate` → **variante A**. Le SPAN couvre
> les dix VLAN dans les deux sens et préserve les étiquettes.

⚠️ Dans tous les cas, le SPAN ne voit que ce qui **atteint le switch** : deux VM
sur le *même* hyperviseur communiquent par le bridge Proxmox et ne sortent jamais
sur le câble. D'où le choix `osint` (pve3) → `infra` (pve1) — deux nœuds
physiques distincts. Ne pas substituer d'autres machines sans le vérifier.

C'est la limite documentée dans `AUDIT-SECURITE.md` : le trafic est-ouest à
l'intérieur du VLAN 30 est commuté, pas routé, et ne traverse jamais le pare-feu.
Si le SPAN ne copie que le trunk, il ne le verra pas — d'où la variante B, qui
reste une vraie preuve de détection latérale (mouvement entre segments).

## Préparation

Ouvre l'interface : **https://soc.yapserver.fr** → *Alerts*.

Avant **chaque** test, note l'horodatage UTC — il te servira à filtrer et à
prouver la corrélation entre les captures :

    date -u '+%Y-%m-%d %H:%M:%S UTC'

Topologie utile (relevée le 29/07/2026) : `osint` = 10.0.30.17 sur **pve3**,
`infra` = 10.0.30.10 sur **pve1**. Deux nœuds physiques différents, donc le flux
traverse forcément le switch.

## Test 1 — Nord-sud (échauffement : valide toute la chaîne)

Ne sert pas de preuve, mais confirme que SPAN + Suricata + indexation marchent.
Si rien n'apparaît ici, inutile de continuer.

    ssh debian@10.0.30.17
    date -u '+%Y-%m-%d %H:%M:%S UTC'
    curl -s http://testmynids.org/uid/index.html

**Attendu** dans *Alerts*, sous une minute : une alerte contenant
`id check returned root`, source 10.0.30.17, destination publique.

## Test 2 — Est-ouest (la preuve)

### Variante A — intra-VLAN (si le SPAN couvre le VLAN 30)

**Terminal 1**, sur `infra` — on sert le motif :

    ssh debian@10.0.30.10
    printf 'uid=0(root) gid=0(root) groups=0(root)\n' > /tmp/id.txt
    cd /tmp && python3 -m http.server 8000 --bind 10.0.30.10

**Terminal 2**, sur `osint` — on le récupère :

    ssh debian@10.0.30.17
    date -u '+%Y-%m-%d %H:%M:%S UTC'
    curl -s http://10.0.30.10:8000/id.txt

Puis `Ctrl+C` dans le terminal 1 et `rm /tmp/id.txt`.

**Attendu** : la même signature, mais avec source **10.0.30.17** et destination
**10.0.30.10** — deux adresses internes du même VLAN. C'est ça, la preuve
est-ouest : la détection a lieu sur un flux qui n'a jamais approché le pare-feu.

### Variante B — inter-VLAN (si le SPAN ne couvre que le trunk)

Même principe, mais la cible est dans **un autre VLAN**, donc le flux est routé
par OPNsense et traverse le trunk. Cible pratique : le PC gaming, VLAN 90.

Sur le PC gaming (Linux), servir le motif dans un dossier temporaire :

    printf 'uid=0(root) gid=0(root) groups=0(root)\n' > /tmp/id.txt
    cd /tmp && python3 -m http.server 8000

Depuis `osint` :

    date -u '+%Y-%m-%d %H:%M:%S UTC'
    curl -s http://10.0.90.100:8000/id.txt

**Attendu** : source 10.0.30.17 (VLAN 30) → destination 10.0.90.100 (VLAN 90).
Une détection de mouvement latéral **entre segments**, ce qui illustre en prime
ta segmentation. Si le pare-feu bloque le flux, c'est une preuve en soi : capture
alors le **rejet dans les journaux OPNsense** et bascule sur la variante A.

## Test 3 — SO voit, Wazuh ne voit pas

Ne relance rien : réutilise l'événement du test 2. L'argument à démontrer est la
**complémentarité** — la détection réseau attrape ce que la détection hôte ignore.

1. Dans SO : filtre sur l'horodatage du test 2, ouvre l'alerte.
2. Dans Wazuh (`wazuh.yapserver.fr`) → *Threat Hunting* → même fenêtre de temps,
   recherche `10.0.30.17` puis `10.0.30.10`.

**Attendu côté Wazuh : aucun résultat.** C'est normal et c'est tout l'intérêt —
un `curl` entre deux VM ne produit aucun journal hôte. Les agents surveillent
fichiers, journaux et intégrité, pas les flux réseau.

> Capture les **deux fenêtres avec l'horodatage visible**. Sans la même plage de
> temps affichée des deux côtés, la preuve ne vaut rien devant un jury.

## L'investigation complète (pour `bc01/c10`)

Prends **une** alerte — celle du test 2 de préférence — et déroule la chaîne
complète, une capture par étape :

1. **Alerts** — la liste, ton alerte visible avec son horodatage.
2. Ouvre-la : **règle déclenchée, signature, sévérité, IP source/destination**.
3. *Actions* → **Hunt** / **Correlate** : les événements liés sur les mêmes IP.
4. Les journaux **Zeek** associés (`conn`, `http`) — c'est ce qui montre le
   contexte réseau, au-delà de la simple signature.
5. **PCAP** : télécharge la capture de la session. La capture d'écran du contenu
   (la chaîne `uid=0(root)` visible dans le flux) est la preuve la plus parlante.

C'est cette étape 5 qui justifie ton texte : Zeek et le PCAP sont exactement ce
que la bascule vers Suricata/OPNsense te fera perdre.

## Checklist avant d'effacer la machine

- [ ] `bc01/c10` — alerte, drill-down, journaux Zeek, PCAP (5 captures)
- [ ] `bc03/c09` — SO avec détection **+** Wazuh vide, même fenêtre horaire
- [ ] `suivi.md` — l'investigation est-ouest, IP source et destination internes
- [ ] Captures rangées dans `dossier-docs/` et référencées dans les textes
- [ ] `suivi.md:63` passé de ⛔ à ✅
- [ ] Nettoyage : `rm /tmp/id.txt` sur les machines utilisées, serveurs arrêtés

Tant que cette liste n'est pas cochée, **ne lance pas l'installation Proxmox** :
la machine SOC est le seul endroit d'où ces preuves peuvent sortir.

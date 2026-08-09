#!/usr/bin/env bash
# =============================================================================
# Campagne de mesure iperf3 — état initial 1 Gb/s avant bascule 10 G
# Preuve T4 du dossier de validation (B2C02 « les débits sont optimisés »).
# =============================================================================
# Exécutée depuis le poste de contrôle, qui orchestre en SSH. Aucune mesure
# n'implique pve1 : il porte TrueNAS et les 7 VM familiales, saturer sa carte
# gèlerait le NFS de tout le parc. Tous les liens étant identiques (1000 Mb/s),
# la mesure sur les nœuds déchargés est représentative.
# =============================================================================
set -u
OUT="$(dirname "$0")/resultats"
mkdir -p "$OUT"
STAMP="$(date +%Y%m%d)"

DUREE=20        # secondes par run
declare -a PATHS=(
  # nom|serveur_ssh|serveur_ip|client_ssh|description
  "A-intra-vlan30|debian@10.0.30.18|10.0.30.18|debian@10.0.30.14|VM->VM VLAN 30, commute (pve3 -> pve2)"
  "B-inter-vlan-route|debian@10.0.30.18|10.0.30.18|root@10.0.10.13|VLAN 10 -> VLAN 30, route par OPNsense (forme du chemin NFS)"
  "C-noeud-a-noeud|root@10.0.10.12|10.0.10.12|root@10.0.10.13|pve4 -> pve3, VLAN 10, commute (chemin des migrations)"
)

run() {                                  # $1=fichier  $2=client_ssh  $3=args
  ssh -o BatchMode=yes "$2" "iperf3 $3 -J" > "$OUT/$1.json" 2>"$OUT/$1.err"
  python3 - "$OUT/$1.json" <<'PY'
import json,sys
try:
    d=json.load(open(sys.argv[1]))
    e=d["end"]
    s=e.get("sum_received") or e["sum"]
    snd=e.get("sum_sent") or e["sum"]
    print(f"    {s['bits_per_second']/1e6:8.1f} Mbit/s recu   "
          f"{snd['bits_per_second']/1e6:8.1f} Mbit/s emis   "
          f"retransmissions={snd.get('retransmits','n/a')}")
except Exception as ex:
    print(f"    ECHEC : {ex}")
PY
}

for p in "${PATHS[@]}"; do
  IFS='|' read -r nom srv_ssh srv_ip cli_ssh desc <<< "$p"
  echo "=== $nom — $desc"
  # pkill -x : correspondance sur le NOM du process. Un -f "iperf3 -s" matcherait
  # la ligne de commande du shell SSH lui-meme et le tuerait avant le lancement.
  ssh -o BatchMode=yes "$srv_ssh" 'pkill -x iperf3 2>/dev/null; sleep 1; iperf3 -s -D -p 5201' >/dev/null 2>&1
  sleep 2
  if ! ssh -o BatchMode=yes "$srv_ssh" 'ss -ltn 2>/dev/null | grep -q ":5201"'; then
    echo "  !! serveur iperf3 non demarre sur $srv_ssh — chemin ignore"; echo; continue
  fi

  echo "  [1 flux, ${DUREE}s, sens montant]"
  run "${STAMP}-${nom}-1flux"        "$cli_ssh" "-c $srv_ip -p 5201 -t $DUREE -P 1"
  sleep 3
  echo "  [4 flux, ${DUREE}s, sens montant]"
  run "${STAMP}-${nom}-4flux"        "$cli_ssh" "-c $srv_ip -p 5201 -t $DUREE -P 4"
  sleep 3
  echo "  [4 flux, ${DUREE}s, sens descendant (-R)]"
  run "${STAMP}-${nom}-4flux-inverse" "$cli_ssh" "-c $srv_ip -p 5201 -t $DUREE -P 4 -R"

  ssh -o BatchMode=yes "$srv_ssh" 'pkill -x iperf3' >/dev/null 2>&1
  echo
done
echo "JSON conserves dans $OUT"

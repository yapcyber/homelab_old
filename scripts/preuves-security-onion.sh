#!/usr/bin/env bash
# =============================================================================
# scripts/preuves-security-onion.sh — Générer le trafic des preuves SOC.
# =============================================================================
# À lancer sur le POSTE DE CONTRÔLE, AVANT de décommissionner Security Onion.
# Orchestre les déclencheurs, horodate chaque étape et s'arrête le temps que tu
# fasses les captures. Les captures d'écran restent manuelles : c'est l'interface
# qui les porte, et c'est toi qui dois pouvoir dire que tu les as produites.
#
#   ./scripts/preuves-security-onion.sh            # tout, dans l'ordre
#   ./scripts/preuves-security-onion.sh --check    # prérequis seulement
#
# Trafic généré : un fichier texte contenant « uid=0(root) gid=0(root) ... »,
# motif que les règles ET/GPL reconnaissent comme la réponse d'un `id` distant.
# Aucun exploit, aucun binaire, rien de destructif.
#
# Le détail des captures attendues et la checklist finale sont dans
# docs/runbooks/preuves-security-onion.md
# =============================================================================
set -uo pipefail

OSINT=10.0.30.17          # pve3
INFRA=10.0.30.10          # pve1  — nœud différent : le flux traverse le switch
GAMING=10.0.90.100        # VLAN 90, pour la variante inter-VLAN
SOC=10.0.50.10
PORT=8000
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=8)

step()  { echo ""; echo "▶ $*"; }
ok()    { echo "  ✓ $*"; }
warn()  { echo "  ⚠ $*" >&2; }
die()   { echo "  ❌ $*" >&2; exit 1; }
# Heure LOCALE d'abord : c'est celle qu'affiche l'interface Security Onion.
# L'UTC suit entre parenthèses, pour les journaux qui l'utilisent.
stamp() { date '+%Y-%m-%d %H:%M:%S %Z'" (UTC $(date -u '+%H:%M:%S'))"; }

pause() {
  echo ""
  echo "  ┌─ CAPTURES À FAIRE ───────────────────────────────────────────"
  while IFS= read -r l; do echo "  │ $l"; done <<<"$1"
  echo "  └──────────────────────────────────────────────────────────────"
  read -r -p "  Entrée une fois les captures faites (ou 'p' pour passer) : " a
  [ "$a" = "p" ] && warn "Étape passée."
}

# --- Prérequis ---------------------------------------------------------------
step "Prérequis"
timeout 6 bash -c "cat </dev/null >/dev/tcp/$SOC/443" 2>/dev/null \
  && ok "Security Onion joignable ($SOC)" || die "Security Onion injoignable — rien à capturer."
ssh "${SSH_OPTS[@]}" "debian@$OSINT" true 2>/dev/null && ok "osint joignable ($OSINT, pve3)" || die "osint injoignable."
ssh "${SSH_OPTS[@]}" "debian@$INFRA" true 2>/dev/null && ok "infra joignable ($INFRA, pve1)" || die "infra injoignable."
ssh "${SSH_OPTS[@]}" "debian@$OSINT" 'command -v curl >/dev/null' 2>/dev/null && ok "curl présent sur osint" || die "curl absent sur osint."
ssh "${SSH_OPTS[@]}" "debian@$INFRA" 'command -v python3 >/dev/null' 2>/dev/null && ok "python3 présent sur infra" || die "python3 absent sur infra."
[ "${1:-}" = "--check" ] && { echo ""; ok "Prérequis satisfaits."; exit 0; }

echo ""
echo "  Interface à ouvrir : https://soc.yapserver.fr  →  HUNT"
echo "  (la page Alerts ne porte qu'un filtre ; c'est Hunt qui accepte les requêtes)"
read -r -p "  Entrée quand l'interface est ouverte : " _

# --- Étape 0 : ce que voit le SPAN ------------------------------------------
step "[0/4] Portée du SPAN — décide de la forme du test est-ouest"
cat <<'EOF'
  Configuration relevée le 29/07/2026 (show monitor session all) :
      Source VLANs — Both : 10,20,30,...,100   →  destination Gi0/2, Replicate

  C'est un SPAN par VLAN : il copie AUSSI le trafic commuté entre deux VM du
  même VLAN. La variante A s'applique. (Variante B = repli si un jour la source
  devenait un port unique, typiquement le trunk Gi0/1.)

  ⚠️ Vrai dans les deux cas : le SPAN ne voit que ce qui ATTEINT le switch.
     Deux VM sur le même hyperviseur passent par le bridge Proxmox et restent
     invisibles — d'où osint (pve3) vers infra (pve1).
EOF
echo ""
read -r -p "  Variante à utiliser [A/b] : " VAR
VAR="${VAR:-A}"; VAR="${VAR^^}"

# --- Étape 1 : nord-sud (validation de la chaîne) ---------------------------
step "[1/4] Nord-sud — échauffement, valide SPAN + Suricata + indexation"
T1="$(stamp)"
echo "  Horodatage : $T1"
RES="$(ssh "${SSH_OPTS[@]}" "debian@$OSINT" "curl -s --max-time 15 -o /dev/null -w '%{http_code}' http://testmynids.org/uid/index.html" 2>/dev/null)"
[ "$RES" = "200" ] && ok "Motif récupéré depuis osint (HTTP $RES)" \
  || warn "Réponse inattendue ($RES) — egress bloqué ? Le test suivant reste valable."
echo "  Attendre ~60 s l'indexation ..."; sleep 60
pause "La page Alerts ne porte qu'un filtre : passe par HUNT pour chercher.
Fenêtre de temps : autour de $T1

Requête 1 — l'alerte attendue :
    event.dataset:alert AND source.ip:\"$OSINT\"

Attendu : une alerte « GPL ATTACK_RESPONSE id check returned root »

────────── SI AUCUN RÉSULTAT, DIAGNOSTIQUER ICI ──────────
Requête 2 — la sonde voit-elle seulement ce trafic ?
    source.ip:\"$OSINT\" | groupby event.dataset

  • Des lignes conn / http apparaissent → la capture fonctionne,
    c'est le JEU DE RÈGLES qui ne déclenche pas.
    ⇒ NE PAS CONTINUER : un journal conn est de la télémétrie, pas une
      détection, et bc03/c09 n'aurait rien à montrer.
      Écrire une règle locale — c'est plus rapide que de réparer le
      ruleset, et c'est une meilleure preuve.
      Procédure complète : section « Test 1bis » du runbook
      docs/runbooks/preuves-security-onion.md
      Puis relancer CE script depuis le début.
  • Rien du tout → le trafic n'atteint pas la sonde :
    problème de SPAN, d'interface de capture, ou Suricata à l'arrêt.

Note ce que tu obtiens : la suite en dépend.

Si la requête 2 ne renvoie RIEN non plus, dérouler sur la sonde
(sudo demande le mot de passe, donc en session interactive) :
    ssh admin@10.0.50.10
    sudo so-status                    # Suricata / Zeek / Elastic en marche ?
    ip -br link                       # repérer l'interface de capture
    sudo timeout 10 tcpdump -i <iface> -nn -c 20
                                      # des paquets arrivent-ils vraiment ?"

# --- Étape 2 : est-ouest (LA preuve) ----------------------------------------
step "[2/4] Est-ouest — la preuve attendue par le dossier"
if [ "$VAR" = "A" ]; then
  echo "  Variante A : $OSINT (pve3) → $INFRA (pve1), même VLAN 30, deux nœuds physiques."
  # Serveur auto-limité : il s'arrête seul, rien à tuer derrière.
  ssh "${SSH_OPTS[@]}" "debian@$INFRA" \
    "printf 'uid=0(root) gid=0(root) groups=0(root)\n' > /tmp/id.txt && cd /tmp && timeout 25 python3 -m http.server $PORT --bind $INFRA >/dev/null 2>&1" &
  SRV=$!
  sleep 4
  T2="$(stamp)"
  echo "  Horodatage : $T2"
  OUT="$(ssh "${SSH_OPTS[@]}" "debian@$OSINT" "curl -s --max-time 10 http://$INFRA:$PORT/id.txt" 2>/dev/null)"
  if [ -n "$OUT" ]; then ok "Motif transféré $OSINT → $INFRA : $OUT"; else warn "Aucune réponse — flux bloqué ?"; fi
  wait "$SRV" 2>/dev/null
  ssh "${SSH_OPTS[@]}" "debian@$INFRA" 'rm -f /tmp/id.txt' 2>/dev/null && ok "Serveur arrêté, fichier effacé"
  CIBLE="$INFRA"
  ATTENDU="source $OSINT → destination $INFRA (deux adresses internes du VLAN 30)"
else
  echo "  Variante B : $OSINT (VLAN 30) → $GAMING (VLAN 90), flux ROUTÉ par OPNsense."
  cat <<EOF

  Sur le PC gaming (Linux), lance :
      printf 'uid=0(root) gid=0(root) groups=0(root)\n' > /tmp/id.txt
      cd /tmp && timeout 60 python3 -m http.server $PORT
EOF
  read -r -p "  Entrée quand le serveur tourne : " _
  T2="$(stamp)"
  echo "  Horodatage : $T2"
  OUT="$(ssh "${SSH_OPTS[@]}" "debian@$OSINT" "curl -s --max-time 10 http://$GAMING:$PORT/id.txt" 2>/dev/null)"
  if [ -n "$OUT" ]; then
    ok "Motif transféré $OSINT → $GAMING : $OUT"
  else
    warn "Aucune réponse — le pare-feu bloque probablement ce flux."
    warn "C'est une preuve en soi : capture le REJET dans les journaux OPNsense,"
    warn "puis relance ce script en variante A."
  fi
  CIBLE="$GAMING"
  ATTENDU="source $OSINT (VLAN 30) → destination $GAMING (VLAN 90), mouvement entre segments"
fi
echo "  Attendre ~60 s l'indexation ..."; sleep 60
pause "HUNT, fenêtre de temps autour de $T2

Requête — cibler précisément ce flux :
    event.dataset:alert AND source.ip:\"$OSINT\" AND destination.ip:\"$CIBLE\"

Variante si tu préfères chercher par signature :
    event.dataset:alert AND alert.signature:*root*

Attendu : $ATTENDU
C'est LA preuve est-ouest : détection sur un flux interne.

Si aucune alerte mais que le flux a bien transité, vérifier ce que
la sonde a vu :
    source.ip:\"$OSINT\" AND destination.ip:\"$CIBLE\" | groupby event.dataset

→ preuve pour dossier-docs/docs/01-preuves/suivi.md"

# --- Étape 3 : SO voit, Wazuh ne voit pas -----------------------------------
step "[3/4] Complémentarité — SO détecte, Wazuh ne voit rien"
echo "  On ne relance rien : on réexploite l'événement de $T2."
pause "1. Dans SO (Hunt) : l'alerte de $T2, HORODATAGE VISIBLE à l'écran
       event.dataset:alert AND source.ip:\"$OSINT\" AND destination.ip:\"$CIBLE\"

2. Dans Wazuh (wazuh.yapserver.fr) → Threat Hunting
   MÊME fenêtre de temps, rechercher :
       data.srcip:\"$OSINT\" OR data.dstip:\"$CIBLE\"
   ou, plus simplement, le texte brut : $OSINT
   Attendu : AUCUN résultat — c'est le but

Un curl entre deux VM ne produit aucun journal hôte : les agents
surveillent fichiers, journaux et intégrité, pas les flux réseau.

⚠️ Les DEUX captures doivent montrer la MÊME plage horaire,
   sinon la preuve ne vaut rien devant un jury.

→ preuve pour dossier-docs/docs/blocs/bc03/c09.md"

# --- Étape 4 : l'investigation complète -------------------------------------
step "[4/4] Investigation complète — 5 captures enchaînées"
pause "Repartir de l'alerte de $T2 :
    event.dataset:alert AND source.ip:\"$OSINT\" AND destination.ip:\"$CIBLE\"

Puis dérouler la chaîne, une capture par étape :

1. Alerts       — la liste, ton alerte visible avec son horodatage
2. Le détail    — règle déclenchée, signature, sévérité, IP src/dst
3. Hunt/Correlate — les événements liés sur les mêmes IP
4. Journaux Zeek — conn et http : le CONTEXTE réseau au-delà de la signature
5. PCAP         — télécharger, puis capturer le contenu du flux
                  (la chaîne uid=0(root) visible dedans)

L'étape 5 justifie ton texte : Zeek et le PCAP sont exactement ce que
la bascule vers Suricata/OPNsense te fera perdre.

→ preuve pour dossier-docs/docs/blocs/bc01/c10.md"

# --- Bilan -------------------------------------------------------------------
step "Terminé"
cat <<EOF
  Horodatages à conserver (heure locale, celle de l'interface) :
    nord-sud  : $T1
    est-ouest : $T2

  Requêtes Hunt utilisées :
    event.dataset:alert AND source.ip:"$OSINT"
    event.dataset:alert AND source.ip:"$OSINT" AND destination.ip:"$CIBLE"
    source.ip:"$OSINT" | groupby event.dataset        (diagnostic)

  Checklist avant d'effacer la machine (détail dans le runbook) :
    [ ] bc01/c10 — alerte, détail, corrélation, Zeek, PCAP (5 captures)
    [ ] bc03/c09 — SO avec détection + Wazuh vide, même fenêtre horaire
    [ ] suivi.md — investigation est-ouest, IP source et destination internes
    [ ] captures rangées dans dossier-docs/ et référencées dans les textes
    [ ] suivi.md:63 passé de ⛔ à ✅

  Tant que ce n'est pas coché, ne lance pas l'installation Proxmox :
  la machine SOC est le seul endroit d'où ces preuves peuvent sortir.
EOF

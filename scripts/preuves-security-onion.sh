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
stamp() { date -u '+%Y-%m-%d %H:%M:%S UTC'; }

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
echo "  Interface à ouvrir maintenant : https://soc.yapserver.fr  →  Alerts"
read -r -p "  Entrée quand l'interface est ouverte : " _

# --- Étape 0 : ce que voit le SPAN ------------------------------------------
step "[0/4] Portée du SPAN — décide de la forme du test est-ouest"
cat <<'EOF'
  Sur le switch :   ssh <ton-user>@10.0.10.2   puis   show monitor session all

    Source VLANs 30 (ou les ports d'accès des nœuds) → variante A (intra-VLAN)
    Source Ports Gi0/1 seulement (le trunk)          → variante B (inter-VLAN)

  Si le SPAN ne copie que le trunk, le trafic entre deux VM du VLAN 30 est
  COMMUTÉ : il ne monte jamais vers OPNsense, la sonde ne le verra jamais.
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
pause "Dans Alerts, filtrer autour de $T1
Attendu : une alerte contenant « id check returned root »
          source $OSINT, destination publique

Si RIEN n'apparaît ici, la chaîne de détection est en cause :
inutile de continuer, il faut d'abord la réparer."

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
  ATTENDU="source $OSINT (VLAN 30) → destination $GAMING (VLAN 90), mouvement entre segments"
fi
echo "  Attendre ~60 s l'indexation ..."; sleep 60
pause "Dans Alerts, filtrer autour de $T2
Attendu : $ATTENDU
C'est LA preuve est-ouest : détection sur un flux interne.

→ preuve pour dossier-docs/docs/01-preuves/suivi.md"

# --- Étape 3 : SO voit, Wazuh ne voit pas -----------------------------------
step "[3/4] Complémentarité — SO détecte, Wazuh ne voit rien"
echo "  On ne relance rien : on réexploite l'événement de $T2."
pause "1. Dans SO   : l'alerte de $T2, HORODATAGE VISIBLE à l'écran
2. Dans Wazuh (wazuh.yapserver.fr) → Threat Hunting
   même fenêtre de temps, rechercher $OSINT puis $INFRA
   Attendu : AUCUN résultat — c'est le but

Un curl entre deux VM ne produit aucun journal hôte : les agents
surveillent fichiers, journaux et intégrité, pas les flux réseau.

⚠️ Les DEUX captures doivent montrer la MÊME plage horaire,
   sinon la preuve ne vaut rien devant un jury.

→ preuve pour dossier-docs/docs/blocs/bc03/c09.md"

# --- Étape 4 : l'investigation complète -------------------------------------
step "[4/4] Investigation complète — 5 captures enchaînées"
pause "Sur l'alerte de $T2, dérouler la chaîne, une capture par étape :

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
  Horodatages à conserver :
    nord-sud  : $T1
    est-ouest : $T2

  Checklist avant d'effacer la machine (détail dans le runbook) :
    [ ] bc01/c10 — alerte, détail, corrélation, Zeek, PCAP (5 captures)
    [ ] bc03/c09 — SO avec détection + Wazuh vide, même fenêtre horaire
    [ ] suivi.md — investigation est-ouest, IP source et destination internes
    [ ] captures rangées dans dossier-docs/ et référencées dans les textes
    [ ] suivi.md:63 passé de ⛔ à ✅

  Tant que ce n'est pas coché, ne lance pas l'installation Proxmox :
  la machine SOC est le seul endroit d'où ces preuves peuvent sortir.
EOF

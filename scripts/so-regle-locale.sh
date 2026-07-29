#!/usr/bin/env bash
# =============================================================================
# scripts/so-regle-locale.sh — Faire DÉPLOYER une règle NIDS locale sur la sonde.
# =============================================================================
# À lancer sur le POSTE DE CONTRÔLE, depuis le VLAN admin.
#
#   ./scripts/so-regle-locale.sh            # diagnostic, puis correction guidée
#   ./scripts/so-regle-locale.sh --diag     # diagnostic seul, ne modifie rien
#
# CONTEXTE (29/07/2026) — la règle 1000002 a été créée dans l'interface
# Detections et Suricata a été redémarré, mais aucune alerte ne part. Or :
#   • Zeek journalise bien le trafic  → la capture fonctionne ;
#   • d'autres règles ont alerté      → le moteur et l'indexation fonctionnent.
# Il ne reste donc qu'une hypothèse : la règle n'est pas DÉPLOYÉE jusqu'aux
# fichiers que Suricata charge réellement.
#
# En SO 3.x, `idstools` a disparu : la synchronisation passe par le moteur
# Detections (interface web, Options → Synchronize). `so-suricata-restart` seul
# ne fait que recharger les mêmes fichiers — sans la règle.
#
# sudo est demandé en INTERACTIF sur la sonde (ssh -t) : le mot de passe reste
# entre toi et la machine, il ne transite ni par ce script ni par aucun fichier.
# =============================================================================
set -uo pipefail

SOC=10.0.50.10
SOUSER=admin
SID="${SID:-1000002}"
MSG="HOMELAB TEST Reponse id root sur flux interne"
REGLE="alert tcp any any -> any any (msg:\"$MSG\"; flow:established,to_client; content:\"uid=0(root)\"; classtype:bad-unknown; sid:$SID; rev:1;)"

step() { echo ""; echo "▶ $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ⚠ $*" >&2; }
die()  { echo "  ❌ $*" >&2; exit 1; }

step "Prérequis"
timeout 6 bash -c "cat </dev/null >/dev/tcp/$SOC/443" 2>/dev/null \
  && ok "Sonde joignable ($SOC)" || die "Sonde injoignable — es-tu bien sur le VLAN admin ?"
ssh -o BatchMode=yes -o ConnectTimeout=8 "$SOUSER@$SOC" true 2>/dev/null \
  && ok "SSH $SOUSER OK" || die "SSH refusé."

# --- Phase 1 : diagnostic ----------------------------------------------------
step "Diagnostic (sudo demandé une fois, mis en cache ensuite)"
echo "  Tape ton mot de passe sudo quand la sonde le demande."
echo ""
ssh -t "$SOUSER@$SOC" "
  echo '── 1. Moteur Detections : est-il synchronisé ? ──'
  sudo so-detections-runtime-status 2>&1 | head -25
  echo
  echo '── 2. Règles réellement chargées par Suricata ──'
  sudo so-suricata-rulestats 2>&1 | head -15
  echo
  echo '── 3. Fichiers de règles que Suricata lit ──'
  sudo grep -A12 '^rule-files' /opt/so/conf/suricata/suricata.yaml 2>/dev/null | head -15
  echo
  echo '── 4. Où vit le fichier que Suricata lit ? ──'
  # NE JAMAIS parcourir /nsm : c'est le dépôt de PCAP, potentiellement des
  # centaines de Go — un grep -r s'y enlise et le diagnostic s'arrête là.
  sudo grep -E 'default-rule-path' /opt/so/conf/suricata/suricata.yaml 2>/dev/null
  # Il existe potentiellement DEUX copies : la source Salt et le fichier
  # d'exécution pointé par default-rule-path. Les lister TOUTES.
  sudo find / -name 'all-rulesets.rules' -not -path '/nsm/*' -not -path '/proc/*' -not -path '/sys/*' 2>/dev/null \
    | while read -r x; do sudo ls -l \"\$x\"; done
  echo
  echo '── 5. La règle $SID est-elle dans chaque copie ? ──'
  sudo find / -name 'all-rulesets.rules' -not -path '/nsm/*' -not -path '/proc/*' -not -path '/sys/*' 2>/dev/null \
    | while read -r x; do
        n=\$(sudo grep -c '^alert' \"\$x\" 2>/dev/null)
        if sudo grep -q 'sid:$SID' \"\$x\" 2>/dev/null; then r='✓ PRESENTE'; else r='⛔ ABSENTE '; fi
        echo \"   \$r  (\$n règles)  \$x\"
      done
  echo
  echo '── 6. Quel fichier le conteneur Suricata lit-il ? ──'
  sudo docker inspect so-suricata --format '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{\"\\n\"}}{{end}}' 2>/dev/null \
    | grep -i rule || echo '   (montages non lisibles)'
"

[ "${1:-}" = "--diag" ] && { echo ""; ok "Diagnostic terminé, rien modifié."; exit 0; }

# --- Phase 2 : correction ----------------------------------------------------
step "Correction"
cat <<EOF
  Deux voies, dans cet ordre de préférence.

  VOIE 1 — l'interface (propre, c'est le mécanisme prévu)
    Detections → menu Options → Synchronize → moteur Suricata
    Vérifie au passage que la règle $SID est bien « Enabled » et qu'aucun
    bandeau « mismatch / integrity check failed » n'est affiché.

  VOIE 2 — injection directe (repli, pour une sonde en fin de vie)
    Écrit la règle dans le fichier local et recharge Suricata sans
    passer par Detections. Suffisant pour produire la preuve ce soir.
EOF
echo ""
read -r -p "  Lancer la VOIE 2 maintenant ? [o/N] " a
[ "$a" = "o" ] || { echo ""; ok "Rien modifié. Fais la VOIE 1, puis relance avec --diag pour vérifier."; exit 0; }

step "Injection directe de la règle $SID"
ssh -t "$SOUSER@$SOC" "
  # Injecter dans TOUTES les copies : la source Salt ET le fichier d'exécution.
  # N'en traiter qu'une laisserait Suricata lire l'autre, restée inchangée.
  sudo find / -name 'all-rulesets.rules' -not -path '/nsm/*' -not -path '/proc/*' -not -path '/sys/*' 2>/dev/null \
    | while read -r LOCAL; do
        echo \"   Cible : \$LOCAL\"
        sudo cp \"\$LOCAL\" \"\$LOCAL.avant-$SID\" 2>/dev/null && echo '     sauvegarde faite'
        if sudo grep -q 'sid:$SID' \"\$LOCAL\" 2>/dev/null; then
          echo '     règle déjà présente'
        else
          echo '$REGLE' | sudo tee -a \"\$LOCAL\" >/dev/null && echo '     règle ajoutée'
        fi
      done
  echo
  echo '── Rechargement ──'
  sudo so-suricata-reload-rules 2>&1 | tail -5
  sleep 8
  echo
  echo '── Vérification : la règle est-elle dans chaque copie ? ──'
  sudo find / -name 'all-rulesets.rules' -not -path '/nsm/*' -not -path '/proc/*' -not -path '/sys/*' 2>/dev/null \
    | while read -r x; do
        sudo grep -q 'sid:$SID' \"\$x\" 2>/dev/null && echo \"   ✓ \$x\" || echo \"   ⛔ \$x\"
      done
  echo
  echo '── Erreurs de chargement éventuelles ──'
  sudo tail -30 /opt/so/log/suricata/suricata.log 2>/dev/null | grep -iE 'error|invalid|$SID' | tail -5 \
    || echo '   aucune erreur récente'
"

step "Suite"
cat <<EOF
  1. Générer le trafic et faire les captures :
         ./scripts/preuves-security-onion.sh

  2. Chercher dans HUNT :
         event.dataset:alert AND alert.signature:*HOMELAB*

  3. Si l'alerte part : capture AUSSI la règle dans Detections à côté de
     l'alerte qu'elle a produite — c'est la preuve la plus forte du lot.

  4. Si elle ne part toujours pas : on arrête les frais et on réécrit c09
     sur le constat réel (voir le runbook, section « Si rien ne part »).
EOF

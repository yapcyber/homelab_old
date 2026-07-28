#!/usr/bin/env bash
# =============================================================================
# Déploiement GitOps automatique, avec RETOUR ARRIÈRE PAR GIT.
# =============================================================================
# Boucle de réconciliation en mode « pull » : la VM interroge origin/main et
# applique ce qui la concerne. Pas de webhook — aucun port entrant n'est ouvert
# sur ce réseau, et le modèle pull est de toute façon celui des outils GitOps.
#
# Chaîne : Renovate ouvre une PR → CI classe le risque → fusion sur main
#          → CE script (timer) → pull + compose up → contrôle de santé
#          → si dégradé : retour à la révision précédente + alerte ntfy.
#
# POURQUOI GIT PLUTÔT QU'UNE SNAPSHOT
#   Un retour git restaure la DÉCLARATION, pas les DONNÉES. C'est donc suffisant
#   pour un changement sans état (tag d'image, option de config) — et meilleur
#   qu'une snapshot : instantané, limité aux piles touchées, sans effet de bord
#   sur les données voisines (Vaultwarden vit sur la même VM que Nextcloud).
#   En revanche c'est INSUFFISANT pour une majeure de base ou une migration de
#   schéma : une fois les données réécrites, remettre l'ancien tag donne un
#   conteneur qui refuse de démarrer.
#   → Ce script REFUSE donc de déployer ce que git ne peut pas annuler, en
#     s'appuyant sur scripts/check-image-bumps.sh (rouge/orange = migration
#     manuelle). Le périmètre automatique est exactement le périmètre réversible.
# =============================================================================
set -u

REPO="$HOME/homelab"
VM="$(hostname -s)"
BLOCKED="$HOME/.homelab-gitops-blocked"   # disjoncteur : révision déjà en échec
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-600}"   # 10 min avant de conclure à l'échec
SETTLE=10                                 # délai avant le 1er contrôle

alert() { /usr/local/bin/homelab-alert "$1" "${2:-}" "${3:-default}"; }

# Une seule exécution à la fois (le timer peut retomber pendant un déploiement).
exec 9>"/tmp/homelab-gitops-$VM.lock"
flock -n 9 || exit 0

cd "$REPO" || { alert "📂 $VM : clone ~/homelab introuvable" "" high; exit 1; }
git fetch --quiet origin main || { alert "📂 $VM : git fetch impossible" "" high; exit 1; }

PREV="$(git rev-parse HEAD)"
NEW="$(git rev-parse origin/main)"
[ "$PREV" = "$NEW" ] && exit 0            # déjà à jour, cas nominal silencieux

# --- Disjoncteur : ne pas re-tenter en boucle une révision déjà en échec -----
if [ -f "$BLOCKED" ] && [ "$(cat "$BLOCKED")" = "$NEW" ]; then
  exit 0
fi

# --- Verrou pull lecture-seule : jamais écraser un travail local ------------
# Si la VM a dérivé, c'est git-drift.sh qui alerte ; ici on s'abstient.
if [ -n "$(git status --porcelain --untracked-files=no)" ] \
   || [ "$(git rev-list --count origin/main..HEAD)" -gt 0 ]; then
  alert "🚨 $VM : déploiement GitOps suspendu (dérive locale)" \
        "Des modifications locales existent : elles seraient écrasées.
Résoudre la dérive avant de laisser le déploiement reprendre." high
  exit 1
fi

# --- Aiguillage : refuser ce que git ne sait pas annuler ---------------------
RISK="$(bash scripts/check-image-bumps.sh "$PREV" "$NEW" 2>&1)" && RISK_RC=0 || RISK_RC=$?
if [ "$RISK_RC" -ne 0 ]; then
  echo "$NEW" > "$BLOCKED"
  alert "⛔ $VM : déploiement refusé — migration de données requise" \
        "$RISK

Le retour arrière par git ne suffirait pas ici : une fois les données
réécrites, l'ancien tag ne redémarre plus.
→ Migration manuelle : scripts/migrate-postgres-major.sh
→ Puis effacer $BLOCKED pour réarmer le déploiement." high
  exit 1
fi

# --- Piles concernées PAR CETTE VM ------------------------------------------
# Convention du dépôt : services/<nom-de-vm>/... Une pile = le répertoire qui
# porte le docker-compose.yml (services/firefly/ghostfolio compte à part).
mapfile -t STACKS < <(
  git diff --name-only "$PREV" "$NEW" -- "services/$VM/" | while read -r f; do
    d="$(dirname "$f")"
    while [ "$d" != "." ] && [ ! -f "$d/docker-compose.yml" ]; do d="$(dirname "$d")"; done
    [ -f "$d/docker-compose.yml" ] && echo "$d"
  done | sort -u
)

if [ "${#STACKS[@]}" -eq 0 ]; then
  # Rien pour cette VM (documentation, CI, autre VM) : on avance le clone sans
  # rien redéployer. C'est le cas le plus fréquent et il doit rester silencieux.
  if git reset --hard --quiet "$NEW"; then exit 0; fi
  alert "📂 $VM : mise à jour du clone impossible" "" high
  exit 1
fi

# --- Application -------------------------------------------------------------
git reset --hard --quiet "$NEW" || { alert "📂 $VM : reset --hard impossible" "" high; exit 1; }

for s in "${STACKS[@]}"; do
  ( cd "$s" && docker compose pull --quiet && docker compose up -d ) >/dev/null 2>&1
done

# --- Contrôle de santé -------------------------------------------------------
# Renvoie sur stdout les conteneurs FRANCHEMENT dégradés, et code 1 s'il reste
# des conteneurs en cours de démarrage (health "starting") — donc à attendre.
inspect_stacks() {
  local s c st he rc name pending=0
  for s in "${STACKS[@]}"; do
    for c in $( (cd "$s" && docker compose ps -q) 2>/dev/null); do
      st="$(docker inspect "$c" --format '{{.State.Status}}' 2>/dev/null)"
      he="$(docker inspect "$c" --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' 2>/dev/null)"
      rc="$(docker inspect "$c" --format '{{.RestartCount}}' 2>/dev/null)"
      name="$(docker inspect "$c" --format '{{.Name}}' 2>/dev/null | tr -d '/')"
      case "$st" in
        running)
          case "$he" in
            unhealthy) echo "  - $name : unhealthy" ;;
            starting)  pending=1 ;;
          esac
          # Boucle de redémarrage : franchement dégradé, inutile d'attendre.
          [ "${rc:-0}" -ge 3 ] && echo "  - $name : $rc redémarrages"
          ;;
        restarting) [ "${rc:-0}" -ge 3 ] && echo "  - $name : en redémarrage ($rc)" || pending=1 ;;
        *)          echo "  - $name : $st" ;;
      esac
    done
  done
  return $pending
}

sleep "$SETTLE"
DEADLINE=$(( $(date +%s) + HEALTH_TIMEOUT ))
while :; do
  BAD="$(inspect_stacks)"; PENDING=$?
  [ -n "$BAD" ] && break                                  # dégradé : on arrête d'attendre
  [ "$PENDING" -eq 0 ] && break                            # tout est stable
  [ "$(date +%s)" -ge "$DEADLINE" ] && { BAD="  - délai de $((HEALTH_TIMEOUT/60)) min dépassé, conteneurs toujours en démarrage"; break; }
  sleep 15
done

# --- Retour arrière si dégradé ----------------------------------------------
if [ -n "$BAD" ]; then
  git reset --hard --quiet "$PREV"
  for s in "${STACKS[@]}"; do
    ( cd "$s" && docker compose up -d ) >/dev/null 2>&1   # pas de pull : images locales
  done
  echo "$NEW" > "$BLOCKED"
  sleep "$SETTLE"
  STILL="$(inspect_stacks)"
  alert "🔙 $VM : déploiement annulé, retour à ${PREV:0:8}" \
        "Piles : ${STACKS[*]}
Révision refusée : ${NEW:0:8}

Constaté :
$BAD

Après retour arrière : ${STILL:-toutes les piles saines}

Le déploiement automatique est SUSPENDU sur cette VM tant que
$BLOCKED existe (évite une boucle d'échecs)." high
  exit 1
fi

alert "✅ $VM : déploiement GitOps appliqué (${NEW:0:8})" "Piles : ${STACKS[*]}" low
exit 0

#!/usr/bin/env bash
# =============================================================================
# scripts/check-image-bumps.sh — INDICATEUR DE CONFIANCE sur les montées d'image.
# =============================================================================
# Compare les images Docker d'une révision de référence à celles du travail en
# cours, et classe chaque changement par risque réel :
#
#   ⛔ ROUGE   — majeure d'une image À ÉTAT (base de données) : le répertoire de
#               données est lié à la majeure. Un simple changement de tag ne
#               migre RIEN ; le conteneur refusera de démarrer. Migration
#               (dump/restore ou pg_upgrade) obligatoire.
#   ⚠️ ORANGE  — majeure d'une application à état : migration de schéma jouée au
#               premier démarrage, souvent irréversible sans restauration.
#   ⚠️ JAUNE   — majeure d'un composant sans état : redémarrage suffit, mais
#               changements incompatibles possibles (options, API).
#   ✅ VERT    — mineure, correctif ou digest : déploiement de routine.
#
#   ./scripts/check-image-bumps.sh [ref]      # défaut : origin/main
#
# Sortie non nulle s'il existe au moins un ROUGE ou un ORANGE → utilisable comme
# garde-fou en CI sur les pull requests Renovate.
# =============================================================================
set -uo pipefail

BASE="${1:-origin/main}"
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 1

git rev-parse --verify "$BASE" >/dev/null 2>&1 || { echo "❌ Révision inconnue : $BASE" >&2; exit 2; }

# Bases de données : le répertoire de données est lié à la majeure, le moteur
# refuse de démarrer sur un format qu'il n'a pas écrit.
STATEFUL_DB='postgres|postgis|mariadb|mysql|percona|elasticsearch|opensearch|cassandra|mongo|influxdb|clickhouse|timescale'
# Caches clé-valeur : format de persistance ASCENDANT-compatible, et ici de la
# donnée reconstructible. Une majeure ne justifie pas le même niveau d'alerte —
# un indicateur qui alerte sur tout ne sert à rien.
CACHE='redis|valkey|keydb|memcached'
# Applications qui migrent leur schéma au démarrage.
STATEFUL_APP='uptime-kuma|nextcloud|immich|authentik|netbox|firefly|ghostfolio|jellystat|thehive|cortex|wazuh|romm|siyuan|dawarich|wanderer|splitpro|sparkyfitness|readeck|audiobookshelf|kavita|navidrome'

# --- Extraction : fichier -> nom d'image -> tag, pour une révision donnée ----
# Normalise en retirant le registre et le digest : ghcr.io/x/postgres:16@sha256:… -> postgres 16
extract() { # $1 = révision ("" = arbre de travail)
  local rev="$1" f content
  while IFS= read -r f; do
    if [ -z "$rev" ]; then
      content="$(cat "$f" 2>/dev/null)"
    else
      content="$(git show "$rev:$f" 2>/dev/null)" || continue
    fi
    grep -hoE '^[[:space:]]*image:[[:space:]]*[^[:space:]#]+' <<<"$content" 2>/dev/null \
      | sed -E 's/^[[:space:]]*image:[[:space:]]*//' \
      | while read -r img; do
          img="${img%%@*}"                       # retire le digest
          local name tag
          name="${img%:*}"; tag="${img##*:}"
          [ "$name" = "$img" ] && tag=""         # pas de tag explicite
          name="${name##*/}"                     # retire le registre/namespace
          printf '%s\t%s\t%s\n' "$f" "$name" "$tag"
        done
  done < <(git ls-files 'services/*docker-compose*.yml' 'services/*compose*.yaml' 2>/dev/null)
}

major() { # extrait la majeure d'un tag : "16-alpine" -> 16 ; "v2.1" -> 2 ; sinon vide
  sed -E 's/^v//' <<<"$1" | grep -oE '^[0-9]+' || true
}

OLD="$(mktemp)"; NEW="$(mktemp)"
trap 'rm -f "$OLD" "$NEW"' EXIT
extract "$BASE" | sort -u > "$OLD"
extract ""      | sort -u > "$NEW"

RED=0; ORANGE=0; YELLOW=0; GREEN=0
echo "Comparaison des images : $BASE → travail en cours"
echo ""

while IFS=$'\t' read -r f name tag; do
  old_tag="$(awk -F'\t' -v f="$f" -v n="$name" '$1==f && $2==n {print $3; exit}' "$OLD")"
  [ -z "$old_tag" ] && continue          # image nouvelle : rien à comparer
  [ "$old_tag" = "$tag" ] && continue    # inchangée

  om="$(major "$old_tag")"; nm="$(major "$tag")"
  svc="${f#services/}"; svc="${svc%/docker-compose.yml}"

  if [ -n "$om" ] && [ -n "$nm" ] && [ "$om" != "$nm" ]; then
    if grep -qiE "^($STATEFUL_DB)$" <<<"$name"; then
      echo "⛔ ROUGE   $svc — $name $old_tag → $tag"
      echo "           base de données : migration obligatoire, le conteneur ne démarrera pas sinon."
      RED=$((RED+1))
    elif grep -qiE "^($STATEFUL_APP)$" <<<"$name"; then
      echo "⚠️  ORANGE  $svc — $name $old_tag → $tag"
      echo "           migration de schéma au démarrage : sauvegarde + snapshot avant."
      ORANGE=$((ORANGE+1))
    elif grep -qiE "^($CACHE)$" <<<"$name"; then
      echo "⚠️  JAUNE   $svc — $name $old_tag → $tag  (cache, compatible ascendant)"
      YELLOW=$((YELLOW+1))
    else
      echo "⚠️  JAUNE   $svc — $name $old_tag → $tag  (majeure sans état)"
      YELLOW=$((YELLOW+1))
    fi
  else
    echo "✅ VERT    $svc — $name $old_tag → $tag"
    GREEN=$((GREEN+1))
  fi
done < "$NEW"

echo ""
echo "Bilan : $RED rouge(s) | $ORANGE orange(s) | $YELLOW jaune(s) | $GREEN vert(s)"

if [ "$RED" -gt 0 ] || [ "$ORANGE" -gt 0 ]; then
  echo ""
  echo "⛔ Changements exigeant une migration de données — NE PAS déployer tel quel."
  echo "   Par pile : snapshot Proxmox de la VM → sauvegarde/dump → migration →"
  echo "   smoke-test → rollback par snapshot en cas d'échec."
  exit 1
fi
echo "✅ Aucun changement exigeant une migration."

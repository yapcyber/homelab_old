#!/usr/bin/env bash
# =============================================================================
# nextcloud-sync-family.sh — à lancer sur la VM cloud (10.0.30.12)
#   bash nextcloud-sync-family.sh          # applique
#   DRY_RUN=1 bash nextcloud-sync-family.sh # simulation
# =============================================================================
# Ajoute au groupe Nextcloud "family" tous les comptes utilisateurs (hors admins
# / comptes techniques listés dans EXCLUDE). Comme l'accès à Nextcloud est
# restreint au groupe Authentik "family" (binding OIDC), tout compte créé via
# "Sign in with YapServer" est un membre family par construction — il suffit donc
# de l'ajouter au groupe local pour qu'il hérite des partages médias add-only.
#
# À relancer quand de nouveaux utilisateurs se sont connectés (ou via un timer).
# =============================================================================
set -uo pipefail
NC="${NC_CONTAINER:-nextcloud}"
GROUP="${NC_GROUP:-family}"
DRY_RUN="${DRY_RUN:-0}"
# Comptes à NE JAMAIS ajouter (admins / techniques). Adapter si besoin.
EXCLUDE="${NC_EXCLUDE:-admin adm-yanis}"

occ(){ docker exec -u www-data "$NC" php occ "$@"; }

echo "== Synchro du groupe Nextcloud '$GROUP' (DRY_RUN=$DRY_RUN) =="
# membres déjà présents dans le groupe
mapfile -t MEMBERS < <(occ group:list --output=json 2>/dev/null \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('\n'.join(d.get('$GROUP',[])))" 2>/dev/null)
is_member(){ local u="$1"; for m in "${MEMBERS[@]:-}"; do [ "$m" = "$u" ] && return 0; done; return 1; }

added=0
while read -r uid; do
  [ -z "$uid" ] && continue
  for e in $EXCLUDE; do [ "$uid" = "$e" ] && { uid=""; break; }; done
  [ -z "$uid" ] && continue
  if is_member "$uid"; then
    echo "  = $uid (déjà membre)"
  elif [ "$DRY_RUN" = "1" ]; then
    echo "  + $uid (serait ajouté)"; added=$((added+1))
  else
    if occ group:adduser "$GROUP" "$uid" >/dev/null 2>&1; then
      echo "  + $uid (ajouté)"; added=$((added+1))
    else
      echo "  ! $uid (échec ajout)"
    fi
  fi
done < <(occ user:list 2>/dev/null | sed -nE 's/^[[:space:]]*-[[:space:]]*([^:]+):.*/\1/p')

echo "== Terminé : $added ajout(s) au groupe '$GROUP' =="

#!/usr/bin/env bash
# =============================================================================
# scripts/migrate-postgres-major.sh — MIGRATION d'une majeure PostgreSQL.
# =============================================================================
# Une majeure PostgreSQL ne se change pas en éditant un tag : le répertoire de
# données porte la majeure qui l'a écrit, et le moteur refuse de démarrer sur un
# format qu'il ne connaît pas. Ce script fait la vraie migration (dump/restore),
# avec une copie du volume conservée comme levier de retour arrière.
#
#   ./scripts/migrate-postgres-major.sh <ip-vm> <conteneur-bdd> [--go]
#
# Sans --go : simulation (inspection + plan), rien n'est modifié.
#
# Tout est déduit du conteneur : projet compose, répertoire de travail, service,
# utilisateur, volume de données. Rien à saisir à la main, rien à deviner.
#
# Pré-requis : le dépôt doit être à jour sur la VM (le compose doit déjà porter
# la NOUVELLE image) — sinon le script redémarrerait l'ancienne majeure.
# =============================================================================
set -uo pipefail

IP="${1:-}"; CONTAINER="${2:-}"; GO="${3:-}"
[ -n "$IP" ] && [ -n "$CONTAINER" ] || { sed -n '5,12p' "$0"; exit 2; }

SSH=(ssh -o BatchMode=yes -o ConnectTimeout=8 "debian@$IP")
step() { echo ""; echo "▶ $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ⚠ $*" >&2; }
die()  { echo "  ❌ $*" >&2; exit 1; }
# Exécute une commande sur la VM, avec sudo si le socket docker l'exige.
rex()  { "${SSH[@]}" "$DOCKER $*"; }

step "Connexion et pré-requis"
"${SSH[@]}" true 2>/dev/null || die "VM $IP injoignable."
if "${SSH[@]}" 'docker ps >/dev/null 2>&1'; then DOCKER="docker"; else DOCKER="sudo docker"; fi
ok "Accès docker : $DOCKER"

# --- Inspection : tout déduire du conteneur ---------------------------------
step "Inspection de $CONTAINER"
read -r PROJECT WORKDIR SERVICE < <("${SSH[@]}" "$DOCKER inspect $CONTAINER --format \
  '{{index .Config.Labels \"com.docker.compose.project\"}} {{index .Config.Labels \"com.docker.compose.project.working_dir\"}} {{index .Config.Labels \"com.docker.compose.service\"}}'" 2>/dev/null)
[ -n "${PROJECT:-}" ] && [ -n "${WORKDIR:-}" ] || die "$CONTAINER introuvable ou hors compose."

PGUSER="$(rex "exec $CONTAINER printenv POSTGRES_USER" 2>/dev/null | tr -d '\r')"
[ -n "$PGUSER" ] || die "POSTGRES_USER introuvable dans $CONTAINER."
OLD_IMAGE="$(rex "inspect $CONTAINER --format '{{.Config.Image}}'" 2>/dev/null | tr -d '\r')"
VOLUME="$(rex "inspect $CONTAINER --format '{{range .Mounts}}{{if eq .Destination \\\"/var/lib/postgresql/data\\\"}}{{.Name}}{{end}}{{end}}'" 2>/dev/null | tr -d '\r')"
[ -n "$VOLUME" ] || VOLUME="$(rex "inspect $CONTAINER --format '{{range .Mounts}}{{if .Name}}{{.Name}} {{end}}{{end}}'" 2>/dev/null | awk '{print $1}' | tr -d '\r')"
[ -n "$VOLUME" ] || die "Volume de données introuvable pour $CONTAINER."
OLD_MAJOR="$(rex "exec $CONTAINER cat /var/lib/postgresql/data/PG_VERSION" 2>/dev/null | tr -d '\r' | cut -d. -f1)"

# Image cible : celle que déclare le compose à jour sur la VM.
NEW_IMAGE="$("${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose config --no-interpolate 2>/dev/null | grep -A3 -E '^  $SERVICE:' | sed -n 's/^ *image: *//p' | head -1" 2>/dev/null | tr -d '\r')"
[ -n "$NEW_IMAGE" ] || NEW_IMAGE="$("${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose config 2>/dev/null | awk '/^  $SERVICE:/{f=1} f&&/image:/{sub(/^ *image: */,\"\"); print; exit}'" 2>/dev/null | tr -d '\r')"

echo "  projet    : $PROJECT"
echo "  répertoire: $WORKDIR"
echo "  service   : $SERVICE"
echo "  utilisateur: $PGUSER"
echo "  volume    : $VOLUME"
echo "  majeure   : $OLD_MAJOR  (image actuelle : $OLD_IMAGE)"
echo "  cible     : ${NEW_IMAGE:-<indéterminée>}"

NEW_MAJOR="$(sed -E 's#.*/##; s/^[^:]*:v?//' <<<"${NEW_IMAGE:-}" | grep -oE '^[0-9]+' || true)"
if [ -z "$NEW_MAJOR" ]; then
  warn "Majeure cible indéterminée — vérifie que le dépôt est à jour sur la VM."
elif [ "$NEW_MAJOR" = "$OLD_MAJOR" ]; then
  ok "Déjà en majeure $OLD_MAJOR — rien à migrer."; exit 0
else
  ok "Migration $OLD_MAJOR → $NEW_MAJOR"
fi

# --- Garde-fou PostgreSQL 18+ : le point de montage a changé ----------------
# Depuis la 18, l'image officielle range les données par majeure sous
# /var/lib/postgresql/<major>/ et attend le montage sur /var/lib/postgresql.
# Un volume monté sur .../data est vu comme « unused mount/volume » et le
# conteneur boucle au démarrage. Le tag ET le montage doivent changer ensemble.
if [ -n "$NEW_MAJOR" ] && [ "$NEW_MAJOR" -ge 18 ] 2>/dev/null; then
  TARGET_MOUNT="$("${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose config 2>/dev/null \
    | awk '/^  $SERVICE:/{f=1} f&&/var\/lib\/postgresql/{print; exit}'" 2>/dev/null | tr -d '\r')"
  if grep -q '/var/lib/postgresql/data' <<<"${TARGET_MOUNT:-}"; then
    echo ""
    die "PostgreSQL $NEW_MAJOR attend le montage sur /var/lib/postgresql, pas sur
     /var/lib/postgresql/data — le conteneur bouclerait au démarrage.
     Corrige d'abord le compose (dépôt, puis pull sur la VM) :
         volumes: [ \"<vol>:/var/lib/postgresql\" ]
     Référence : docker-library/postgres#1259. Rien n'a été touché."
  fi
  ok "Point de montage compatible 18+."
fi

BACKUP_VOL="${VOLUME}-pre${OLD_MAJOR}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DUMP="/var/backups/homelab/pg-major/${CONTAINER}-${STAMP}.sql"

if [ "$GO" != "--go" ]; then
  echo ""
  echo "SIMULATION — relance avec --go pour exécuter. Plan :"
  echo "  1. pg_dumpall  → $DUMP (sur la VM)"
  echo "  2. compose down (volumes conservés)"
  echo "  3. copie du volume $VOLUME → $BACKUP_VOL (levier de retour)"
  echo "  4. purge de $VOLUME, démarrage de $SERVICE en majeure $NEW_MAJOR"
  echo "  5. restauration du dump, puis remontée de la pile"
  echo "  6. contrôles (tailles de bases, état des conteneurs)"
  exit 0
fi

# --- 1. Dump -----------------------------------------------------------------
step "1/6 — Dump complet (pg_dumpall)"
"${SSH[@]}" "sudo mkdir -p /var/backups/homelab/pg-major && sudo chmod 700 /var/backups/homelab/pg-major" || die "mkdir échoué."
"${SSH[@]}" "$DOCKER exec $CONTAINER pg_dumpall -U $PGUSER | sudo tee $DUMP >/dev/null" || die "pg_dumpall a échoué."
DUMP_SIZE="$("${SSH[@]}" "sudo stat -c%s $DUMP" 2>/dev/null || echo 0)"
[ "$DUMP_SIZE" -gt 1000 ] || die "Dump suspect (${DUMP_SIZE} octets) — abandon, rien n'a été touché."
"${SSH[@]}" "sudo grep -q 'PostgreSQL database cluster dump' $DUMP" || die "Dump sans en-tête attendu — abandon."
ok "Dump : $DUMP (${DUMP_SIZE} octets)"

# --- 2. Arrêt ----------------------------------------------------------------
step "2/6 — Arrêt de la pile"
"${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose down" || die "compose down a échoué."
ok "Pile arrêtée (volumes conservés)."

# --- 3. Copie du volume (levier de retour) ----------------------------------
step "3/6 — Copie de sauvegarde du volume"
rex "volume rm $BACKUP_VOL" >/dev/null 2>&1
rex "volume create $BACKUP_VOL" >/dev/null || die "Création de $BACKUP_VOL impossible."
"${SSH[@]}" "$DOCKER run --rm -v $VOLUME:/from:ro -v $BACKUP_VOL:/to alpine sh -c 'cp -a /from/. /to/'" \
  || die "Copie du volume échouée — rien n'a été purgé."
"${SSH[@]}" "$DOCKER run --rm -v $BACKUP_VOL:/d alpine test -f /d/PG_VERSION" \
  || die "Copie incomplète (PG_VERSION absent) — abandon."
ok "Volume copié → $BACKUP_VOL"

# --- 4. Purge + démarrage en nouvelle majeure -------------------------------
step "4/6 — Purge du volume et démarrage en majeure $NEW_MAJOR"
"${SSH[@]}" "$DOCKER run --rm -v $VOLUME:/d alpine sh -c 'rm -rf /d/..?* /d/.[!.]* /d/*'" || die "Purge échouée."
"${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose up -d $SERVICE" || die "Démarrage échoué."
for i in $(seq 1 30); do
  "${SSH[@]}" "$DOCKER exec $CONTAINER pg_isready -U $PGUSER" >/dev/null 2>&1 && break
  sleep 3
done
"${SSH[@]}" "$DOCKER exec $CONTAINER pg_isready -U $PGUSER" >/dev/null 2>&1 \
  || die "Le moteur n'accepte pas de connexion après 90 s. Retour arrière : voir la fin du script."
ok "PostgreSQL $NEW_MAJOR démarré sur un volume neuf."

# --- 5. Restauration ---------------------------------------------------------
step "5/6 — Restauration du dump"
"${SSH[@]}" "sudo cat $DUMP | $DOCKER exec -i $CONTAINER psql -U $PGUSER -d postgres -v ON_ERROR_STOP=0" >/dev/null 2>&1 \
  || warn "psql a signalé des erreurs (souvent bénignes : rôles/bases déjà présents)."
ok "Dump restauré."

step "6/6 — Remontée de la pile et contrôles"
"${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose up -d" || warn "compose up a signalé une erreur."
sleep 10
echo "  --- bases après migration ---"
"${SSH[@]}" "$DOCKER exec $CONTAINER psql -U $PGUSER -d postgres -tAc \
  'SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database WHERE NOT datistemplate;'" 2>/dev/null | sed 's/^/    /'
echo "  --- conteneurs ---"
"${SSH[@]}" "cd '$WORKDIR' && $DOCKER compose ps --format '{{.Name}}\t{{.Status}}'" 2>/dev/null | sed 's/^/    /'

echo ""
echo "✅ Migration $OLD_MAJOR → $NEW_MAJOR terminée pour $CONTAINER."
echo ""
echo "Vérifie l'application, puis libère la copie :"
echo "    ssh debian@$IP '$DOCKER volume rm $BACKUP_VOL'"
echo ""
echo "RETOUR ARRIÈRE (si l'application ne fonctionne pas) :"
echo "    ssh debian@$IP \"cd '$WORKDIR' && $DOCKER compose down\""
echo "    ssh debian@$IP '$DOCKER run --rm -v $BACKUP_VOL:/from:ro -v $VOLUME:/to alpine sh -c \"rm -rf /to/* ; cp -a /from/. /to/\"'"
echo "    # puis remettre l'ancienne image ($OLD_IMAGE) dans le compose et redéployer"

#!/usr/bin/env bash
# =============================================================================
# media-sort-gaming.sh — tri des dépôts (inbox -> bibliothèque) sur le PC gaming
# =============================================================================
# Approche "validation" : on NE devine RIEN. Un fichier/dossier est rangé
# seulement s'il respecte déjà la convention de nommage (cf. doc). Sinon il part
# en _quarantaine (jamais supprimé). Ne traite que les éléments STABLES (plus
# modifiés depuis STABLE_MIN minutes = upload terminé).
#
# Lancement (cron/systemd, toutes les ~15 min), en root ou via jellyfin :
#   DRY_RUN=1 bash media-sort-gaming.sh     # simulation (défaut) — À FAIRE D'ABORD
#   DRY_RUN=0 bash media-sort-gaming.sh     # exécution réelle
# =============================================================================
set -uo pipefail

D="${MEDIA_ROOT:-/mnt/d}"
INBOX="$D/_inbox"
QUAR="$D/_quarantaine"
LOG="${MEDIA_LOG:-/var/log/media-sort.log}"
STABLE_MIN="${STABLE_MIN:-5}"       # minutes sans modif = upload fini
DRY_RUN="${DRY_RUN:-1}"             # 1 = simulation (défaut, sûr)
NTFY="${NTFY_URL:-}"               # ex: http://10.0.30.11:8082/homelab (best-effort)

# type -> dossier cible (dans $D)
declare -A DEST=(
  [films]="Jellyfin/Films"      [series]="Jellyfin/Séries"
  [anime]="Jellyfin/Anime"      [cartoons]="Jellyfin/Cartoons"
  [music]="Navidrome/Musique"   [livres]="Kavita/eBook"
  [livres-audio]="AudioBookShelf" [comics]="Kavita/Comics"
  [manga]="Kavita/Manga"        [roms]="RomM"
)
# extensions autorisées par famille
VIDEO='mkv|mp4|avi|m4v|mov|ts|webm'
AUDIO='flac|mp3|m4a|m4b|ogg|opus|wav|aac'
EBOOK='epub|pdf|mobi|azw3|djvu'
COMIC='cbz|cbr|pdf'

log(){ echo "$(date '+%F %T') $*" | tee -a "$LOG" ; }
notify(){ [ -n "$NTFY" ] && curl -s -m 5 -H "Title: Tri média" -d "$1" "$NTFY" >/dev/null 2>&1 || true ; }

# valide le NOM d'un item selon son type. 0 = conforme, 1 = à mettre en quarantaine.
valide(){
  local type="$1" name="$2" ext="${2##*.}"; ext="${ext,,}"
  case "$type" in
    films|anime|cartoons)
      [[ "$name" =~ \([0-9]{4}\) ]] && [[ "$ext" =~ ^($VIDEO)$ ]] ;;
    series)
      [[ "$name" =~ [Ss][0-9]{1,2}[Ee][0-9]{1,3} ]] && [[ "$ext" =~ ^($VIDEO)$ ]] ;;
    music)         [[ "$ext" =~ ^($AUDIO)$ ]] ;;
    livres)        [[ "$ext" =~ ^($EBOOK)$ ]] ;;
    livres-audio)  [[ "$ext" =~ ^($AUDIO)$ ]] ;;
    comics|manga)  [[ "$ext" =~ ^($COMIC)$ ]] ;;
    roms)          [[ -n "$ext" && "$ext" != "$name" ]] ;;  # a une extension (RomM valide le reste)
    *) return 1 ;;
  esac
}

move_to(){  # $1 src, $2 dossier cible
  local src="$1" dst="$2"
  if [ "$DRY_RUN" = "1" ]; then log "[SIM] ranger  : $src -> $dst/"; return; fi
  mkdir -p "$dst"
  if mv -n "$src" "$dst/"; then log "[OK]  rangé   : $(basename "$src") -> $dst/"
  else log "[ERR] échec mv: $src"; fi
}
quarantine(){  # $1 src, $2 raison
  local src="$1"
  if [ "$DRY_RUN" = "1" ]; then log "[SIM] quaran. : $src ($2)"; return; fi
  mkdir -p "$QUAR"; mv -n "$src" "$QUAR/" && log "[QUAR] $(basename "$src") ($2)"
  notify "À corriger : $(basename "$src") — $2"
}

[ -d "$INBOX" ] || { log "inbox absente: $INBOX"; exit 1; }
log "=== tri démarré (DRY_RUN=$DRY_RUN, stable>${STABLE_MIN}min) ==="

for type in "${!DEST[@]}"; do
  dir="$INBOX/$type"; [ -d "$dir" ] || continue
  dest="$D/${DEST[$type]}"
  # éléments de 1er niveau seulement (fichier OU dossier, ex. une saison de série)
  find "$dir" -mindepth 1 -maxdepth 1 -mmin +"$STABLE_MIN" -print0 2>/dev/null |
  while IFS= read -r -d '' item; do
    base="$(basename "$item")"
    # sécurité : ignorer les temporaires/cachés d'upload
    case "$base" in .*|*.part|*.tmp|*.crdownload) continue ;; esac
    if [ -d "$item" ]; then
      # dossier (série/album) : rangé tel quel, validation légère sur le nom
      move_to "$item" "$dest"
    elif valide "$type" "$base"; then
      move_to "$item" "$dest"
    else
      quarantine "$item" "nom non conforme ($type)"
    fi
  done
done
log "=== tri terminé ==="

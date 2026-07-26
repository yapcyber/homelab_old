#!/usr/bin/env bash
# =============================================================================
# media-sort-gaming.sh — tri des dépôts (inbox -> bibliothèque) sur le PC gaming
# =============================================================================
# Approche "validation" : on NE devine RIEN. Un élément est rangé seulement s'il
# respecte la convention (cf. doc), sinon il part en _quarantaine (jamais
# supprimé). Ne traite que les éléments STABLES (plus modifiés depuis STABLE_MIN
# minutes = upload terminé).
#
# ROMs : rangées PAR PLATEFORME. L'utilisateur dépose dans _inbox/roms/<console>/
# (ex. roms/ps/). Un fichier laissé à la racine roms/ part en quarantaine.
#
#   DRY_RUN=1 bash media-sort-gaming.sh   # simulation (défaut, sûr) — À FAIRE D'ABORD
#   DRY_RUN=0 bash media-sort-gaming.sh   # exécution réelle (sudo requis)
# =============================================================================
set -uo pipefail

D="${MEDIA_ROOT:-/mnt/d}"
INBOX="$D/_inbox"
QUAR="$D/_quarantaine"
LOG="${MEDIA_LOG:-/var/log/media-sort.log}"
STABLE_MIN="${STABLE_MIN:-5}"
DRY_RUN="${DRY_RUN:-1}"
NTFY="${NTFY_URL:-}"

# type -> dossier cible (hors roms, traité à part)
declare -A DEST=(
  [films]="Jellyfin/Films"      [series]="Jellyfin/Séries"
  [anime]="Jellyfin/Anime"      [cartoons]="Jellyfin/Cartoons"
  [music]="Navidrome/Musique"   [livres]="Kavita/eBook"
  [livres-audio]="AudioBookShelf" [comics]="Kavita/Comics"
  [manga]="Kavita/Manga"
)
VIDEO='mkv|mp4|avi|m4v|mov|ts|webm'
AUDIO='flac|mp3|m4a|m4b|ogg|opus|wav|aac'
EBOOK='epub|pdf|mobi|azw3|djvu'
COMIC='cbz|cbr|pdf'
# plateformes RomM reconnues (dossiers valides sous roms/)
ROM_PLATFORMS='nes snes n64 gc wii gb gbc gba nds 3ds ps ps2 psp sms genesis gamegear saturn dreamcast segacd arcade atari2600 pcengine neogeo'

log(){ echo "$(date '+%F %T') $*" | tee -a "$LOG" ; }
notify(){ [ -n "$NTFY" ] && curl -s -m 5 -H "Title: Tri média" -d "$1" "$NTFY" >/dev/null 2>&1 || true ; }

valide(){  # $1 type, $2 nom
  local type="$1" name="$2" ext="${2##*.}"; ext="${ext,,}"
  case "$type" in
    films|anime|cartoons) [[ "$name" =~ \([0-9]{4}\) ]] && [[ "$ext" =~ ^($VIDEO)$ ]] ;;
    series)               [[ "$name" =~ [Ss][0-9]{1,2}[Ee][0-9]{1,3} ]] && [[ "$ext" =~ ^($VIDEO)$ ]] ;;
    music)                [[ "$ext" =~ ^($AUDIO)$ ]] ;;
    livres)               [[ "$ext" =~ ^($EBOOK)$ ]] ;;
    livres-audio)         [[ "$ext" =~ ^($AUDIO)$ ]] ;;
    comics|manga)         [[ "$ext" =~ ^($COMIC)$ ]] ;;
    *) return 1 ;;
  esac
}
move_to(){ local src="$1" dst="$2"
  if [ "$DRY_RUN" = "1" ]; then log "[SIM] ranger  : $src -> $dst/"; return; fi
  mkdir -p "$dst"; mv -n "$src" "$dst/" && log "[OK]  rangé   : $(basename "$src") -> $dst/" || log "[ERR] échec mv: $src" ; }
quarantine(){ local src="$1"
  if [ "$DRY_RUN" = "1" ]; then log "[SIM] quaran. : $src ($2)"; return; fi
  mkdir -p "$QUAR"; mv -n "$src" "$QUAR/" && log "[QUAR] $(basename "$src") ($2)"; notify "À corriger : $(basename "$src") — $2" ; }

[ -d "$INBOX" ] || { log "inbox absente: $INBOX"; exit 1; }
log "=== tri démarré (DRY_RUN=$DRY_RUN, stable>${STABLE_MIN}min) ==="

# --- Types classiques (validation par nommage) ---
for type in "${!DEST[@]}"; do
  dir="$INBOX/$type"; [ -d "$dir" ] || continue
  dest="$D/${DEST[$type]}"
  find "$dir" -mindepth 1 -maxdepth 1 -mmin +"$STABLE_MIN" -print0 2>/dev/null |
  while IFS= read -r -d '' item; do
    base="$(basename "$item")"
    case "$base" in .*|*.part|*.tmp|*.crdownload) continue ;; esac
    if [ -d "$item" ]; then move_to "$item" "$dest"
    elif valide "$type" "$base"; then move_to "$item" "$dest"
    else quarantine "$item" "nom non conforme ($type)"; fi
  done
done

# --- ROMs : rangées par plateforme (roms/<console>/ -> RomM/roms/<console>/) ---
rdir="$INBOX/roms"
if [ -d "$rdir" ]; then
  # 1) fichiers laissés à la racine roms/ (sans console) -> quarantaine
  find "$rdir" -mindepth 1 -maxdepth 1 -type f -mmin +"$STABLE_MIN" -print0 2>/dev/null |
  while IFS= read -r -d '' item; do
    base="$(basename "$item")"; case "$base" in .*|*.part|*.tmp) continue ;; esac
    quarantine "$item" "ROM sans console : range-la dans roms/<console>/ (ex. roms/ps/)"
  done
  # 2) contenu des sous-dossiers de plateforme reconnus
  for plat in $ROM_PLATFORMS; do
    pdir="$rdir/$plat"; [ -d "$pdir" ] || continue
    find "$pdir" -mindepth 1 -maxdepth 1 -mmin +"$STABLE_MIN" -print0 2>/dev/null |
    while IFS= read -r -d '' item; do
      base="$(basename "$item")"; case "$base" in .*|*.part|*.tmp) continue ;; esac
      move_to "$item" "$D/RomM/roms/$plat"
    done
  done
fi
log "=== tri terminé ==="

#!/usr/bin/env bash
# =============================================================================
# setup-media-inbox-gaming.sh — à lancer SUR le PC gaming (Linux/Ubuntu)
#   sudo bash setup-media-inbox-gaming.sh
# =============================================================================
# Crée l'arborescence de dépôt (inbox add-only par type + quarantaine) sur le
# disque médias /mnt/d, un compte Samba d'upload dédié (nextcloud-writer), et un
# partage SMB [Inbox] en écriture — SANS toucher au partage [Media] existant
# (read-only). Le tri (inbox -> bibliothèque) se fera par un script séparé.
# =============================================================================
set -euo pipefail
D=/mnt/d
[ -d "$D/Jellyfin" ] || { echo "❌ $D/Jellyfin introuvable — mauvais disque ?"; exit 1; }

echo "== 1. Arborescence de dépôt =="
mkdir -p "$D"/_inbox/{films,series,anime,cartoons,music,livres,comics,manga,roms}
mkdir -p "$D"/_quarantaine
# NTFS : chown best-effort (les droits réels viennent du montage + force user Samba)
chown -R jellyfin:jellyfin "$D/_inbox" "$D/_quarantaine" 2>/dev/null || true
echo "   ok : $D/_inbox/{9 types} + $D/_quarantaine"

echo "== 2. Compte d'upload dédié (système + Samba) =="
id nextcloud-writer >/dev/null 2>&1 || \
  useradd --no-create-home --shell /usr/sbin/nologin nextcloud-writer
echo "   >>> Définis le mot de passe SAMBA de 'nextcloud-writer'"
echo "       (tu le ressaisiras dans Nextcloud pour l'External Storage) :"
smbpasswd -a nextcloud-writer

echo "== 3. Partage SMB [Inbox] en écriture =="
if ! grep -q '^\[Inbox\]' /etc/samba/smb.conf; then
  cat >> /etc/samba/smb.conf <<'EOF'

[Inbox]
   path = /mnt/d/_inbox
   browseable = yes
   read only = no
   valid users = nextcloud-writer
   force user = jellyfin
   create mask = 0664
   directory mask = 0775
EOF
  echo "   partage [Inbox] ajouté à smb.conf"
else
  echo "   partage [Inbox] déjà présent"
fi

echo "== 4. Validation + rechargement Samba =="
testparm -s >/dev/null
systemctl reload smbd 2>/dev/null || systemctl reload smb 2>/dev/null || service smbd reload
echo ""
echo "✅ Terminé."
echo "   Partage d'upload : //10.0.90.100/Inbox  (compte: nextcloud-writer)"
echo "   Partage lecture  : //10.0.90.100/Media   (inchangé, read-only)"
echo "   → Donne-moi le feu vert : je branche l'External Storage Nextcloud dessus."

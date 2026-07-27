#!/usr/bin/env bash
# =============================================================================
# scripts/backup-restic-drive.sh — Sauvegarde HORS-SITE chiffrée vers Google
# Drive, via restic (chiffrement + versioning côté client) sur backend rclone.
# =============================================================================
# Tourne sur le poste de contrôle (EliteBook), qui seul a les clés SSH de toutes
# les VM. Pour chaque VM du groupe 'services' ayant des sauvegardes :
#   - streame le DERNIER 'daily' + sa clé /etc/homelab-backup.key en tar-over-ssh
#     directement dans restic (rien à installer sur les VM, aucun fichier temporaire) ;
#   - restic chiffre CÔTÉ CLIENT → Google ne voit que du chiffré (indispensable :
#     plusieurs dumps sont en clair) ;
#   - rétention 7 quotidiennes / 4 hebdo / 6 mensuelles par hôte, puis contrôle d'intégrité.
#
# Pré-requis (voir docs/runbooks/sauvegarde-restic-drive.md) :
#   - restic + rclone installés ; remote rclone 'gdrive' configuré (OAuth) ;
#   - mot de passe restic dans scripts/restic-drive.enc.env (SOPS).
# =============================================================================
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRET="$REPO_DIR/scripts/restic-drive.enc.env"
RCLONE_REMOTE="${RCLONE_REMOTE:-gdrive}"
export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-rclone:${RCLONE_REMOTE}:homelab-restic}"
SSH_OPTS=(-o ConnectTimeout=8 -o BatchMode=yes)

die() { echo "❌ $*" >&2; exit 1; }

command -v restic >/dev/null 2>&1 || die "restic absent → sudo apt install restic"
command -v rclone >/dev/null 2>&1 || die "rclone absent → sudo apt install rclone"
command -v sops   >/dev/null 2>&1 || die "sops absent"
rclone listremotes 2>/dev/null | grep -qx "${RCLONE_REMOTE}:" \
  || die "remote rclone '${RCLONE_REMOTE}:' introuvable → configure-le : rclone config"

# --- Mot de passe restic depuis SOPS (jamais écrit sur disque) ---------------
RESTIC_PASSWORD="$(sops -d "$SECRET" 2>/dev/null | sed -n 's/^RESTIC_PASSWORD=//p')"
[ -n "$RESTIC_PASSWORD" ] || die "RESTIC_PASSWORD introuvable dans $SECRET"
export RESTIC_PASSWORD

# --- Init du dépôt si absent -------------------------------------------------
if ! restic snapshots >/dev/null 2>&1; then
  echo "→ Dépôt restic absent sur ${RESTIC_REPOSITORY} — initialisation ..."
  restic init || die "restic init a échoué (remote/OAuth ?)"
fi

# --- Énumération des hôtes 'services' ---------------------------------------
mapfile -t HOSTS < <(cd "$REPO_DIR/ansible" 2>/dev/null && ansible-inventory -i inventory/hosts.yml --list 2>/dev/null \
  | jq -r '.services.hosts[] as $h | "\($h) \(._meta.hostvars[$h].ansible_host)"' 2>/dev/null)
if [ "${#HOSTS[@]}" -eq 0 ]; then
  HOSTS=( "infra 10.0.30.10" "monitoring 10.0.30.11" "cloud 10.0.30.12" "media 10.0.30.13" \
          "security 10.0.30.14" "scanner 10.0.30.15" "firefly 10.0.30.16" "osint 10.0.30.17" "ir 10.0.30.18" )
fi

# --- Sauvegarde par hôte : dernier daily + clé -> restic (stdin) -------------
OK=0; SKIP=0; FAIL=0
for entry in "${HOSTS[@]}"; do
  host="${entry%% *}"; ip="${entry##* }"
  printf '• %-11s (%s) ... ' "$host" "$ip"
  latest="$(ssh "${SSH_OPTS[@]}" "debian@$ip" 'sudo sh -c "ls -1 /var/backups/homelab/daily 2>/dev/null | sort | tail -1"' 2>/dev/null)"
  if [ -z "$latest" ]; then echo "aucun backup — ignoré"; SKIP=$((SKIP+1)); continue; fi

  # tar : le dernier daily + la clé openssl de la VM, streamés dans restic
  if ssh "${SSH_OPTS[@]}" "debian@$ip" \
        "sudo tar cf - -C /var/backups/homelab/daily '$latest' -C /etc homelab-backup.key" 2>/dev/null \
     | restic backup --stdin --stdin-filename "${host}-daily.tar" \
         --host "$host" --tag offsite --tag "$host" >/dev/null 2>&1; then
    echo "OK ($latest)"; OK=$((OK+1))
  else
    echo "ÉCHEC"; FAIL=$((FAIL+1))
  fi
done

# --- OPNsense : configuration du pare-feu -> restic --------------------------
# config.xml porte des SECRETS EN CLAIR (clé privée WireGuard, hashes de comptes,
# token DDNS Cloudflare, clés API). Il ne touche le disque que dans un fichier
# 0600 détruit en sortie, et ne quitte la machine QUE chiffré par restic.
# Ne JAMAIS le committer, ni le laisser dans /tmp.
backup_opnsense() {
  local secret="$REPO_DIR/scripts/opnsense-api.enc.env"
  local url key sec pin tmpd xml size

  if [ ! -f "$secret" ]; then
    echo "• opnsense    ... non configuré ($(basename "$secret") absent) — ignoré"
    SKIP=$((SKIP+1)); return 0
  fi
  printf '• %-11s ... ' "opnsense"
  if ! command -v xmllint >/dev/null 2>&1; then
    echo "ÉCHEC (xmllint absent → sudo apt install libxml2-utils)"; FAIL=$((FAIL+1)); return 1
  fi

  # Secrets déchiffrés en mémoire uniquement
  local env_out; env_out="$(sops -d "$secret" 2>/dev/null)" || {
    echo "ÉCHEC (déchiffrement SOPS)"; FAIL=$((FAIL+1)); return 1; }
  url="$(sed -n 's/^OPNSENSE_URL=//p'            <<<"$env_out")"
  key="$(sed -n 's/^OPNSENSE_API_KEY=//p'        <<<"$env_out")"
  sec="$(sed -n 's/^OPNSENSE_API_SECRET=//p'     <<<"$env_out")"
  pin="$(sed -n 's/^OPNSENSE_PINNED_PUBKEY=//p'  <<<"$env_out")"
  unset env_out
  if [ -z "$url" ] || [ -z "$key" ] || [ -z "$sec" ]; then
    echo "ÉCHEC (OPNSENSE_URL / _API_KEY / _API_SECRET manquants)"; FAIL=$((FAIL+1)); return 1
  fi

  tmpd="$(mktemp -d)" || { echo "ÉCHEC (mktemp)"; FAIL=$((FAIL+1)); return 1; }
  chmod 700 "$tmpd"; xml="$tmpd/config.xml"
  # shellcheck disable=SC2064
  trap "shred -u '$xml' 2>/dev/null; rm -rf '$tmpd'" RETURN

  # Cert du pare-feu = auto-signé -> -k, mais la clé publique est ÉPINGLÉE si
  # OPNSENSE_PINNED_PUBKEY est fourni (protection MITM réelle, sans fichier CA).
  local curl_args=(-sS --fail --max-time 60 -k -u "$key:$sec")
  [ -n "$pin" ] && curl_args+=(--pinnedpubkey "$pin")
  if ! curl "${curl_args[@]}" -o "$xml" "$url/api/core/backup/download/this" 2>/dev/null; then
    echo "ÉCHEC (API injoignable / auth refusée / épinglage rejeté)"; FAIL=$((FAIL+1)); return 1
  fi

  # Validation fail-closed : on refuse de sauvegarder un fichier inexploitable.
  # (Régression connue OPNsense 25.7.3 : XML renvoyé échappé en HTML.)
  size="$(stat -c%s "$xml" 2>/dev/null || echo 0)"
  if [ "$size" -lt 10000 ]; then
    echo "ÉCHEC (config.xml suspect : ${size} octets)"; FAIL=$((FAIL+1)); return 1
  fi
  if grep -q '&lt;opnsense&gt;' "$xml"; then
    echo "ÉCHEC (XML échappé en HTML — régression API ; voir runbook, repli SSH)"
    FAIL=$((FAIL+1)); return 1
  fi
  if ! xmllint --noout "$xml" 2>/dev/null || ! grep -q '<opnsense>' "$xml"; then
    echo "ÉCHEC (XML invalide ou racine <opnsense> absente)"; FAIL=$((FAIL+1)); return 1
  fi

  if restic backup --stdin --stdin-filename "opnsense-config.xml" \
       --host opnsense --tag offsite --tag opnsense < "$xml" >/dev/null 2>&1; then
    echo "OK (config.xml, ${size} octets)"; OK=$((OK+1))
  else
    echo "ÉCHEC (restic)"; FAIL=$((FAIL+1)); return 1
  fi
}
backup_opnsense

# --- Rétention + intégrité ---------------------------------------------------
echo "→ Rétention (7j/4s/6m par hôte) ..."
restic forget --group-by host --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune >/dev/null 2>&1 \
  || echo "⚠️  restic forget/prune a signalé une erreur."
echo "→ Contrôle d'intégrité ..."
restic check >/dev/null 2>&1 && echo "   intégrité OK" || echo "⚠️  restic check a signalé une erreur."

echo ""
echo "📦 Hors-site Drive : $OK copié(s) | $SKIP ignoré(s) | $FAIL échec(s)  →  ${RESTIC_REPOSITORY}"
[ "$FAIL" -eq 0 ] || exit 1
echo "✅ Terminé."

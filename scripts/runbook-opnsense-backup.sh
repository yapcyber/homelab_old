#!/usr/bin/env bash
# =============================================================================
# scripts/runbook-opnsense-backup.sh — ACTIVATION de la sauvegarde OPNsense.
# =============================================================================
# À lancer UNE FOIS, sur le POSTE DE CONTRÔLE (celui qui a la clé age SOPS).
# Idempotent : re-lançable sans risque.
#
#   ./scripts/runbook-opnsense-backup.sh [chemin/vers/apikey.txt]
#
# Enchaîne les étapes 1, 3, 4 et 5 du runbook : outil xmllint → empreinte TLS
# du pare-feu → secret SOPS → test de bout en bout.
# L'étape 2 (groupe + utilisateur + clé API dans l'UI OPNsense) est manuelle et
# doit être faite AVANT : voir docs/runbooks/sauvegarde-opnsense-drive.md
#
# Le fichier apikey.txt contient un SECRET : il n'est jamais recopié en clair
# dans le dépôt, et le script propose de l'effacer à la fin.
# =============================================================================
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGE_KEY="$HOME/.config/sops/age/keys.txt"
SECRET_FILE="$REPO_DIR/scripts/opnsense-api.enc.env"
OPNSENSE_URL="${OPNSENSE_URL:-https://10.0.100.1}"
APIKEY_FILE="${1:-}"

step() { echo ""; echo "▶ $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ⚠ $*" >&2; }
die()  { echo "  ❌ $*" >&2; exit 1; }

TMPD="$(mktemp -d)" || die "mktemp impossible."
chmod 700 "$TMPD"
cleanup() { find "$TMPD" -type f -exec shred -u {} + 2>/dev/null; rm -rf "$TMPD"; }
trap cleanup EXIT

# --- 0. Pré-vérifications ----------------------------------------------------
step "Pré-vérifications du poste"
command -v sops >/dev/null 2>&1 || die "sops absent : ce n'est pas le poste de contrôle."
[ -f "$AGE_KEY" ] || die "Clé age SOPS absente ($AGE_KEY) : mauvais poste."
[ -f "$REPO_DIR/scripts/backup-restic-drive.sh" ] || die "Script de sauvegarde introuvable."
command -v openssl >/dev/null 2>&1 || die "openssl absent."
ok "Poste de contrôle confirmé."

if [ -f "$SECRET_FILE" ]; then
  warn "$(basename "$SECRET_FILE") existe déjà — il sera REMPLACÉ."
  read -r -p "  Continuer ? [o/N] " a; [ "$a" = "o" ] || die "Abandon."
fi

# --- 1. Outil xmllint --------------------------------------------------------
step "[Étape 1] Outil de validation XML"
if command -v xmllint >/dev/null 2>&1; then
  ok "xmllint déjà présent."
else
  echo "  Installation de libxml2-utils (sudo) ..."
  sudo apt update -qq && sudo apt install -y libxml2-utils || die "Installation échouée."
  ok "xmllint installé."
fi

# --- 2. Lecture de la clé API (produite à l'étape 2, dans l'UI) --------------
step "[Étape 2] Clé API du compte svc-backup"
if [ -z "$APIKEY_FILE" ]; then
  echo "  Fichier apikey.txt téléchargé depuis OPNsense"
  echo "  (System → Access → Users → svc-backup → API keys)."
  read -r -p "  Chemin du fichier : " APIKEY_FILE
fi
[ -f "$APIKEY_FILE" ] || die "Fichier introuvable : $APIKEY_FILE"

API_KEY="$(sed -n 's/^key=//p'    "$APIKEY_FILE" | tr -d '\r\n')"
API_SECRET="$(sed -n 's/^secret=//p' "$APIKEY_FILE" | tr -d '\r\n')"
[ -n "$API_KEY" ] && [ -n "$API_SECRET" ] || die "key= / secret= introuvables dans $APIKEY_FILE"
ok "Clé lue (identifiant ${API_KEY:0:8}…, secret masqué)."

# --- 3. Empreinte de la clé publique TLS du pare-feu ------------------------
step "[Étape 3] Empreinte TLS du pare-feu"
HOST="${OPNSENSE_URL#*://}"; HOST="${HOST%%/*}"; HOST="${HOST%%:*}"
echo "  Cible : $HOST:443"
PIN_B64="$(openssl s_client -connect "$HOST:443" </dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout 2>/dev/null \
  | openssl pkey -pubin -outform der 2>/dev/null \
  | openssl dgst -sha256 -binary 2>/dev/null | base64)"
[ -n "$PIN_B64" ] || die "Impossible de récupérer le certificat de $HOST (pare-feu joignable ? VPN ?)."
PIN="sha256//$PIN_B64"
ok "Empreinte : $PIN"

# --- 4. Test des identifiants AVANT de les enregistrer ----------------------
step "[Étape 4] Test de l'accès API (avant enregistrement)"
if ! curl -sS --fail --max-time 30 -k --pinnedpubkey "$PIN" \
      -u "$API_KEY:$API_SECRET" \
      -o "$TMPD/config.xml" "$OPNSENSE_URL/api/core/backup/download/this" 2>"$TMPD/curl.err"; then
  echo "  --- détail curl ---"; cat "$TMPD/curl.err" >&2
  die "Appel API refusé. Vérifier le privilège 'Diagnostics: Configuration History' du groupe backup."
fi
SIZE="$(stat -c%s "$TMPD/config.xml" 2>/dev/null || echo 0)"
[ "$SIZE" -ge 10000 ] || die "config.xml suspect (${SIZE} octets) — réponse d'erreur ou page de login ?"
grep -q '&lt;opnsense&gt;' "$TMPD/config.xml" && die "XML échappé en HTML (régression API) — voir le runbook, section Dépannage."
xmllint --noout "$TMPD/config.xml" 2>/dev/null || die "XML mal formé."
grep -q '<opnsense>' "$TMPD/config.xml" || die "Racine <opnsense> absente."
ok "Configuration récupérée et valide (${SIZE} octets)."

# --- 5. Écriture du secret chiffré SOPS -------------------------------------
step "[Étape 5] Secret SOPS"
umask 077
cat > "$TMPD/opn.env" <<EOF
OPNSENSE_URL=$OPNSENSE_URL
OPNSENSE_API_KEY=$API_KEY
OPNSENSE_API_SECRET=$API_SECRET
OPNSENSE_PINNED_PUBKEY=$PIN
EOF
# SOPS choisit sa règle de chiffrement d'après le chemin du fichier d'ENTRÉE, et
# cherche .sops.yaml au-dessus de lui : un fichier dans /tmp ne correspond à
# aucune règle. D'où --filename-override + exécution depuis la racine du dépôt
# (convention déjà en place dans scripts/sops-runbook.sh).
# On écrit dans un temporaire : une redirection directe créerait un fichier vide
# avant même de savoir si sops réussit.
if ! (cd "$REPO_DIR" && sops --encrypt --filename-override "${SECRET_FILE##*/}" \
        "$TMPD/opn.env") > "$TMPD/opn.enc" 2>"$TMPD/sops.err"; then
  echo "  --- détail sops ---"; cat "$TMPD/sops.err" >&2
  die "Chiffrement SOPS échoué (rien n'a été écrit)."
fi
[ -s "$TMPD/opn.enc" ] || die "Sortie SOPS vide (rien n'a été écrit)."
mv "$TMPD/opn.enc" "$SECRET_FILE"
chmod 600 "$SECRET_FILE"
sops -d "$SECRET_FILE" >/dev/null 2>&1 || die "Relecture du secret chiffré impossible."
ok "$(basename "$SECRET_FILE") écrit et relu."

if grep -q "$API_SECRET" "$SECRET_FILE" 2>/dev/null; then
  rm -f "$SECRET_FILE"; die "SECRET EN CLAIR dans le fichier chiffré — abandon, rien n'est conservé."
fi
ok "Contrôle : aucun secret en clair dans le fichier versionné."

# --- 6. Sauvegarde réelle ----------------------------------------------------
step "[Étape 6] Sauvegarde hors-site complète"
echo "  Lancement de backup-restic-drive.sh (toutes les VM + le pare-feu) ..."
if "$REPO_DIR/scripts/backup-restic-drive.sh"; then
  ok "Sauvegarde terminée."
else
  warn "Le script a signalé au moins un échec — lire la sortie ci-dessus."
fi

# --- 7. Vérification du snapshot --------------------------------------------
step "[Étape 7] Vérification du snapshot OPNsense"
RESTIC_PASSWORD="$(sops -d "$REPO_DIR/scripts/restic-drive.enc.env" 2>/dev/null | sed -n 's/^RESTIC_PASSWORD=//p')"
if [ -n "$RESTIC_PASSWORD" ] && command -v restic >/dev/null 2>&1; then
  export RESTIC_PASSWORD
  export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-rclone:gdrive:homelab-restic}"
  restic snapshots --host opnsense 2>/dev/null | tail -5 || warn "Aucun snapshot 'opnsense' listé."
else
  warn "Vérification ignorée (restic ou mot de passe indisponible)."
fi

# --- 8. Hygiène du fichier de clé -------------------------------------------
step "[Étape 8] Hygiène"
echo "  $APIKEY_FILE contient le secret API en clair."
read -r -p "  L'effacer définitivement (shred) ? [o/N] " a
if [ "$a" = "o" ]; then shred -u "$APIKEY_FILE" && ok "Effacé."; else warn "Conservé — à ranger dans Vaultwarden puis effacer."; fi

echo ""
echo "✅ Terminé. Reste à versionner le secret chiffré :"
echo "     cd $REPO_DIR && git add scripts/opnsense-api.enc.env \\"
echo "       && git commit -m 'feat(backup): secret API OPNsense' && git push"

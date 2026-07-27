# Sauvegarde de la configuration OPNsense vers Google Drive

Ajoute le **pare-feu** à la chaîne hors-site existante
([sauvegarde-restic-drive.md](sauvegarde-restic-drive.md)). OPNsense était le seul
élément critique du homelab sans sauvegarde automatisée : sa perte imposait de
reconstruire à la main VLANs, règles, DHCP Kea, Unbound, WireGuard et DDNS.

## Principe

    poste de contrôle ──API HTTPS (clé épinglée)──▶ OPNsense /api/core/backup/download/this
                       ──restic (chiffré côté client)──▶ rclone ──▶ Google Drive

- **Tiré depuis le poste de contrôle**, pas poussé par le pare-feu. Le pare-feu
  ne reçoit donc **aucun identifiant Google** et n'a besoin d'aucun accès sortant
  supplémentaire — on n'élargit pas la surface d'attaque de l'équipement de bord.
- **Un seul job hors-site** : la fonction `backup_opnsense()` est intégrée à
  `scripts/backup-restic-drive.sh`, donc couverte par le timer quotidien, la
  rétention (7j/4s/6m) et le `restic check` déjà en place.
- **Snapshot restic dédié** : hôte `opnsense`, tags `offsite` + `opnsense`.

> ⚠️ **`config.xml` contient des secrets en clair** : clé privée WireGuard, hashes
> des comptes, token DDNS Cloudflare, clés API. Le script ne l'écrit que dans un
> fichier temporaire `0600` détruit par `shred` en sortie, et il ne quitte la
> machine que chiffré par restic. **Ne jamais le committer ni le laisser traîner.**

### Pourquoi pas la fonction native d'OPNsense

Elle a quitté le cœur d'OPNsense en mars 2025 (en 25.7/26.1/master, seul le
provider `Local` subsiste) pour devenir le plugin `os-gdrive-backup`, à cause
d'un verrou Google ([opnsense/core#8343](https://github.com/opnsense/core/issues/8343)) :
un compte de service créé après le **15/04/2025** ne peut plus posséder de
fichier Drive, et les contournements proposés exigent Google Workspace. Le
mainteneur a acté le déplacement « *so people can use it while it lasts* ».
Le plugin reste par ailleurs bloqué sur une clé P12 lue par `openssl_pkcs12_read()`,
cassée depuis OpenSSL 3. **Voie écartée : elle dépend d'une brique que Google
peut couper.**

## Installation (une seule fois)

### 1. Outils (poste de contrôle)

    sudo apt install -y libxml2-utils          # xmllint, requis par la validation

### 2. Compte et clé API dédiés (UI OPNsense)

Fail-closed : un compte qui ne peut *que* lire la configuration, rien d'autre.

1. **System → Access → Groups** → `+` → nom `backup`
   → privilège **`Diagnostics: Configuration History`** (c'est lui qui ouvre
   `/api/core/backup/*`). Aucun autre privilège.
2. **System → Access → Users** → `+` → nom `svc-backup`
   → **Login shell : `/usr/sbin/nologin`**, pas de mot de passe utilisable,
   groupe `backup`.
3. Sur cet utilisateur → **API keys** → `+` → un fichier `apikey.txt` est
   téléchargé : il contient `key=` et `secret=`. C'est la **seule** fois où le
   secret est affiché.

### 3. Empreinte TLS du pare-feu

Le certificat de l'interface d'admin est auto-signé : on épingle la clé publique
plutôt que de désactiver la vérification.

    openssl s_client -connect 10.0.100.1:443 </dev/null 2>/dev/null \
      | openssl x509 -pubkey -noout \
      | openssl pkey -pubin -outform der \
      | openssl dgst -sha256 -binary | base64

Résultat à préfixer par `sha256//`.

### 4. Secret SOPS

    cp scripts/opnsense-api.env.example /tmp/opn.env
    ${EDITOR:-nano} /tmp/opn.env               # coller URL, key, secret, épinglage
    sops --encrypt /tmp/opn.env > scripts/opnsense-api.enc.env
    shred -u /tmp/opn.env

Vérifier qu'aucune version claire ne subsiste :

    git status --short scripts/          # doit ne montrer que *.enc.env

### 5. Test

    ~/homelab/scripts/backup-restic-drive.sh

Attendu en fin de liste : `• opnsense    ... OK (config.xml, NNNNNN octets)`.

Contrôler le snapshot :

    export RESTIC_PASSWORD="$(sops -d scripts/restic-drive.enc.env | sed -n 's/^RESTIC_PASSWORD=//p')"
    export RESTIC_REPOSITORY=rclone:gdrive:homelab-restic
    restic snapshots --host opnsense

### 6. Versionner

    git add scripts/opnsense-api.enc.env && git commit -m "feat(backup): secret API OPNsense" && git push

Rien d'autre à faire : le timer quotidien existant embarque désormais le pare-feu.

## Restauration

    restic dump latest --host opnsense /opnsense-config.xml > /tmp/config.xml
    xmllint --noout /tmp/config.xml && echo "XML valide"

Puis, dans l'UI : **System → Configuration → Backups → Restore** → charger le
fichier → le pare-feu redémarre avec cette configuration.

> Restauration sur matériel neuf : les noms d'interfaces physiques (`igb0`,
> `mlxen0`…) doivent correspondre, sinon OPNsense demande un ré-assignement en
> console au premier démarrage. Prévoir un accès écran/clavier.

`shred -u /tmp/config.xml` une fois l'opération terminée.

## Validations fail-closed du script

Le script **refuse** de sauvegarder un fichier inexploitable — un backup corrompu
qui passe pour valide est pire que pas de backup :

| Contrôle | Motif |
|---|---|
| Taille ≥ 10 000 octets | Attrape les réponses d'erreur courtes / pages de login |
| Absence de `&lt;opnsense&gt;` | Régression connue **OPNsense 25.7.3** : XML renvoyé échappé en HTML |
| `xmllint --noout` | XML réellement bien formé |
| Racine `<opnsense>` présente | C'est bien une configuration, pas un autre document |

Tout échec sort en code non nul → le `OnFailure=` du timer déclenche l'alerte ntfy.

## Dépannage

| Symptôme | Cause / correctif |
|---|---|
| `non configuré ... ignoré` | `scripts/opnsense-api.enc.env` absent → étape 4 |
| `ÉCHEC (xmllint absent)` | `sudo apt install libxml2-utils` |
| `ÉCHEC (API injoignable / auth refusée / épinglage rejeté)` | Tester à la main : `curl -k -u "KEY:SECRET" https://10.0.100.1/api/core/backup/download/this \| head -c 200`. Une réponse de login ⇒ privilège `Diagnostics: Configuration History` manquant. Une erreur d'épinglage ⇒ certificat du pare-feu renouvelé, refaire l'étape 3. |
| `ÉCHEC (XML échappé en HTML)` | Régression de l'API sur la version installée. **Repli manuel** (le pare-feu doit accepter ta clé SSH) : `ssh root@10.0.100.1 cat /conf/config.xml > /tmp/config.xml`, vérifier `xmllint --noout /tmp/config.xml`, injecter avec `restic backup --stdin --stdin-filename opnsense-config.xml --host opnsense --tag offsite --tag opnsense < /tmp/config.xml`, puis `shred -u /tmp/config.xml`. |

## Limites connues

- Sauvegarde la **configuration**, pas l'état : baux DHCP en cours, cache
  Unbound, compteurs et journaux ne sont pas repris (sans intérêt en restauration).
- Les **paquets installés** (Suricata et ses rulesets, `os-*`) sont référencés dans
  `config.xml` mais réinstallés depuis Internet à la restauration : prévoir une
  connectivité sortante lors d'un rebuild complet.

# Sauvegarde OPNsense vers Google Drive (plugin `os-gdrive-backup`)

Sauvegarde **autonome du pare-feu** : OPNsense pousse lui-même sa configuration
chiffrée vers Google Drive, sans dépendre du poste de contrôle.

## Ce qu'il faut savoir avant de commencer

La fonction a quitté le cœur d'OPNsense en mars 2025 pour devenir un plugin, à
cause d'un changement Google ([opnsense/core#8343](https://github.com/opnsense/core/issues/8343)) :

> Any new service accounts created after **April 15, 2025**, won't receive this
> storage. […] **New service accounts will not be able to own any Drive items.**

Le mainteneur OPNsense a acté le déplacement en plugin « *so people can use it
while it lasts* ». Conséquences directes :

- ✅ **Compte de service créé AVANT le 15/04/2025** → conserve ses 15 Go, tout fonctionne.
- ⛔ **Compte de service créé APRÈS** → ne peut posséder aucun fichier Drive,
  l'envoi échoue. Les trois contournements proposés par Google (Shared Drives,
  consentement OAuth au nom d'un humain, délégation à l'échelle du domaine)
  exigent **Google Workspace** et ne sont pas applicables à un compte Gmail personnel.

Le code du plugin date de 2018 et n'a reçu depuis que des retouches de forme
(déplacement, tier, linter) : **aucun correctif fonctionnel**. Le bug P12 /
OpenSSL 3 de la 24.1 est donc toujours présent — voir étape 2.

> Repli documenté si Google coupe cette voie : `scripts/backup-restic-drive.sh`
> contient une fonction `backup_opnsense()` (tirage par API depuis le poste de
> contrôle), **inerte tant que `scripts/opnsense-api.enc.env` n'existe pas**.
> Voir [sauvegarde-opnsense-drive.md](sauvegarde-opnsense-drive.md).

## Étape 0 — Go / No-Go (2 min)

`console.cloud.google.com` → **IAM & Admin → Service Accounts** → colonne
**Creation date** du compte utilisé pour OPNsense.

Antérieure au 15/04/2025 → continuer. Sinon, inutile d'aller plus loin : basculer
sur le repli ci-dessus.

## Étape 1 — Côté Google

1. Dans le projet portant ce compte de service : **APIs & Services → Bibliothèque**
   → activer **Google Drive API**.
2. **IAM & Admin → Service Accounts** → le compte → onglet **Keys** →
   **Add key → Create new key → type P12** → un `.p12` est téléchargé.
   Son mot de passe est **`notasecret`** (constante Google, codée en dur dans le plugin).
3. Dans **ton** Google Drive : créer un dossier (ex. `opnsense-backups`), le
   **partager avec l'adresse e-mail du compte de service** en rôle **Éditeur**.
4. Ouvrir ce dossier ; l'URL donne le **Folder ID** :
   `drive.google.com/drive/folders/<FOLDER_ID>`

> Les fichiers déposés appartiennent au **compte de service**, pas à toi : ils
> pèsent sur son quota et disparaîtraient avec lui. Ce n'est pas une copie
> détenue par ton compte Google — d'où l'intérêt de garder une seconde voie.

## Étape 2 — Convertir la clé P12 (bug OpenSSL 3)

Le plugin lit la clé ainsi :

```php
openssl_pkcs12_read(base64_decode($privateKeyB64), $certinfo, "notasecret");
// -> "Invalid P12 key, openssl_pkcs12_read() failed"
```

Les P12 émis par Google utilisent des algorithmes hérités (RC2-40) qu'**OpenSSL 3
refuse** sans le provider `legacy` : c'est la panne signalée depuis la 24.1.

**Diagnostic d'abord** — sur le poste de contrôle :

    openssl pkcs12 -in ~/Téléchargements/<cle>.p12 -passin pass:notasecret -nodes -noout \
      && echo "OK : lisible par OpenSSL 3, aucune conversion nécessaire"

Si la commande échoue, **convertir** en conservant impérativement le mot de passe
`notasecret` :

    openssl pkcs12 -legacy -in ~/Téléchargements/<cle>.p12 -passin pass:notasecret \
      -nodes -out /tmp/gdrive.pem

    openssl pkcs12 -export -in /tmp/gdrive.pem -out ~/gdrive-opnsense.p12 \
      -passout pass:notasecret -keypbe AES-256-CBC -certpbe AES-256-CBC -macalg SHA256

    shred -u /tmp/gdrive.pem

    # contrôle : doit passer SANS -legacy
    openssl pkcs12 -in ~/gdrive-opnsense.p12 -passin pass:notasecret -nodes -noout \
      && echo "OK : convertie"

C'est `~/gdrive-opnsense.p12` qu'on téléversera. La clé privée du compte de
service est un secret : la ranger dans **Vaultwarden** et effacer les copies
locales une fois l'opération terminée.

## Étape 3 — Installer le plugin

**System → Firmware → Plugins** → chercher **`os-gdrive-backup`** → `+`.

Il tire la dépendance `php-google-api-php-client`.

## Étape 4 — Configurer

**System → Configuration → Backups** — un bloc *Google Drive* apparaît :

| Champ | Valeur |
|---|---|
| **Enable** | coché |
| **Email Address** | l'adresse du **compte de service** (pas la tienne) |
| **P12 key** | téléverser `~/gdrive-opnsense.p12` |
| **Folder ID** | l'ID relevé à l'étape 1.4 |
| **Prefix hostname to backupfile** | coché — fichiers `<host>.<domaine>-<timestamp>.xml` au lieu de `config-<timestamp>.xml` |
| **Backup Count** | 60 par défaut ; au-delà, les plus anciens sont supprimés |
| **Password** / **Confirm** | mot de passe **fort** chiffrant la sauvegarde |

> ⚠️ **Sans ce mot de passe, la sauvegarde est irrécupérable.** Le déposer dans
> Vaultwarden *avant* de continuer. C'est lui qui rend acceptable le dépôt sur un
> service tiers — la description du plugin déconseille explicitement d'envoyer
> ces données vers un service public.

## Étape 5 — Planifier (indispensable)

**Le plugin ne planifie rien de lui-même.** Il expose seulement l'action configd
`system remote.backup`. Sans tâche cron, il ne s'exécutera jamais.

**System → Settings → Cron → `+`** :

| Champ | Valeur |
|---|---|
| Enabled | coché |
| Minutes / Hours | `0` / `3` |
| Day/Month/Weekday | `*` |
| **Command** | **Remote backup** |
| **Parameters** | `300` (délai aléatoire en secondes avant exécution) |
| Description | `Sauvegarde configuration vers Google Drive` |

## Étape 6 — Tester et vérifier

Exécution immédiate, depuis le shell OPNsense (menu 8) :

    configctl system remote.backup

Journal — **System → Log Files → General**, filtrer sur `backup` :

| Message | Signification |
|---|---|
| `backup configuration as <fichier>` | ✅ envoi effectué |
| `error connecting to Google Drive` | P12 illisible (étape 2) ou API Drive non activée |
| `error while fetching filelist from Google Drive` | Folder ID faux, ou dossier non partagé avec le compte de service |
| `unable to upload … to Google Drive` | quota du compte de service à zéro → **verrou Google d'avril 2025** (étape 0) |

Puis vérifier la présence du fichier dans le dossier Drive.

> **Le plugin n'envoie que si la configuration a changé** depuis le dernier
> envoi : il télécharge le dernier fichier, le déchiffre et le compare. Une
> exécution sans nouveau fichier n'est donc **pas** un échec. Pour forcer un
> envoi lors d'un test, modifier réellement un paramètre (ex. la description
> d'une règle) avant de relancer.

## Étape 7 — Tester la restauration (à ne pas sauter)

Une sauvegarde jamais restaurée n'est pas une sauvegarde.

1. Télécharger un `.xml` depuis le dossier Drive.
2. **System → Configuration → Backups → Restore** → cocher que le fichier est
   chiffré → saisir le mot de passe de l'étape 4 → charger.

À valider sur une OPNsense de test ou juste avant un créneau de maintenance : une
restauration redémarre le pare-feu avec la configuration chargée.

> Sur matériel différent, les noms d'interfaces physiques (`igb0`, `mlxen0`…)
> doivent correspondre, sinon OPNsense demande un ré-assignement en console au
> premier démarrage : prévoir écran + clavier.

## Limites

- Sauvegarde la **configuration**, pas l'état (baux DHCP, cache Unbound, RRD).
- Les **paquets** (Suricata et ses rulesets, plugins `os-*`) sont référencés dans
  `config.xml` mais réinstallés depuis Internet à la restauration : prévoir une
  connectivité sortante lors d'une reconstruction complète.
- Dépend d'une brique que Google peut désactiver : surveiller l'apparition de
  `unable to upload` dans le journal.

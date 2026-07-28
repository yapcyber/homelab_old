# Monter un service de version

Il n'existe pas de procédure unique : monter Navidrome et monter PostgreSQL n'ont
rien à voir. Ce qui est général, c'est la **méthode de classement** — et une fois
la classe connue, la procédure l'est aussi.

## 1. Classer avant d'agir

    ./scripts/check-image-bumps.sh <ref-de-base> [cible] [portée]

    # exemples
    ./scripts/check-image-bumps.sh origin/main                    # mon travail en cours
    ./scripts/check-image-bumps.sh HEAD~1 HEAD services/cloud     # une VM en particulier

| Classe | Ce qui change | Qui s'en occupe |
|---|---|---|
| ✅ **VERT** | mineure, correctif, digest | **Personne** — la boucle GitOps déploie seule |
| ⚠️ **JAUNE** | majeure sans état, ou cache (redis/valkey) | La boucle GitOps déploie, surveiller l'alerte |
| ⚠️ **ORANGE** | application qui migre son schéma au démarrage | **Toi**, §3 |
| ⛔ **ROUGE** | majeure d'un moteur de base de données | **Toi**, §4 |

La règle qui gouverne tout : **le déploiement automatique ne couvre que ce qu'un
retour git peut annuler**. Git restaure la déclaration, pas les données. Dès que
les données sont réécrites, on sort du périmètre automatique.

## 2. Vert et jaune — ne rien faire

Fusionner la PR suffit. Dans les 10 minutes, la VM concernée applique et vérifie.
Une alerte ntfy arrive : `✅ <vm> : déploiement GitOps appliqué`.

Si le résultat est dégradé, le retour arrière est automatique et l'alerte devient
`🔙 <vm> : déploiement annulé`. Voir
[gitops-deploiement-automatique.md](gitops-deploiement-automatique.md).

## 3. Orange — application à état

L'application migre sa base au premier démarrage. Le retour arrière n'est
possible que par restauration : **la sauvegarde n'est pas optionnelle**.

    # 1. Lire les notes de version amont — chercher "breaking", "migration"
    # 2. Sauvegarde COHÉRENTE, conteneur arrêté
    ssh debian@<vm> 'cd ~/homelab/services/<vm>/<pile> && docker compose stop'
    ssh debian@<vm> 'sudo tar czf ~/<pile>-pre-<version>.tar.gz -C ~/homelab/services/<vm>/<pile> data'

> Prendre la sauvegarde **conteneur arrêté**. À chaud, une base SQLite écrit dans
> son journal WAL pendant la copie et l'archive est incohérente — `tar` le
> signale (`file changed as we read it`), et c'est une vraie erreur, pas un
> avertissement cosmétique.

    # 3. Épingler la nouvelle version (tag + digest) dans le compose, commit, push
    # 4. Laisser la boucle GitOps déployer, ou forcer :
    ssh debian@<vm> 'sudo systemctl start homelab-gitops-apply.service'
    # 5. Suivre la migration dans les logs
    ssh debian@<vm> 'docker logs -f <conteneur>'

Certaines migrations affichent `[DON'T STOP]` : **ne pas redémarrer le conteneur**
tant qu'elles tournent, même si le service répond déjà.

## 4. Rouge — majeure d'un moteur de base de données

Le répertoire de données porte la majeure qui l'a écrit. Changer le tag ne migre
rien : le moteur **refuse de démarrer**. Il faut un dump/restore.

### 4a. PostgreSQL, volume nommé — outillé

    ./scripts/migrate-postgres-major.sh <ip-vm> <conteneur>          # simulation
    ./scripts/migrate-postgres-major.sh <ip-vm> <conteneur> --go     # exécution

Tout est déduit du conteneur (projet, répertoire, service, utilisateur, volume,
majeure). Le script dump, vérifie le dump, copie le volume en `<volume>-pre<N>`,
purge, démarre la nouvelle majeure, restaure, remonte la pile et contrôle.

**Pré-requis** : le dépôt doit déjà être à jour sur la VM avec la nouvelle image,
sinon le script relancerait l'ancienne majeure — il s'en rend compte et s'arrête.

### 4b. ⚠️ Le piège PostgreSQL 18

Depuis la 18, l'image officielle range les données par majeure sous
`/var/lib/postgresql/<majeure>/` et attend le montage sur `/var/lib/postgresql`.
Un volume monté sur `.../data` est vu comme *« unused mount/volume »* et le
conteneur boucle au démarrage.

**Le tag et le point de montage changent ensemble :**

```yaml
    image: postgres:18-alpine
    volumes:
      - db:/var/lib/postgresql        # et NON /var/lib/postgresql/data
```

Si le compose fixait un `PGDATA` explicite, le retirer : il contournait à la main
le conflit que la 18 résout nativement.

Le script refuse de démarrer si le montage n'est pas corrigé. Vérifier aussi les
images tierces — leur convention se contrôle en une commande :

    docker run --rm <image>:18 printenv PGDATA

### 4c. PostgreSQL, montage bind — à la main

Quand la base est sur un bind (`./data/postgresql`, `${DB_DATA_LOCATION}`), le
script ne s'applique pas. Même logique, exécutée pas à pas :

    # 1. Dump, et le VÉRIFIER avant de toucher à quoi que ce soit
    docker exec <c> pg_dumpall -U <user> | sudo tee /var/backups/homelab/pg-major/<c>-$(date +%F).sql >/dev/null
    sudo grep -q 'PostgreSQL database cluster dump' <dump> && echo "en-tête OK"
    sudo grep -c 'CREATE TABLE' <dump>

    # 2. Arrêt + copie du répertoire (levier de retour)
    docker compose down
    sudo cp -a data/postgresql data/postgresql-pre<N>

    # 3. Corriger le compose (tag + montage), commit, push, pull sur la VM
    # 4. Repartir sur un répertoire vide
    sudo rm -rf data/postgresql && sudo mkdir -p data/postgresql
    docker compose up -d <service-bdd>

    # 5. Restaurer
    sudo cat <dump> | docker exec -i <c> psql -U <user> -d postgres

    # 6. Remonter la pile
    docker compose up -d

> Deux erreurs `already exists` (base et rôle) à la restauration sont **normales** :
> le conteneur neuf les a créées depuis `POSTGRES_DB`/`POSTGRES_USER` avant que le
> dump ne tente de les recréer. Toute autre erreur mérite lecture.

### 4d. MariaDB — souvent, ne pas migrer

MariaDB alterne LTS et versions **roulantes** à support court. Avant toute
montée, vérifier la nature de la cible sur `mariadb.org/about/#maintenance-policy`.

Exemple réel : Renovate proposait `11.8.8 → 12.3.2`. Or 11.8 est **LTS jusqu'au
04/06/2028** et les 12.x sont roulantes. Accepter revenait à troquer une LTS
stable contre une version éphémère sous l'application des finances. Décision
retenue : **ne pas migrer**, verrouillée par `allowedVersions: "<12"` dans
`renovate.json`.

## 5. Vérifier — sur les données, pas sur le conteneur

Un conteneur `healthy` ne prouve rien. **Relever les compteurs AVANT, les
comparer APRÈS** — c'est la seule vérification qui a du sens.

    # avant ET après, la même requête
    docker exec <c> psql -U <user> -d <base> -tAc \
      "SELECT relname, n_live_tup FROM pg_stat_user_tables WHERE n_live_tup>0 ORDER BY n_live_tup DESC LIMIT 8;"

> La **taille** de la base diminue normalement après un dump/restore (plus de
> tuples morts ni d'index gonflés) : 70 Mo → 16 Mo sur jellystat, 139 → 106 sur
> Authentik. Ce n'est pas une perte. Les **compteurs de lignes**, eux, doivent
> être identiques.

Puis un test applicatif réel : page qui répond, endpoint de santé, connexion.

## 6. Retour arrière

| Cas | Comment |
|---|---|
| Sans état | `git revert` + laisser la boucle redéployer |
| PostgreSQL volume nommé | Commandes affichées en fin de `migrate-postgres-major.sh` |
| PostgreSQL bind | `docker compose down`, restaurer `data/postgresql-pre<N>`, remettre l'ancien tag |
| Application à état | Restaurer l'archive du §3 — le retour git seul ne suffit pas |

Après un retour arrière automatique, la VM est en quarantaine :

    ssh debian@<vm> 'cat ~/.homelab-gitops-blocked'   # révision refusée
    ssh debian@<vm> 'rm ~/.homelab-gitops-blocked'    # réarmer après correction

## 7. Rendre une version visible pour Renovate

Une image dont la version vient d'une variable (`:${APP_VERSION}`) est
**invisible pour Renovate** : la valeur vit dans le `.env` gitignoré, aucune PR
ne sera jamais ouverte, et le service vieillit en silence. C'était le cas
d'Immich (bloqué en v2 alors que la v3 existait) et d'Authentik.

Épingler dans le compose, tag **et** digest :

    docker inspect <conteneur> --format '{{.Image}}' \
      | xargs -I{} docker image inspect {} --format '{{index .RepoDigests 0}}'

## 8. Registre des pièges rencontrés

| Piège | Où |
|---|---|
| PostgreSQL 18 change de point de montage | §4b |
| Image tierce : vérifier sa convention plutôt que la supposer | §4b |
| Sauvegarde SQLite à chaud = archive incohérente | §3 |
| MariaDB 12.x = version roulante, pas LTS | §4d |
| Version en variable = invisible pour Renovate | §7 |
| `already exists` à la restauration = bénin | §4c |
| Baisse de taille après dump/restore = normal | §5 |

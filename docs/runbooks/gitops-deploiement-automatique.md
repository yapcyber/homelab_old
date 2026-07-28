# Déploiement GitOps automatique (avec retour arrière par git)

Boucle de réconciliation : une mise à jour fusionnée sur `main` se retrouve
déployée sur les VM concernées, et **s'annule toute seule** si le résultat est
dégradé.

## La chaîne complète

    Renovate ouvre une PR
      → CI classe le risque (scripts/check-image-bumps.sh)
      → rouge/orange : la PR ÉCHOUE, migration manuelle requise
      → vert/jaune  : fusion sur main
          → timer (10 min) sur chaque VM : gitops-apply.sh
              → pull + docker compose up -d des piles concernées
              → contrôle de santé (10 min max)
                  ├─ sain    → alerte ntfy basse, terminé
                  └─ dégradé → retour à la révision précédente + alerte haute

Le modèle est **pull**, pas webhook : aucun port entrant n'est ouvert sur ce
réseau, et c'est de toute façon le fonctionnement des outils GitOps établis.

## Pourquoi git plutôt qu'une snapshot Proxmox

C'est le choix structurant, et il mérite d'être compris.

Un retour git restaure la **déclaration** (compose, configuration), pas les
**données**. Il est donc :

- **suffisant et supérieur** pour un changement sans état (tag d'image, option) :
  instantané, limité aux piles touchées, sans effet de bord sur les données
  voisines — restaurer une snapshot de la VM `cloud` ramènerait aussi Vaultwarden
  en arrière, ce qui est inacceptable ;
- **insuffisant** pour une majeure de base de données ou une migration de schéma :
  une fois les données réécrites, remettre l'ancien tag donne un conteneur qui
  refuse de démarrer (constaté sur jellystat, PostgreSQL 16 → 18).

D'où la règle : **le périmètre automatique est exactement le périmètre
réversible**. `gitops-apply.sh` refuse de déployer ce que git ne peut pas
annuler, et renvoie vers la procédure manuelle.

## Ce que le script refuse de faire

| Situation | Comportement |
|---|---|
| Rouge/orange détecté (base de données, migration de schéma) | **Refus**, alerte haute, révision mise en quarantaine |
| Dérive locale (commit ou fichier modifié sur la VM) | **Refus** — ne jamais écraser un travail local |
| Révision déjà en échec | Silence (disjoncteur, évite la boucle d'alertes) |
| Changement ne concernant pas cette VM | Avance le clone, ne redéploie rien |

## Sélection des piles

Convention du dépôt : `services/<nom-de-vm>/<pile>/`. Le script ne redéploie que
les piles dont un fichier a changé, sur **sa** VM. Une pile est le répertoire
portant le `docker-compose.yml` — `services/firefly/ghostfolio` est donc traité
indépendamment de `services/firefly`.

## Contrôle de santé

Un conteneur est jugé **dégradé** si : `unhealthy`, arrêté, ou ≥ 3 redémarrages.
Un conteneur en `starting` est **attendu** jusqu'au délai de 10 minutes (une
pile lourde comme Authentik met plus d'une minute à se déclarer saine).

## Après un retour arrière

L'alerte ntfy indique la révision refusée, les piles concernées et ce qui a été
constaté. Le déploiement reste **suspendu sur cette VM** tant que le fichier
de quarantaine existe :

    ssh debian@<vm> 'cat ~/.homelab-gitops-blocked'    # révision refusée

Après correction (dans le dépôt, jamais sur la VM) :

    ssh debian@<vm> 'rm ~/.homelab-gitops-blocked'     # réarme le déploiement

## Déploiement de la boucle elle-même

    cd ~/homelab/ansible
    ansible-playbook playbooks/scheduled-tasks.yml --limit infra,monitoring,cloud,media,firefly

Contrôles :

    ssh debian@10.0.30.10 'systemctl list-timers homelab-gitops-apply.timer'
    ssh debian@10.0.30.10 'sudo systemctl start homelab-gitops-apply.service'   # exécution immédiate
    ssh debian@10.0.30.10 'journalctl -u homelab-gitops-apply.service -n 40'

## Limites connues

- Les **4 VM à stacks amont** (security, scanner, osint, ir) sont hors périmètre :
  elles n'ont pas de clone du dépôt. Voir `services/deploiements-amont/`.
- Le script ne teste que la **santé des conteneurs**, pas le fonctionnement
  applicatif. Un service peut être `healthy` et cassé fonctionnellement — les
  sondes Uptime Kuma restent la deuxième ligne de détection.
- Un changement touchant plusieurs VM est appliqué **par VM indépendamment** :
  un retour arrière sur `cloud` ne retire pas le déploiement déjà fait sur
  `media`. Acceptable ici, les piles étant indépendantes.

# Faire déployer une règle NIDS locale sur Security Onion

Runbook de session pour la soirée du 29/07/2026 : obtenir **une alerte** de la
sonde avant de la décommissionner, faute de quoi deux preuves du dossier de
validation tombent.

    ./scripts/so-regle-locale.sh --diag    # diagnostic seul
    ./scripts/so-regle-locale.sh           # diagnostic + correction guidée

À lancer **depuis le VLAN admin** : l'interface et le SSH de la sonde n'y sont
joignables que de là.

## Où on en est

| Constat | Conclusion |
|---|---|
| Zeek journalise le trafic (`conn`, `http` remontent) | La capture fonctionne, le SPAN est bon |
| D'autres règles ont alerté ces 7 derniers jours | Le moteur Suricata et l'indexation fonctionnent |
| La règle locale `1000002` ne déclenche jamais | **Elle n'est pas déployée** jusqu'aux fichiers que Suricata charge |

Une seule hypothèse tient debout : la règle existe dans l'interface *Detections*
mais n'a jamais atteint les fichiers de règles.

**Pourquoi `so-idstools-restart` n'existait pas** : en SO 3.x, `idstools` a été
remplacé par le moteur *Detections*. `so-suricata-restart` recharge bien Suricata
— mais les *mêmes* fichiers, sans la règle. Il manquait l'étape de
synchronisation.

## Voie 1 — l'interface (à essayer en premier)

C'est le mécanisme prévu, et il ne laisse pas de dette.

1. **Detections** → repérer la règle `1000002`.
   - statut **Enabled** et pas seulement créée ?
   - un bandeau *mismatch* ou *integrity check failed* ? C'est un bug connu de
     l'ajout de règles personnalisées, et ce serait l'explication.
2. **Options → Synchronize**, moteur **Suricata**.
3. Vérifier : `./scripts/so-regle-locale.sh --diag` → l'étape 4 doit désormais
   trouver la règle dans un fichier déployé.

## Voie 2 — injection directe (repli assumé)

Le script propose d'écrire la règle directement dans le fichier local et de
recharger Suricata, en court-circuitant *Detections*. Il sauvegarde le fichier
avant (`.avant-1000002`) et ne fait rien sans confirmation.

C'est de la dette technique — sur une machine effacée le soir même, elle ne
coûte rien. **Ne pas reproduire ce geste sur une sonde qu'on garde** : la
divergence entre l'interface et les fichiers deviendrait ingérable.

## Vérifier

    event.dataset:alert AND alert.signature:*HOMELAB*

Puis générer le trafic et enchaîner les captures :

    ./scripts/preuves-security-onion.sh

> **Capture supplémentaire, la plus forte du lot** : la règle affichée dans
> *Detections* à côté de l'alerte qu'elle a produite. On passe de « j'ai lancé un
> test et ça s'est allumé » à « j'ai écrit la signature, je l'ai déployée, elle a
> détecté ».

## Si rien ne part

On arrête les frais — la sonde disparaît ce soir, l'acharnement n'a pas de
valeur. On réécrit `bc03/c09` sur le **constat réel**, qui est défendable et
vérifiable :

> Évaluation de la couverture de détection du homelab. Le port miroir est
> correctement configuré (SPAN par VLAN sur les dix segments, encapsulation
> `Replicate`) et la capture est prouvée par les journaux Zeek. Le moteur
> alerte sur les règles fournies. En revanche, une signature locale déployée
> pour l'occasion n'a pas produit d'alerte : la chaîne de détection était
> partiellement inopérante sans que rien ne le signale. Ce constat a motivé la
> consolidation de la détection réseau sur Suricata intégré à OPNsense, qui
> couvre le nord-sud et l'inter-VLAN, au prix de la perte de Zeek et du PCAP —
> arbitrage assumé au vu de l'usage réel.

Cette version démontre la compétence visée — **évaluer, conclure, décider** —
mieux qu'une capture d'écran d'un outil qui fonctionne. Une visibilité qu'on
croit avoir et qu'on n'a pas est un constat d'audit, pas un échec.

Éléments de preuve disponibles pour cette version : configuration du SPAN,
journaux Zeek du flux de test, absence d'alerte sur la fenêtre, règle écrite et
déployée, et le chantier de migration vers Suricata/OPNsense.

## Impact sur l'autre fiche

`bc01/c10` n'est **pas** bloquée : la capture Security Onion n'y est qu'une
preuve sur cinq (post-mortem Dupont, tableau Grafana/Loki, journaux de filtrage
OPNsense, Observateur d'événements Windows). Retirer la ligne et la phrase sur la
sonde suffit — la compétence reste largement couverte.

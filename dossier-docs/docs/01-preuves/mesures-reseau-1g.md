---
title: "Mesure des débits — état initial 1 Gb/s"
sidebar_position: 4
---

# Mesure des débits réseau — état initial en 1 Gb/s

**Pièce produite le 9 août 2026, entre 05h02 et 05h12 CEST.**
Elle sert la compétence [BC02 C2](/blocs/bc02/c02) (« les débits sont
optimisés ») et alimente [BC02 C3](/blocs/bc02/c03). C'est l'action T4 du
[plan d'actions](/actions).

:::info Pourquoi cette date
Cette mesure n'était réalisable que tant que l'installation actuelle était en
place. Le déménagement du 10 août 2026 modifie le brassage, et la
consolidation des machines virtuelles sur un seul nœud supprime les chemins
inter-nœuds mesurés ici. Sans cet état initial, l'évolution vers 10 Gb/s
resterait une étude sans avant ni après.
:::

## Objet

Établir, avant toute modification physique, le débit réellement atteint sur
chacun des chemins réseau du homelab, afin de déterminer si le plafond observé
provient du support physique ou d'un défaut de configuration. La distinction
commande la suite : un défaut se corrige sans dépense, un plafond physique ne
se lève qu'en changeant le support.

## Conditions de la mesure

| Paramètre | Valeur |
|---|---|
| Date et heure | 9 août 2026, 05h02 à 05h12 CEST |
| Outil | `iperf3` 3.18 sur les hyperviseurs, 3.12 sur les machines virtuelles |
| Durée par essai | 20 secondes |
| Flux | 1 puis 4 flux parallèles |
| Sens | Montant, puis descendant avec l'option de renversement |
| Charge concurrente | Aucune tâche planifiée active. La sauvegarde quotidienne (01h30) et la mise à jour des flux de vulnérabilités (02h30) étaient terminées ; la vérification de dérive (07h00) n'avait pas commencé |
| Négociation des liens | Les huit interfaces physiques des quatre nœuds annoncent 1000 Mb/s |

Trois précautions ont encadré la campagne.

Le nœud portant le stockage n'a pas été saturé. Il héberge la machine virtuelle
de NAS et sept machines virtuelles dont les disques système vivent sur ce
partage : saturer son lien aurait dégradé le service familial pendant l'essai.
Les liens étant tous identiques, la mesure sur les nœuds déchargés est
représentative.

Le réseau de quorum n'a pas été mesuré. Le saturer aurait pu faire perdre le
quorum à un nœud et déclencher son exclusion du cluster. Sur ce segment, la
grandeur utile est la latence, pas le débit.

Aucune donnée n'a été écrite sur un volume de production au-delà d'un fichier
temporaire de 512 Mio, supprimé immédiatement, l'espace disponible ayant été
vérifié avant et après.

## Topologie observée

La reconnaissance préalable a établi un fait qui n'était pas documenté : les
disques système des machines virtuelles sont servis par un partage réseau situé
sur un autre segment que celui des hyperviseurs. Le trafic de stockage est donc
**routé par le pare-feu**, et non commuté. Chaque lecture et chaque écriture de
disque traverse le routeur.

Chaque nœud dispose de deux interfaces à 1 Gb/s, l'une portant l'administration
et les machines virtuelles, l'autre dédiée au réseau de quorum. Cette séparation
physique est ce qui a permis de mesurer sans mettre le cluster en risque.

## Résultats — débit brut

Débit utile en Mbit/s, mesuré sur 20 secondes.

| Chemin | Nature | 1 flux | 4 flux | 4 flux, sens inverse |
|---|---|---:|---:|---:|
| A — machine virtuelle vers machine virtuelle, même segment, deux nœuds différents | Commuté | 937,9 | 937,3 | 938,9 |
| B — hyperviseur vers machine virtuelle, segments différents | Routé par le pare-feu | 918,7 | 920,6 | 910,0 |
| C — hyperviseur vers hyperviseur, segment d'administration | Commuté | 941,3 | 939,2 | 940,2 |

Le plafond théorique d'un lien à 1000 Mb/s, une fois retirées les enveloppes
Ethernet, IP et TCP, se situe à environ 941 Mbit/s.

## Résultats — débit du stockage réseau

Fichier de 512 Mio, écriture et lecture en accès direct, cache client vidé
avant la lecture.

| Depuis | Écriture | Lecture |
|---|---:|---:|
| Nœud vide, distant du stockage | 88,1 Mo/s (705 Mbit/s) | 104 Mo/s (832 Mbit/s) |
| Nœud portant le stockage | 89,5 Mo/s (716 Mbit/s) | 102 Mo/s (816 Mbit/s) |

## Interprétation

**Le lien physique est saturé, et c'est lui la limite.** Le chemin commuté entre
hyperviseurs atteint 941,3 Mbit/s, soit la valeur maximale atteignable sur un
lien à 1000 Mb/s. Aucun réglage logiciel ne peut y gagner quoi que ce soit. Le
plafond n'est pas un défaut de configuration : c'est le support.

**Le routage par le pare-feu coûte peu.** Le chemin routé rend 918 à 921 Mbit/s
contre 941 en commuté, soit entre 2,2 et 3,3 pour cent. Le pare-feu route donc
quasiment au débit du lien et n'est pas le goulot d'étranglement, contrairement
à ce que la présence d'un routage sur le chemin de stockage pouvait laisser
craindre.

**La virtualisation ne coûte rien de significatif.** Le chemin entre deux
machines virtuelles portées par deux hyperviseurs distincts rend 938 Mbit/s,
soit 0,4 pour cent sous le chemin entre hyperviseurs.

**Le stockage réseau atteint 75 à 88 pour cent du plafond.** L'écart avec le
débit brut correspond aux enveloppes du protocole de partage de fichiers et à la
sémantique d'écriture synchrone, pas à la topologie.

**Une hypothèse a été formulée puis réfutée par la mesure.** Le stockage étant
une machine virtuelle hébergée sur un nœud, et son segment étant routé, le
trafic de ce nœud vers son propre stockage sort vers le pare-feu et revient par
le même lien physique. J'ai supposé que ce repli en épingle coûterait la moitié
du débit disponible. La mesure le contredit : depuis ce nœud, l'écriture rend
89,5 Mo/s contre 88,1 Mo/s depuis un nœud distant, soit un écart nul à la marge
d'erreur près. L'explication est que le lien est bidirectionnel simultané :
l'aller et le retour empruntent des directions indépendantes et n'entrent pas en
concurrence. J'ai conservé cette hypothèse et sa réfutation plutôt que de ne
publier que le résultat, parce qu'elle documente la démarche.

## Conclusion

Tous les chemins mesurés fonctionnent à leur plafond physique. La marge de
progression par la configuration est nulle ; le seul levier restant est le
support de transmission. C'est ce constat, et non une préférence pour une
technologie, qui justifie l'évolution vers 10 Gb/s inscrite en cible.

## Données brutes

Les neuf relevés `iperf3` sont conservés au format JSON, horodatés, avec le
nombre de flux, la durée, le sens, le nombre de retransmissions et la taille de
segment.

- [Relevés bruts iperf3 du 9 août 2026](pathname:///preuves/iperf-2026-08-09/)

Une seule modification y a été apportée, et elle est déclarée ici : la bannière
système, qui contenait la version exacte du noyau des hyperviseurs, a été
remplacée par le seul nom d'hôte. Le dépôt qui porte ce site est public, et une
version de noyau précise est ce qui permet d'apparier une vulnérabilité connue à
une machine. Aucune valeur de mesure n'a été touchée.

## Suite — mesure après évolution

L'action T5 reprend le même protocole, aux mêmes points, une fois le lien
10 Gb/s actif. La comparaison n'est valable que si la méthode est identique :
mêmes chemins, même durée, mêmes nombres de flux, mêmes sens. La procédure de
reproduction est décrite dans le dépôt, à
`docs/runbooks/mesure-debits-reseau.md`.

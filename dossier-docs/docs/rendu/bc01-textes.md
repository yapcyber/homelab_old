---
title: "BC01 — textes du rendu"
sidebar_position: 1
---

# BC01 — textes du rendu

:::tip Textes à jour au 2 août 2026
Ces onze textes intègrent **deux couches de correction factuelle** appliquées
au-dessus du texte validé d'origine, sans en réécrire le fond :

- **Juillet 2026** : neuf machines de service, chaîne d'infrastructure-as-code,
  chaîne de sauvegarde réellement déployée, positionnement de contributeur au
  comité de sécurité.
- **2 août 2026** : sonde de détection **décommissionnée** et traitée au passé,
  cluster passé de **trois à quatre nœuds** avec arbitre de quorum, haute
  disponibilité **armée mais non testée** avec le motif du report, et démonstration
  de détection est-ouest ajoutée en C10.

Les corrections sont portées par `build_dossier_refonte.py`, qui génère le
document Word à partir du texte d'origine. Le fichier source reste intact.
:::

:::caution Un point à confirmer
La version de juillet affirmait qu'un test de restauration avait été mené
**après sauvegarde sur la clé chiffrée hors ligne**. Les sources sont
ambiguës sur ce point : le test du 22 juillet depuis le dépôt hors site est
certain, celui depuis la clé ne l'est pas.

Par prudence, C11 énonce désormais que la branche hors ligne est en place et
contrôlée, mais qu'aucune restauration complète n'a encore été conduite depuis ce
support. Cette formulation est cohérente avec [BC03 C13](/blocs/bc03/c13).
**Si une restauration depuis la clé a bien eu lieu, dis-le moi et je rétablis.**
:::

Titre RNCP 35594, Administrateur Systèmes, Réseaux et Bases de Données (certificateur IGENSIA), préparé en Bachelor 3 Cybersécurité à Lille Ynov Campus.

Candidat : Yanis Deschamps.

Ce document regroupe, pour le bloc BC01, le texte rédigé de chacune des onze compétences (origine de l'acquisition, rappel du contexte, activités réalisées, preuves jointes) ainsi que la liste des preuves à apporter en annexe, avec leur contenu attendu. Le bloc n'est validé que si les onze compétences sont acquises.

## Conventions et points d'attention

- **Anonymisation.** Toutes les preuves issues de Dupont Restauration doivent être anonymisées ou floutées (noms, adresses IP, noms d'hôtes, marques d'outils de sécurité).
- **Éléments réservés à l'oral**, sans annexe car sans trace exploitable : la panne CrowdStrike chez Concentrix (compétence 1), l'intervention Meraki chez Concentrix (compétence 5), le diagnostic du poste qui redémarrait, identifiant 1074 (compétence 10).
- **Sources.** Trois origines de preuves : le homelab personnel (yapserver.fr), l'alternance chez Dupont Restauration, et deux projets de bases de données menés à Ynov (ShopSecure et AccessNow).

## Actions à réaliser sur le homelab avant collecte

1. Déployer la solution de sauvegarde automatisée (runbook) pour produire les preuves de la compétence 11.
2. Déployer Uptime Kuma et le laisser tourner une à deux semaines pour obtenir un taux de disponibilité présentable (compétences 1 et 3). Grafana et Loki restent dédiés à la centralisation des journaux (compétence 10) et à la remontée des sauvegardes (compétence 11).
3. Remplir le tableau d'allocation des ressources avec les valeurs réelles et ajouter la ligne de ratio de consolidation (compétence 2).
4. Produire le ou les schémas de topologie, réseau et virtualisation (compétences 1, 2 et 5).
5. Finaliser la configuration du déploiement par rings dans Tanium, puis la capturer (compétence 4).

---

# Compétences et preuves

## Compétence 1 : Assurer l'exploitation du Système d'Information

**Énoncé du référentiel.** Assurer l'exploitation du Système d'Information (SI) pour maintenir une opérationnalité constante grâce à un large spectre de savoir-faire associés aux systèmes.

**Critère d'évaluation.** Les différents systèmes et équipements installés sont constamment opérationnels.

**Origine de l'acquisition.** J'ai acquis cette compétence en poste, comme technicien informatique chez Concentrix puis comme alternant administrateur en cybersécurité chez Dupont Restauration, et je l'ai élargie sur mon infrastructure personnelle.

**Rappel du contexte (voir partie 1).** Chez Dupont Restauration, j'interviens principalement sur le volet sécurité de l'exploitation du SI. Mon homelab me sert d'environnement de mise en pratique sur des briques système que je ne pilote pas en entreprise.

**Activités réalisées.** Chez Dupont Restauration, je participe chaque matin au journal d'exploitation, dont je tiens la partie sécurité. Cette vérification quotidienne d'une vingtaine de points conditionne le démarrage de la production et confirme que les services concernés sont opérationnels avant l'ouverture. J'ai également mené des actions concrètes d'exploitation, comme la création d'une stratégie de groupe (GPO) pour appliquer un paramètre de sécurité, et l'exécution d'un script de désinstallation d'un logiciel et d'une mise à jour (KB) sur le parc. Sur la continuité de service, je suis intervenu en première ligne lors de la panne CrowdStrike de juillet 2024, alors technicien chez Concentrix. Une fois la remédiation identifiée, je l'ai appliquée manuellement sur plus de cinq cents postes en saisissant la clé BitLocker et en supprimant le fichier défaillant, tout en surveillant le rétablissement du réseau pour indiquer aux équipes la marche à suivre lors de la reprise. J'ai par ailleurs contribué au traitement d'une alerte remontée par le SOC chez Dupont Restauration, de l'analyse à la remédiation, et participé à la rédaction de l'analyse post-mortem associée. Sur mon homelab, je maintiens en fonctionnement continu une infrastructure virtualisée sous Proxmox VE, qui héberge mes services derrière un pare-feu OPNsense, avec une détection réseau assurée par le moteur Suricata qui y est intégré, après le décommissionnement en juillet 2026 de la sonde dédiée que j'exploitais jusque-là. J'y administre de bout en bout un service DNS et un service DHCP, ce qui me permet de couvrir un spectre de savoir-faire système plus large que mon périmètre en entreprise.

**Preuves à apporter.**

- Extrait du journal d'exploitation, volet sécurité (Dupont, à anonymiser) : montre les points de vérification quotidiens conditionnant le démarrage de la production.
- Capture de la GPO créée et extrait du script de désinstallation logiciel et KB (Dupont, à anonymiser).
- Extrait de l'analyse post-mortem d'une alerte SOC (Dupont, à anonymiser).
- Schéma de topologie du homelab.
- Captures Proxmox VE des machines et conteneurs en fonctionnement (avec uptime) et tableau de disponibilité issu d'Uptime Kuma.
- Configuration des services DNS et DHCP du homelab (zone Unbound, étendue Kea).
- Élément oral, sans annexe : la panne CrowdStrike chez Concentrix.

---

## Compétence 2 : Concevoir l'infrastructure d'une plateforme virtuelle

**Énoncé du référentiel.** Concevoir l'infrastructure d'une plateforme virtuelle pour intégrer plusieurs machines physiques en une seule.

**Critère d'évaluation.** Le nombre de serveurs physiques est diminué.

**Origine de l'acquisition.** J'ai acquis et mis en pratique cette compétence sur mon infrastructure personnelle, le homelab yapserver.fr, que j'ai conçue et que j'administre en autonomie.

**Rappel du contexte (voir partie 1).** Ce homelab auto-hébergé répond à des besoins personnels et familiaux, et me sert d'environnement de conception et de démonstration en infrastructure, réseau et sécurité.

**Activités réalisées.** J'ai conçu une plateforme de virtualisation sous Proxmox VE 9.2.3, organisée en cluster de quatre nœuds reposant sur quatre mini-PC, afin d'héberger l'ensemble de mes services sur un nombre réduit de machines physiques. Sur ce socle, je fais cohabiter neuf machines virtuelles de service couvrant l'infrastructure, la supervision, le cloud familial, les médias, la détection hôte, le scan de vulnérabilités, la gestion financière, l'OSINT et la réponse à incident. À l'intérieur des VM, j'utilise Docker et Docker Compose pour isoler les applications, ce qui me permet de consolider une quarantaine de services applicatifs sur quatre hôtes physiques. Dans un modèle où chaque ensemble fonctionnel aurait reposé sur une machine dédiée, cette architecture aurait nécessité une quinzaine de serveurs ; ils sont consolidés sur quatre mini-PC, dont le quatrième a été obtenu en réaffectant une machine déjà présente plutôt qu'en achetant du matériel. Pour fiabiliser et standardiser les nouveaux déploiements, j'utilise désormais un modèle doré Debian 13 construit avec Packer, puis cloné et configuré avec OpenTofu et cloud-init. Le stockage NFS partagé rend les VM de service accessibles aux différents nœuds du cluster, tout en constituant actuellement un point de défaillance unique que j'ai identifié dans ma dette d'infrastructure. J'ai réalisé moi-même le dimensionnement des ressources de chaque machine, en cherchant à équilibrer l'ensemble : une allocation au plus juste pour les applications de service et une marge plus large pour les briques de sécurité.

**Preuves à apporter.**

- Schéma d'architecture de la plateforme virtualisée (cluster Proxmox à quatre nœuds, arbitre de quorum et VM hébergées).
- Tableau d'allocation des ressources rempli avec les valeurs réelles (CPU, RAM et stockage des hôtes ; vCPU, RAM, disque et services par VM) et ligne de synthèse de la consolidation avec le ratio.
- Capture Proxmox VE du cluster et de la liste des VM avec leurs ressources.
- Modèle de VM et configuration cloud-init illustrant l'industrialisation du déploiement.

---

## Compétence 3 : Maintenir en conditions opérationnelles l'infrastructure en utilisant des logiciels de gestion de la haute disponibilité

**Énoncé du référentiel.** Maintenir en conditions opérationnelles l'infrastructure de l'entreprise en utilisant des logiciels de gestion de la haute disponibilité.

**Critère d'évaluation.** Le taux de disponibilité observé est conforme aux exigences de l'exploitation.

**Origine de l'acquisition.** J'ai mis en œuvre cette compétence sur mon homelab, où j'ai conçu la haute disponibilité du cluster, et je la complète par ma participation quotidienne à la vérification de disponibilité chez Dupont Restauration.

**Rappel du contexte (voir partie 1).** Sur mon homelab, plusieurs services sont utilisés au quotidien par mes proches, ce qui m'impose de viser une disponibilité continue. Chez Dupont Restauration, la disponibilité des systèmes conditionne le démarrage de la production chaque matin.

**Activités réalisées.** Sur mon homelab, j'ai configuré la haute disponibilité native de Proxmox VE sur un cluster de quatre nœuds, complété par un arbitre de quorum externe hébergé sur un nano-ordinateur recyclé. Le cluster dispose ainsi de cinq voix pour un quorum de trois, ce qui lui permet de tolérer deux pannes simultanées et supprime le blocage à deux contre deux propre à un nombre pair de nœuds. La communication entre les nœuds repose sur Corosync, sur un réseau dédié, pour maintenir le quorum, et le gestionnaire de haute disponibilité est associé à un watchdog. Le stockage NFS partagé rend les disques des VM accessibles depuis les différents nœuds et permet leur migration. Uptime Kuma mesure la disponibilité des services et déclenche des notifications par ntfy ; Prometheus et Grafana complètent cette observation par des métriques d'infrastructure. La haute disponibilité est armée depuis le 1er août 2026, avec neuf ressources déclarées et un chien de garde actif, mais je n'ai pas encore conduit de test volontaire et tracé d'arrêt d'un nœud avec mesure du délai de reprise. Ce report est délibéré : le relevé de capacité montre une répartition mémoire déséquilibrée, et le gestionnaire de haute disponibilité ne vérifie pas la mémoire disponible avant de placer une machine, si bien qu'une reprise pourrait viser un nœud incapable de l'accueillir. Rééquilibrer la répartition passe donc avant le test. Je distingue donc la mise en place du mécanisme de la validation complète de la bascule, qui reste une preuve à produire. J'ai également identifié que la VM TrueNAS et son stockage USB constituent actuellement un point de défaillance unique : la HA protège d'une perte de nœud de calcul, pas d'une perte du stockage partagé. Chez Dupont Restauration, je tiens chaque matin le volet sécurité du journal d'exploitation, dont la vérification d'une vingtaine de points contribue au contrôle de la disponibilité avant l'ouverture de la production.

**Preuves à apporter.**

- Capture Proxmox VE montrant la haute disponibilité configurée, l'état du quorum et le watchdog.
- Tableau de bord Uptime Kuma présentant le taux de disponibilité observé et l'historique des incidents.
- À produire : compte rendu daté d'un test de bascule contrôlé, avec journaux Proxmox et durée mesurée.
- Extrait du journal d'exploitation, volet sécurité (Dupont, à anonymiser).

---

## Compétence 4 : Identifier rapidement les systèmes qui nécessitent des correctifs et qui doivent être reconfigurés en fonction des préconisations constructeurs

**Énoncé du référentiel.** Identifier rapidement les systèmes qui nécessitent des correctifs et qui doivent être reconfigurés en fonction des préconisations constructeurs.

**Critère d'évaluation.** Les correctifs sont appliqués, les paramètres systèmes sont ajustés et cohérents.

**Origine de l'acquisition.** J'ai développé cette compétence dans le cadre de mon alternance chez Dupont Restauration, où le maintien en condition de sécurité fait partie de mes missions, et je la prolonge sur mon homelab.

**Rappel du contexte (voir partie 1).** Chez Dupont Restauration, je contribue au maintien en condition de sécurité du parc, ce qui suppose d'identifier les systèmes vulnérables ou non conformes et d'y appliquer les correctifs ou les ajustements nécessaires.

**Activités réalisées.** Chez Dupont Restauration, je propose des mises à jour et je réalise des scans de vulnérabilité pour identifier les systèmes à corriger, puis j'applique la politique de priorisation en vigueur, fondée sur le score CVSS : une vulnérabilité de score supérieur ou égal à 8 est traitée sous 7 jours, une vulnérabilité comprise entre 6 et 8 sous 14 jours, et une vulnérabilité mineure sous 90 jours. Le déploiement et le suivi des correctifs reposent sur Tanium, dont j'ai assuré la prise en main et pour lequel j'ai rédigé des procédures d'équipe ; Tanium remplace progressivement WSUS sur le périmètre des serveurs, la gestion des postes utilisateurs devant basculer vers Intune une fois celui-ci déployé. Je participe actuellement à la mise en place d'un déploiement par paliers, appelés rings, sur Tanium, afin de tester les correctifs avant leur généralisation au parc et de limiter les régressions. J'ai par ailleurs mené des actions concrètes de reconfiguration : lors d'un incident réel, une règle d'approbation automatique défaillante sur WSUS avait diffusé une mise à jour problématique provoquant des dysfonctionnements sur des ordinateurs portables. J'ai identifié la cause, puis déployé une stratégie de groupe (GPO) et un script de désinstallation pour retirer la mise à jour en cause et rétablir les postes. Mon rôle de premier répondant sur l'EDR me conduit également à analyser les alertes pour repérer rapidement les postes à corriger. Sur mon homelab, j'exécute des scans de vulnérabilité avec OpenVAS pour détecter les correctifs à appliquer. Wazuh, déployé en instance mono-nœud avec des agents actifs, complète cette visibilité côté hôtes, tandis que la détection réseau est assurée par le moteur Suricata intégré au pare-feu, qui voit les flux entrants et sortants comme les flux entre segments puisqu'il en assure le routage. CrowdSec est déployé devant Traefik, mais je le présente comme un mécanisme en place et non comme une capacité de blocage éprouvée, le homelab étant principalement accessible par VPN.

**Preuves à apporter.**

- Extrait de la politique de priorisation des correctifs fondée sur le score CVSS (Dupont, à anonymiser).
- Capture de la console Tanium montrant l'état des correctifs sur le parc (Dupont, à anonymiser).
- Capture de la GPO créée et extrait du script de désinstallation, rollback de la mise à jour (Dupont, à anonymiser).
- Rapport hebdomadaire de scan OpenVAS du homelab, avec les CVE détectées et leur criticité.
- Extrait d'une alerte EDR ayant conduit à un correctif (Dupont, à anonymiser).
- À venir : capture de la configuration du déploiement par rings dans Tanium.

---

## Compétence 5 : Configurer les équipements réseaux pour assurer l'interconnexion physique et virtuelle des sites

**Énoncé du référentiel.** Configurer les équipements réseaux pour assurer l'interconnexion physique et virtuelle des sites.

**Critère d'évaluation.** Les interconnexions sont opérationnelles.

**Origine de l'acquisition.** J'ai acquis cette compétence sur mon homelab, où j'ai conçu et configuré l'ensemble du réseau, et je l'ai abordée en contexte professionnel comme technicien chez Concentrix.

**Rappel du contexte (voir partie 1).** Mon homelab repose sur un réseau segmenté en plusieurs VLAN, reliant un commutateur physique, un pare-feu et une plateforme de virtualisation, avec un accès distant sécurisé.

**Activités réalisées.** Sur mon homelab, j'ai configuré en ligne de commande un commutateur Cisco 3560X pour créer une dizaine de VLAN correspondant à mes différents usages (administration, production, DMZ, SOC, stockage, invités, entre autres), et j'ai établi un trunk entre ce commutateur et mon pare-feu OPNsense. Le routage inter-VLAN est assuré par OPNsense. J'ai en outre activé le Port Security sur ce commutateur afin de restreindre, port par port, les équipements autorisés à se connecter au réseau physique. Le pare-feu OPNsense assure le routage inter-VLAN, le service DHCP (Kea) et la résolution DNS interne (Unbound). Pour l'interconnexion virtuelle, j'ai propagé cette segmentation jusque dans l'hyperviseur en activant le marquage VLAN sur Proxmox, de sorte que chaque machine virtuelle soit rattachée au segment réseau correspondant à sa fonction. J'ai également mis en place un accès distant sécurisé au moyen d'un tunnel WireGuard, qui me permet de rejoindre mon réseau depuis l'extérieur, avec une mise à jour dynamique de l'enregistrement DNS via Cloudflare. Un port miroir du commutateur alimentait par ailleurs une sonde de détection dédiée, que j'ai décommissionnée en juillet 2026 après une analyse de proportionnalité du risque ; la détection réseau est depuis assurée par le moteur intégré au pare-feu. J'ai enfin corrigé, lors de l'intégration du quatrième nœud, un défaut qui faisait transiter son anneau de quorum par le pare-feu faute de pont dédié, en le ramenant sur son réseau propre. En tant que technicien chez Concentrix, j'ai aussi été amené à intervenir sur des équipements réseau d'entreprise, par exemple pour déployer une règle et modifier les VLAN d'un groupe de postes sur une infrastructure Meraki.

**Preuves à apporter.**

- Schéma de la topologie réseau (VLAN, trunk, routage inter-VLAN et tunnel WireGuard).
- Extraits de configuration du commutateur Cisco (création des VLAN, trunk et Port Security).
- Capture de la configuration VLAN sur Proxmox.
- Capture de la configuration du tunnel WireGuard.
- Captures des étendues DHCP et de la résolution DNS interne.
- Élément oral, sans annexe : l'intervention Meraki chez Concentrix.

---

## Compétence 6 : Administrer les bases de données avec méthode selon la configuration requise pour leur mise en production

**Énoncé du référentiel.** Administrer les bases de données avec méthode selon la configuration requise pour leur mise en production.

**Critère d'évaluation.** Les bases de données sont opérationnelles, une méthode a été utilisée.

**Origine de l'acquisition.** J'ai acquis cette compétence lors de deux travaux pratiques d'administration de bases de données menés à Lille Ynov Campus, les projets ShopSecure et AccessNow, et je la mets en pratique sur les bases de mes services auto-hébergés.

**Rappel du contexte (voir partie 1).** Ces projets m'ont placé en posture d'administrateur de bases de données, chargé de rendre une base cohérente, sécurisée et exploitable en production.

**Activités réalisées.** Sur le projet ShopSecure, j'ai construit le schéma sous PostgreSQL en appliquant une méthode d'intégrité rigoureuse : clés primaires et étrangères, politiques de suppression adaptées (ON DELETE RESTRICT ou CASCADE selon les cas), contraintes CHECK (prix positif, stock non négatif), contraintes UNIQUE et suppression logique pour préserver l'auditabilité. J'ai garanti l'atomicité des opérations critiques par des transactions explicites avec gestion d'erreur et ROLLBACK conditionnel, et automatisé un audit des modifications de prix au moyen d'un trigger PL/pgSQL. Sur le projet final AccessNow, une base de gestion d'accès multi-pays réalisée en binôme, j'ai mené une démarche complète de mise en production : audit du modèle existant, corrections d'intégrité, application stricte du principe du moindre privilège par des rôles PostgreSQL distincts avec tests des droits autorisés et interdits, gestion de la cohérence en cas d'incident, et prise en compte de la conformité RGPD par anonymisation sans rompre la traçabilité. Ce projet a été évalué à 20 sur 20. Sur mon homelab, j'administre par ailleurs les bases de données de mes services auto-hébergés, que j'ai configurées et mises en service moi-même.

**Preuves à apporter.**

- Scripts SQL du projet ShopSecure : tables et contraintes, transaction ACID, fonction et trigger d'audit.
- Scripts du projet AccessNow : evolutions.sql, dcl.sql et tests_dcl.sql, coherence.sql, rgpd.sql, ainsi que le document de modélisation.
- Relevé de note attestant le résultat de 20 sur 20.

---

## Compétence 7 : Mesurer et analyser les performances pour optimiser le stockage en vue de faciliter les accès

**Énoncé du référentiel.** Mesurer et analyser les performances pour optimiser le stockage en vue de faciliter les accès.

**Critère d'évaluation.** Les temps de réponse sont satisfaisants.

**Origine de l'acquisition.** J'ai acquis cette compétence lors du projet ShopSecure à Lille Ynov Campus, sur un volet dédié au diagnostic de performance.

**Rappel du contexte (voir partie 1).** Le scénario simulait la dégradation d'un rapport client à la suite d'une forte hausse du volume de commandes, l'objectif étant de ramener le temps de réponse à un niveau satisfaisant.

**Activités réalisées.** Après avoir injecté environ cinquante mille lignes dans la table des commandes pour reproduire un volume réaliste, j'ai diagnostiqué la requête lente du support client à l'aide de la commande EXPLAIN ANALYZE. L'analyse du plan d'exécution a révélé un parcours séquentiel complet de la table et m'a permis de mesurer le temps d'exécution réel. J'ai ainsi localisé précisément le goulot d'étranglement, en m'appuyant sur la lecture du plan plutôt que sur des suppositions.

**Preuves à apporter.**

- Script de simulation des données (environ cinquante mille commandes).
- Sortie de EXPLAIN ANALYZE avant optimisation, montrant le parcours séquentiel et le temps d'exécution mesuré.

---

## Compétence 8 : Améliorer les performances des bases de données en optimisant l'emplacement des stockages

**Énoncé du référentiel.** Améliorer les performances des bases de données en optimisant l'emplacement des stockages.

**Critère d'évaluation.** La fluidité des accès aux données est assurée.

**Origine de l'acquisition.** J'ai acquis cette compétence dans la continuité du diagnostic précédent, lors du projet ShopSecure, et lors du volet de gestion des journaux longue durée du projet AccessNow.

**Rappel du contexte (voir partie 1).** Une fois la requête lente diagnostiquée, il s'agissait de rétablir la fluidité des accès par un placement pertinent des données.

**Activités réalisées.** Pour corriger le parcours séquentiel identifié, j'ai créé un index composite sur la table des commandes, en ordonnant les colonnes selon leur sélectivité : le code postal, puis le statut, puis la date de commande en ordre décroissant. Cet ordre permet à la fois un filtrage efficace et l'élimination de l'étape de tri coûteuse. J'ai validé le gain en relançant EXPLAIN ANALYZE, ce qui a confirmé le remplacement du parcours séquentiel par un parcours d'index et une nette réduction du temps de réponse. Sur le projet AccessNow, dont les journaux d'accès devaient être conservés au moins dix ans, j'ai aussi traité la question du volume par une stratégie de partitionnement et d'archivage, afin de préserver la fluidité des accès malgré la croissance des données.

**Preuves à apporter.**

- Script de création de l'index composite.
- Sorties de EXPLAIN ANALYZE avant et après optimisation, avec le calcul du gain de performance.
- Extrait de la stratégie de gestion des journaux longue durée (partitionnement et archivage) du projet AccessNow.

---

## Compétence 9 : Rationaliser les tâches quotidiennes en rédigeant des scripts et en les intégrant dans des procédures d'exploitation automatisées

**Énoncé du référentiel.** Rationaliser les tâches quotidiennes en rédigeant des scripts et en les intégrant dans des procédures d'exploitation automatisées.

**Critère d'évaluation.** Accroissement de la productivité constaté.

**Origine de l'acquisition.** L'automatisation est un axe que je pratique depuis mon poste de chargé de flux chez Concentrix, que j'ai poursuivi dans mon alternance chez Dupont Restauration, et que j'approfondis sur mon homelab.

**Rappel du contexte (voir partie 1).** Comme chargé de flux, je devais fiabiliser et accélérer un reporting quotidien. Chez Dupont Restauration, j'automatise le suivi d'indicateurs de sécurité récurrents. Sur mon homelab, j'industrialise le déploiement et l'exploitation de mes services.

**Activités réalisées.** En tant que chargé de flux chez Concentrix, sur le projet Younited-Credit, j'ai conçu des scripts VBA pilotant PowerQuery pour automatiser l'ingestion de douze fichiers d'export quotidiens, leur consolidation en vue d'analyses mensuelles et annuelles, puis la génération d'un courriel de synthèse prêt à l'envoi. Cette automatisation a réduit sensiblement le temps de production du reporting et fiabilisé les données transmises. Chez Dupont Restauration, j'ai mis en place des flux PowerAutomate qui orchestrent le dépôt et la récupération de fichiers sur SharePoint afin de calculer automatiquement les indicateurs des campagnes de sensibilisation à la cybersécurité, ce qui supprime un traitement manuel hebdomadaire. J'ai également configuré une tâche planifiée exécutant un script d'export des utilisateurs actifs de l'Active Directory ; par précaution, la récupération finale du fichier reste manuelle, afin d'éviter toute sortie non maîtrisée de données sensibles. Sur mon homelab, j'industrialise l'exploitation au moyen d'un modèle doré Debian 13 construit avec Packer, de VM déployées avec OpenTofu et cloud-init, puis configurées et mises à jour avec Ansible. Des fichiers Docker Compose décrivent et reproduisent les services. Des timers systemd déclenchent notamment les sauvegardes, les vérifications d'intégrité et les contrôles de santé. Le renouvellement des certificats Let's Encrypt et la mise à jour dynamique du DNS via Cloudflare sont également automatisés. Le projet CV-as-Code reste un chantier et n'est pas présenté comme une chaîne en production.

**Preuves à apporter.**

- Capture du flux PowerAutomate de calcul des indicateurs (Dupont, à anonymiser).
- Vue du planificateur de tâches Windows et extrait du script d'export Active Directory (Dupont, à anonymiser).
- Exemples de fichiers Docker Compose, du modèle Packer, de la configuration OpenTofu et des playbooks Ansible du homelab.
- Extraits des unités et timers systemd utilisés pour les tâches récurrentes.
- Le cas échéant, extrait commenté du code VBA et de la requête PowerQuery, si une copie personnelle a été conservée (sinon, élément oral).

---

## Compétence 10 : Faciliter la résolution des problèmes par une analyse des journaux d'historiques systèmes

**Énoncé du référentiel.** Faciliter la résolution des problèmes par une analyse des journaux d'historiques systèmes.

**Critère d'évaluation.** Les problèmes détectés sont résolus avec agilité.

**Origine de l'acquisition.** J'ai développé cette compétence comme technicien chez Concentrix, où le diagnostic reposait sur la lecture des journaux système, puis dans mon alternance chez Dupont Restauration en tant que premier répondant SOC, et je l'industrialise sur mon homelab.

**Rappel du contexte (voir partie 1).** L'analyse de journaux est indispensable pour diagnostiquer les pannes et lever les doutes lors d'incidents de sécurité. Je l'exerce aussi bien sur des postes Windows que sur mon infrastructure personnelle.

**Activités réalisées.** Comme technicien chez Concentrix, j'utilisais l'Observateur d'événements Windows pour remonter à la cause d'un dysfonctionnement. Sur un poste qui redémarrait fréquemment, par exemple, l'analyse des journaux d'arrêt (identifiant d'événement 1074) m'a permis de démontrer que les redémarrages étaient déclenchés manuellement par l'utilisateur et non par une panne, ce qui a permis de clore l'incident sur une base factuelle. Chez Dupont Restauration, j'interviens comme premier répondant sur certaines alertes EDR : à partir d'une alerte, j'examine les événements pour contribuer à sa qualification, appliquer ou proposer la remédiation et formaliser une analyse post-mortem. Dans le cadre du COSECOPS, mon rôle est celui d'un contributeur : je dépose notamment un rapport mensuel PingCastle et je challenge le SOC sur les constats observés, sans me présenter comme responsable ou animateur du SOC. Sur mon homelab, j'ai mis en place une centralisation des journaux avec Loki et Promtail, que j'interroge et visualise dans Grafana pour disposer d'une vision d'ensemble de l'état de mes machines et corréler les événements. J'ai également exploité une sonde de détection réseau, avec Suricata et Zeek, jusqu'à son décommissionnement en juillet 2026. J'en ai tiré une démonstration que je documente : sur un flux interne entre deux machines d'un même segment, la sonde a produit une alerte que le SIEM hôte n'a pas vue, tandis que celui-ci relevait des authentifications que la sonde ne pouvait pas observer. Cette mise en regard, conduite avant l'extinction parce qu'elle n'aurait plus été reproductible ensuite, m'a surtout appris à chercher les angles morts d'un outil plutôt qu'à lui faire confiance. J'exploite enfin les journaux de filtrage du pare-feu pour ajuster mes règles et comprendre les rejets de flux légitimes.

**Preuves à apporter.**

- Extrait de l'analyse post-mortem d'une alerte SOC (Dupont, à anonymiser).
- Tableau de bord Grafana présentant les journaux centralisés via Loki sur le homelab.
- Synthèse écrite de la détection est-ouest : captures de la sonde, mise en regard du SIEM hôte et angles morts identifiés.
- Capture de l'interface de filtrage des journaux d'OPNsense.
- Extrait de l'Observateur d'événements Windows illustrant un diagnostic.
- Élément oral, sans annexe : le diagnostic du poste qui redémarrait (identifiant 1074) chez Concentrix.

---

## Compétence 11 : Automatiser les procédures de sauvegarde en rédigeant des scripts et en les intégrant avec des outils d'exploitation systèmes

**Énoncé du référentiel.** Automatiser les procédures de sauvegarde en rédigeant des scripts et en les intégrant avec des outils d'exploitation systèmes.

**Critère d'évaluation.** Les coûts d'exploitation sont réduits.

**Origine de l'acquisition.** N'ayant pas exercé cette tâche en entreprise, j'ai conçu et mis en place une procédure de sauvegarde automatisée sur mon homelab, à partir d'une réflexion structurée sur les besoins, les contraintes et les bonnes pratiques.

**Rappel du contexte (voir partie 1).** Mon homelab héberge des données personnelles et familiales sensibles, dont un gestionnaire de mots de passe, un cloud et une photothèque, dont la perte serait critique. Cela justifie une stratégie de sauvegarde fiable et automatisée.

**Activités réalisées.** J'ai identifié les données critiques puis déployé une chaîne de sauvegarde conforme à une stratégie 3-2-1-1-0 : plusieurs copies des données sur des supports différents, dont une hors site et une hors ligne, avec une intégrité vérifiée par des contrôles et des tests de restauration. Sur chacune des huit VM concernées, des scripts produisent chaque jour des dumps des bases et des configurations, puis les chiffrent localement avec OpenSSL en AES-256-CBC et PBKDF2, selon une rotation de sept sauvegardes quotidiennes, quatre hebdomadaires et trois mensuelles. Des unités et timers systemd déclenchent les traitements, appliquent un verrou commun pour éviter les exécutions concurrentes et produisent des journaux exploitables. Un contrôle quotidien vérifie la fraîcheur des archives, leur format et leur déchiffrabilité ; toute anomalie est remontée par ntfy. La copie hors site est automatisée : depuis le poste de contrôle, la dernière sauvegarde quotidienne de chaque VM est collectée puis versée dans un dépôt restic chiffré côté client avant envoi vers un stockage en ligne, avec une rétention de sept quotidiennes, quatre hebdomadaires et six mensuelles par hôte, suivie d'un contrôle d'intégrité du dépôt. La copie hors ligne repose sur une clé USB chiffrée en LUKS, branchée uniquement le temps de la copie puis conservée hors site ; elle reçoit les dernières archives de chaque VM, leurs clés de chiffrement, un manifeste d'empreintes SHA-256 et la procédure de restauration. J'ai validé la chaîne par des tests de restauration réels : un snapshot restauré le 22 juillet depuis le dépôt hors site, avec vérification de l'intégrité des dumps et du déchiffrement des archives ; la branche hors ligne a été mise en place et contrôlée après sauvegarde, mais je n'ai pas encore conduit de restauration complète depuis ce support. Cette automatisation supprime la manipulation quotidienne et réduit le coût d'exploitation ; le rituel de la clé USB reste volontairement manuel et son objectif de perte de données maximale est assumé.

**Preuves à apporter.**

- Extraits anonymisés des scripts de dump, de chiffrement OpenSSL et de rotation.
- Unités systemd associées, service et timer, avec journal d'une exécution réussie.
- Journal du contrôle quotidien de fraîcheur, de format et de déchiffrabilité, et capture d'une notification ntfy.
- Configuration expurgée de la copie hors site restic et journal d'une exécution avec rétention et contrôle d'intégrité.
- Manifeste d'empreintes et procédure de restauration écrits sur la clé USB chiffrée, copie hors ligne.
- Procès-verbal du test de restauration du 22 juillet depuis le dépôt hors site : périmètre, étapes, durée, contrôles effectués et résultat.

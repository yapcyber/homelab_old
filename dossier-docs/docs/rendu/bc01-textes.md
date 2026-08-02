---
title: "BC01 — textes du rendu"
sidebar_position: 1
---

# BC01 — textes du rendu

:::caution Rafraîchissement factuel requis avant le rendu
Ces onze textes ont été figés **avant** les chantiers de fin juillet 2026. Quatre
points ne décrivent plus l'infrastructure réelle et doivent être repris :

1. **Security Onion** (C1, C5, C10) : la sonde a été **décommissionnée le 31 juillet 2026**
   et sa machine reversée en quatrième nœud. À réécrire **au passé**, comme une brique
   exploitée puis retirée sur analyse de proportionnalité du risque. Cet arbitrage est
   plus fort qu'un outil en place. La détection réseau est reprise par le moteur intégré
   au pare-feu.
2. **Taille du cluster** (C2, C3) : « trois nœuds » est devenu **quatre nœuds**, plus un
   arbitre de quorum externe opérationnel depuis le 1er août 2026.
3. **Haute disponibilité** (C3) : elle est **armée mais non testée**. Le test de bascule
   est reporté tant que la répartition mémoire ne permet pas qu'il aboutisse. Ne pas
   décrire une bascule automatique comme démontrée.
4. **Ratio de consolidation** (C2) : le décompte des services et des machines a changé.
   À refiger depuis l'inventaire des actifs, en cohérence avec
   [BC02 C16](/blocs/bc02/c16).

Le point de vigilance historique sur les sauvegardes est en revanche **levé** : le texte
de C11 décrivait une cible, elle est devenue réelle le 22 juillet 2026.
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

**Activités réalisées.** Chez Dupont Restauration, je participe chaque matin au journal d'exploitation, dont je tiens la partie sécurité. Cette vérification quotidienne d'une vingtaine de points conditionne le démarrage de la production et confirme que les services concernés sont opérationnels avant l'ouverture. J'ai également mené des actions concrètes d'exploitation, comme la création d'une stratégie de groupe (GPO) pour appliquer un paramètre de sécurité, et l'exécution d'un script de désinstallation d'un logiciel et d'une mise à jour (KB) sur le parc. Sur la continuité de service, je suis intervenu en première ligne lors de la panne CrowdStrike de juillet 2024, alors technicien chez Concentrix. Une fois la remédiation identifiée, je l'ai appliquée manuellement sur plus de cinq cents postes en saisissant la clé BitLocker et en supprimant le fichier défaillant, tout en surveillant le rétablissement du réseau pour indiquer aux équipes la marche à suivre lors de la reprise. J'ai par ailleurs contribué au traitement d'une alerte remontée par le SOC chez Dupont Restauration, de l'analyse à la remédiation, et participé à la rédaction de l'analyse post-mortem associée. Sur mon homelab, je maintiens en fonctionnement continu une infrastructure virtualisée sous Proxmox VE, qui héberge mes services derrière un pare-feu OPNsense, avec une supervision de la détection assurée par Security Onion. J'y administre de bout en bout un service DNS et un service DHCP, ce qui me permet de couvrir un spectre de savoir-faire système plus large que mon périmètre en entreprise.

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

**Activités réalisées.** J'ai conçu une plateforme de virtualisation sous Proxmox VE 9.2.2, organisée en cluster de trois nœuds reposant sur trois mini-PC, afin d'héberger l'ensemble de mes services sur un nombre réduit de machines physiques. Sur ce socle, je fais cohabiter cinq machines virtuelles porteuses de services : une VM d'infrastructure (Traefik, Authentik, Homarr), une VM de supervision (Prometheus, Grafana, Loki), une VM cloud (Nextcloud, Immich, Vaultwarden), une VM média (Jellyfin et la suite Arr) et une VM de stockage (TrueNAS). Chacun de ces ensembles pourrait à lui seul justifier un serveur dédié. À l'intérieur des VM, j'utilise Docker et Docker Compose pour isoler chaque application, ce qui me permet de regrouper une dizaine de services sur seulement trois petites machines. Dans un modèle classique où chaque service correspondrait à un serveur dédié, cette architecture aurait demandé une quinzaine de machines physiques ; je les ai regroupées sur trois hôtes, soit un ratio d'environ cinq services par machine. Pour fiabiliser et standardiser les déploiements, je pars d'un modèle de VM Debian 12 avec cloud-init et clé SSH, et je place les disques sur un stockage partagé en NFS afin que les machines restent migrables d'un nœud à l'autre. J'ai réalisé moi-même le dimensionnement des ressources de chaque machine, en cherchant à équilibrer l'ensemble : une allocation au plus juste pour les applications de service et une marge plus large pour les briques de sécurité.

**Preuves à apporter.**

- Schéma d'architecture de la plateforme virtualisée (cluster Proxmox à trois nœuds et VM hébergées).
- Tableau d'allocation des ressources rempli avec les valeurs réelles (CPU, RAM et stockage des hôtes ; vCPU, RAM, disque et services par VM) et ligne de synthèse de la consolidation avec le ratio.
- Capture Proxmox VE du cluster et de la liste des VM avec leurs ressources.
- Modèle de VM et configuration cloud-init illustrant l'industrialisation du déploiement.

---

## Compétence 3 : Maintenir en conditions opérationnelles l'infrastructure en utilisant des logiciels de gestion de la haute disponibilité

**Énoncé du référentiel.** Maintenir en conditions opérationnelles l'infrastructure de l'entreprise en utilisant des logiciels de gestion de la haute disponibilité.

**Critère d'évaluation.** Le taux de disponibilité observé est conforme aux exigences de l'exploitation.

**Origine de l'acquisition.** J'ai mis en œuvre cette compétence sur mon homelab, où j'ai conçu la haute disponibilité du cluster, et je la complète par ma participation quotidienne à la vérification de disponibilité chez Dupont Restauration.

**Rappel du contexte (voir partie 1).** Sur mon homelab, plusieurs services sont utilisés au quotidien par mes proches, ce qui m'impose de viser une disponibilité continue. Chez Dupont Restauration, la disponibilité des systèmes conditionne le démarrage de la production chaque matin.

**Activités réalisées.** Sur mon homelab, j'ai mis en place la haute disponibilité native de Proxmox VE sur un cluster de trois nœuds. La communication entre les nœuds repose sur Corosync, sur un réseau dédié, pour maintenir le quorum, et le gestionnaire de haute disponibilité, couplé à un chien de garde (watchdog), redémarre automatiquement les machines virtuelles concernées sur un nœud survivant en cas de défaillance. Cette bascule est rendue possible par un stockage partagé en NFS, qui rend les disques des machines accessibles depuis n'importe quel nœud du cluster. Pour observer la disponibilité réelle et détecter les anomalies, j'exploite une supervision dédiée reposant sur Prometheus, Grafana et Loki, qui me fournit des indicateurs et des tableaux de bord sur l'état de l'infrastructure. Chez Dupont Restauration, je tiens chaque matin le volet sécurité du journal d'exploitation, dont la vérification d'une vingtaine de points conditionne la disponibilité des services avant l'ouverture de la production.

**Preuves à apporter.**

- Capture Proxmox VE montrant la haute disponibilité activée sur les machines virtuelles et l'état du quorum du cluster.
- Tableau de bord de disponibilité (Uptime Kuma) présentant le taux observé sur une à deux semaines, avec l'historique des incidents éventuels.
- Extrait du journal d'exploitation, volet sécurité (Dupont, à anonymiser).

---

## Compétence 4 : Identifier rapidement les systèmes qui nécessitent des correctifs et qui doivent être reconfigurés en fonction des préconisations constructeurs

**Énoncé du référentiel.** Identifier rapidement les systèmes qui nécessitent des correctifs et qui doivent être reconfigurés en fonction des préconisations constructeurs.

**Critère d'évaluation.** Les correctifs sont appliqués, les paramètres systèmes sont ajustés et cohérents.

**Origine de l'acquisition.** J'ai développé cette compétence dans le cadre de mon alternance chez Dupont Restauration, où le maintien en condition de sécurité fait partie de mes missions, et je la prolonge sur mon homelab.

**Rappel du contexte (voir partie 1).** Chez Dupont Restauration, je contribue au maintien en condition de sécurité du parc, ce qui suppose d'identifier les systèmes vulnérables ou non conformes et d'y appliquer les correctifs ou les ajustements nécessaires.

**Activités réalisées.** Chez Dupont Restauration, je propose des mises à jour et je réalise des scans de vulnérabilité pour identifier les systèmes à corriger, puis j'applique la politique de priorisation en vigueur, fondée sur le score CVSS : une vulnérabilité de score supérieur ou égal à 8 est traitée sous 7 jours, une vulnérabilité comprise entre 6 et 8 sous 14 jours, et une vulnérabilité mineure sous 90 jours. Le déploiement et le suivi des correctifs reposent sur Tanium, dont j'ai assuré la prise en main et pour lequel j'ai rédigé des procédures d'équipe ; Tanium remplace progressivement WSUS sur le périmètre des serveurs, la gestion des postes utilisateurs devant basculer vers Intune une fois celui-ci déployé. Je participe actuellement à la mise en place d'un déploiement par paliers, appelés rings, sur Tanium, afin de tester les correctifs avant leur généralisation au parc et de limiter les régressions. J'ai par ailleurs mené des actions concrètes de reconfiguration : lors d'un incident réel, une règle d'approbation automatique défaillante sur WSUS avait diffusé une mise à jour problématique provoquant des dysfonctionnements sur des ordinateurs portables. J'ai identifié la cause, puis déployé une stratégie de groupe (GPO) et un script de désinstallation pour retirer la mise à jour en cause et rétablir les postes. Mon rôle de premier répondant sur l'EDR me conduit également à analyser les alertes pour repérer rapidement les postes à corriger. Sur mon homelab, j'exécute chaque semaine un scan de vulnérabilité avec OpenVAS pour détecter les correctifs à appliquer, et je m'appuie sur Security Onion et CrowdSec pour repérer les comportements anormaux pouvant signaler un système à reconfigurer.

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

**Activités réalisées.** Sur mon homelab, j'ai configuré en ligne de commande un commutateur Cisco 3560X pour créer et router une dizaine de VLAN correspondant à mes différents usages (administration, production, DMZ, SOC, stockage, invités, entre autres), et j'ai établi un lien d'agrégation (trunk) entre ce commutateur et mon pare-feu OPNsense. J'ai en outre activé le Port Security sur ce commutateur afin de restreindre, port par port, les équipements autorisés à se connecter au réseau physique. Le pare-feu OPNsense assure le routage inter-VLAN, le service DHCP (Kea) et la résolution DNS interne (Unbound). Pour l'interconnexion virtuelle, j'ai propagé cette segmentation jusque dans l'hyperviseur en activant le marquage VLAN sur Proxmox, de sorte que chaque machine virtuelle soit rattachée au segment réseau correspondant à sa fonction. J'ai également mis en place un accès distant sécurisé au moyen d'un tunnel WireGuard, qui me permet de rejoindre mon réseau depuis l'extérieur, avec une mise à jour dynamique de l'enregistrement DNS via Cloudflare. Une copie du trafic est par ailleurs dirigée par SPAN vers ma sonde Security Onion. En tant que technicien chez Concentrix, j'ai aussi été amené à intervenir sur des équipements réseau d'entreprise, par exemple pour déployer une règle et modifier les VLAN d'un groupe de postes sur une infrastructure Meraki.

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

**Activités réalisées.** En tant que chargé de flux chez Concentrix, sur le projet Younited-Credit, j'ai conçu des scripts VBA pilotant PowerQuery pour automatiser l'ingestion de douze fichiers d'export quotidiens, leur consolidation en vue d'analyses mensuelles et annuelles, puis la génération d'un courriel de synthèse prêt à l'envoi. Cette automatisation a réduit sensiblement le temps de production du reporting et fiabilisé les données transmises. Chez Dupont Restauration, j'ai mis en place des flux PowerAutomate qui orchestrent le dépôt et la récupération de fichiers sur SharePoint afin de calculer automatiquement les indicateurs des campagnes de sensibilisation à la cybersécurité, ce qui supprime un traitement manuel hebdomadaire. J'ai également configuré une tâche planifiée exécutant un script d'export des utilisateurs actifs de l'Active Directory ; par précaution, la récupération finale du fichier reste manuelle, afin d'éviter toute sortie non maîtrisée de données sensibles. Sur mon homelab, j'industrialise l'exploitation au moyen d'un modèle de machine virtuelle avec cloud-init pour standardiser les déploiements, de fichiers docker-compose pour décrire et reproduire mes services, du renouvellement automatique des certificats Let's Encrypt et de la mise à jour dynamique du DNS via Cloudflare. J'ai par ailleurs développé un projet personnel d'automatisation, CV-as-Code, un pipeline en Python auto-hébergé qui ingère des courriels en IMAP, applique un filtrage déterministe, puis produit des documents par intégration continue, de Markdown vers PDF.

**Preuves à apporter.**

- Capture du flux PowerAutomate de calcul des indicateurs (Dupont, à anonymiser).
- Vue du planificateur de tâches Windows et extrait du script d'export Active Directory (Dupont, à anonymiser).
- Exemples de fichiers docker-compose et du modèle cloud-init du homelab.
- Extrait du dépôt public et de la chaîne d'intégration continue du projet CV-as-Code.
- Le cas échéant, extrait commenté du code VBA et de la requête PowerQuery, si une copie personnelle a été conservée (sinon, élément oral).

---

## Compétence 10 : Faciliter la résolution des problèmes par une analyse des journaux d'historiques systèmes

**Énoncé du référentiel.** Faciliter la résolution des problèmes par une analyse des journaux d'historiques systèmes.

**Critère d'évaluation.** Les problèmes détectés sont résolus avec agilité.

**Origine de l'acquisition.** J'ai développé cette compétence comme technicien chez Concentrix, où le diagnostic reposait sur la lecture des journaux système, puis dans mon alternance chez Dupont Restauration en tant que premier répondant SOC, et je l'industrialise sur mon homelab.

**Rappel du contexte (voir partie 1).** L'analyse de journaux est indispensable pour diagnostiquer les pannes et lever les doutes lors d'incidents de sécurité. Je l'exerce aussi bien sur des postes Windows que sur mon infrastructure personnelle.

**Activités réalisées.** Comme technicien chez Concentrix, j'utilisais l'Observateur d'événements Windows pour remonter à la cause d'un dysfonctionnement. Sur un poste qui redémarrait fréquemment, par exemple, l'analyse des journaux d'arrêt (identifiant d'événement 1074) m'a permis de démontrer que les redémarrages étaient déclenchés manuellement par l'utilisateur et non par une panne, ce qui a permis de clore l'incident sur une base factuelle. Chez Dupont Restauration, mon rôle de premier répondant sur le SOC et l'EDR repose directement sur l'analyse des journaux : à partir d'une alerte, j'examine les événements pour qualifier l'incident, identifier la remédiation et formaliser une analyse post-mortem, comme lors du traitement d'une alerte que j'ai suivie de l'analyse jusqu'à la remédiation. Sur mon homelab, j'ai mis en place une centralisation des journaux avec Loki et Promtail, que j'interroge et visualise dans Grafana pour disposer d'une vision d'ensemble de l'état de mes machines et corréler les événements. J'exploite également ma sonde Security Onion, avec Suricata et Zeek, pour analyser le trafic réseau et lever les doutes sur des comportements suspects, ainsi que les journaux de filtrage d'OPNsense pour ajuster mes règles et comprendre les rejets de flux légitimes.

**Preuves à apporter.**

- Extrait de l'analyse post-mortem d'une alerte SOC (Dupont, à anonymiser).
- Tableau de bord Grafana présentant les journaux centralisés via Loki sur le homelab.
- Capture d'une analyse dans Security Onion.
- Capture de l'interface de filtrage des journaux d'OPNsense.
- Extrait de l'Observateur d'événements Windows illustrant un diagnostic.
- Élément oral, sans annexe : le diagnostic du poste qui redémarrait (identifiant 1074) chez Concentrix.

---

## Compétence 11 : Automatiser les procédures de sauvegarde en rédigeant des scripts et en les intégrant avec des outils d'exploitation systèmes

**Énoncé du référentiel.** Automatiser les procédures de sauvegarde en rédigeant des scripts et en les intégrant avec des outils d'exploitation systèmes.

**Critère d'évaluation.** Les coûts d'exploitation sont réduits.

**Origine de l'acquisition.** N'ayant pas exercé cette tâche en entreprise, j'ai conçu et mis en place une procédure de sauvegarde automatisée sur mon homelab, à partir d'une réflexion structurée sur les besoins, les contraintes et les bonnes pratiques.

**Rappel du contexte (voir partie 1).** Mon homelab héberge des données personnelles et familiales sensibles, dont un gestionnaire de mots de passe, un cloud et une photothèque, dont la perte serait critique. Cela justifie une stratégie de sauvegarde fiable et automatisée.

**Activités réalisées.** J'ai d'abord identifié les données critiques et leur niveau d'exigence, puis défini une stratégie reposant sur la règle 3-2-1 : une copie de production, une copie locale et une copie hors site. J'ai retenu une approche à deux niveaux. Au niveau des machines virtuelles, j'utilise les sauvegardes intégrées de Proxmox pour disposer d'images restaurables. Au niveau des données applicatives, j'ai écrit des scripts produisant des sauvegardes cohérentes des bases (dump PostgreSQL, MariaDB et SQLite) et des répertoires de données, que je confie à restic pour le chiffrement, la déduplication et la rotation selon une politique de rétention définie. Ces scripts sont déclenchés par des timers systemd, ce qui les intègre proprement à l'exploitation du système et fournit une journalisation exploitable. La copie hors site est envoyée chiffrée vers un stockage objet, ce qui fonctionne malgré le double NAT puisque la connexion est sortante. Enfin, j'ai relié le résultat des sauvegardes à ma supervision pour être alerté en cas d'échec, et je vérifie périodiquement l'intégrité des dépôts ainsi que la restauration. Cette automatisation supprime toute manipulation manuelle quotidienne et réduit d'autant le coût d'exploitation.

**Preuves à apporter** (après déploiement de la solution).

- Schéma de la stratégie de sauvegarde (règle 3-2-1, niveaux machine virtuelle et données).
- Extraits des scripts et des unités systemd associées (service et timer).
- Capture de la politique de rétention restic (sortie de restic snapshots et de la politique forget).
- Capture de la remontée des sauvegardes dans la supervision.
- Journal d'un test de restauration réussi.

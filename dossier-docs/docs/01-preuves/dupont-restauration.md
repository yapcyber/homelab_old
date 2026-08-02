---
title: Preuves Dupont Restauration
sidebar_position: 2
---

# Preuves à récupérer chez Dupont Restauration

> Liste des pièces que **seule l'alternance peut fournir** : elles n'existent
> ni dans le homelab, ni dans les projets académiques. Chaque entrée précise
> les compétences visées, l'information qui doit apparaître sur la pièce, et
> la contrainte d'anonymisation.

**34 des 61 compétences** du référentiel s'appuient au moins partiellement sur
une preuve d'entreprise : 5 sur BC01, 8 sur BC02, 12 sur BC03 et 9 sur BC04.
C'est le gisement le plus dépendant d'un tiers, et donc celui dont le délai
d'obtention est le moins maîtrisé. À traiter en premier.

**Statuts :**
**À extraire** — j'y ai accès, il reste à sortir la pièce et à l'anonymiser ·
**À demander** — nécessite l'accord d'un tiers (tuteur, collègue, RSSI) ·
**Oral** — élément réel, sans trace exploitable, présenté sans annexe.

:::tip Inventaire réel au 2 août 2026 : la collecte est très avancée
L'encart précédent, qui annonçait qu'aucune pièce n'était collectée, était
périmé. **117 fichiers de preuves sont présents**, et la numérotation de
`preuves/preuves_dossier/` suit exactement les 34 pièces listées ci-dessous.

| Emplacement | Fichiers | Nature |
|---|---|---|
| `preuves/` racine | 33 | Dupont, nommées par sujet |
| `preuves/preuves_dossier/` | 65 | Dupont, numérotées selon les 34 pièces. 26 à anonymiser, 39 à vérifier |
| `preuves/preuves_2/` | 10 | Compléments Dupont |
| `preuves/preuves_homelab/` | 9 | Détection est-ouest, plus la synthèse rédigée |

**Deux verrous ont sauté.** La **pièce 27**, console MDM, est obtenue : c'était
la demande la plus ancienne de la liste. La **pièce 25**, PingCastle et sa
transmission au SOC, l'est également.

**Il manque huit pièces sur 34** : 16, 17, 19, 21, 23, 32, 33 et 34. Cinq
dépendent d'un tiers, leur délai ne t'appartient pas : ce sont elles qui
partent en premier.
:::

:::danger Le vrai goulot est l'anonymisation
**Aucun des 108 fichiers Dupont n'est anonymisé à ce jour.** Plusieurs captures
laissent lire la raison sociale, des noms de personnes, des noms d'hôtes et des
identifiants internes. C'est le poste de travail le plus lourd du dossier,
estimé de 8 à 12 heures, et il est purement mécanique.

Une preuve non anonymisée est inutilisable, donc une compétence non prouvée.
Prioriser les pièces qui servent plusieurs compétences chacune : 7, 9, 11 à 14,
24, 25, 27 et 28.
:::

## Règles applicables à toutes les pièces

Ces règles viennent de [l'état de la rédaction](/rendu/etat-redaction) et
s'appliquent sans exception :

- Toute preuve d'entreprise est **anonymisée ou floutée** avant insertion :
  raison sociale, noms de personnes, adresses de courriel, noms de serveurs,
  adresses IP internes, identifiants de tickets, logos.
- Ce qui doit rester lisible, c'est **la structure et la démarche**, pas la
  donnée métier. Une capture illisible ne prouve rien ; une capture trop
  précise ne peut pas être annexée.
- Un élément réel sans trace exploitable est classé **oral uniquement, sans
  annexe**. Il n'est jamais annoncé comme une annexe.
- Le positionnement hiérarchique n'est jamais gonflé : contributeur reste
  contributeur, alternant reste alternant.

## Exploitation quotidienne

### 1. Journal d'exploitation, volet sécurité

**Compétences :** BC01 C1 · BC01 C3 · BC03 C14

**Ce qui doit apparaître :** la structure du journal et le fait qu'il est tenu
**chaque matin avant l'ouverture de la production** ; la **vingtaine de points
de vérification** ; l'identification du volet sécurité comme étant celui dont
j'ai la charge. Pour BC03 C14, seules les **grandes catégories** de points
sont nécessaires : ce sont elles qui démontrent l'identification des éléments
critiques pour la continuité, pas le détail des contrôles.

**Anonymisation :** ne conserver que les intitulés de catégories. Retirer les
noms de systèmes, de sites et de services, ainsi que toute valeur relevée.

**Statut :** À extraire.

## Correctifs et gestion du parc (Tanium, WSUS)

### 2. Politique de priorisation fondée sur le score CVSS

**Compétences :** BC01 C4 · BC03 C10

**Ce qui doit apparaître :** les trois seuils tels qu'ils sont appliqués —
score supérieur ou égal à 8 traité sous **7 jours**, score compris entre 6 et 8
sous **14 jours**, vulnérabilité mineure sous **90 jours** — et le fait que
cette politique est **celle de l'entreprise**, que j'applique, et non une règle
que j'aurais définie.

**Anonymisation :** extrait de la procédure ou du support interne, en-tête
retiré.

**Statut :** À extraire.

### 3. Console Tanium, état des correctifs sur le parc

**Compétences :** BC01 C4 · BC03 C10

**Ce qui doit apparaître :** le taux de conformité du parc et la répartition
des correctifs par état, à une date donnée. C'est la preuve que les correctifs
sont **effectivement appliqués**, ce qu'exige le critère de BC01 C4.

**Anonymisation :** flouter les noms de machines et d'utilisateurs ; conserver
les compteurs et les pourcentages.

**Statut :** À demander (capture de console, autorisation à confirmer).

### 4. Déploiement par paliers (rings) sur Tanium

**Compétences :** BC02 C4 · BC02 C5

**Ce qui doit apparaître :** la **composition des paliers** et leur ordre de
passage, qui démontrent que les correctifs sont testés sur un périmètre
restreint avant généralisation au parc. C'est exactement le critère de BC02 C5
(« solutions maquettées ou procédures établies ») et l'ordonnancement demandé
par BC02 C4.

**Anonymisation :** conserver le nombre de machines par palier, retirer leur
identification.

**Statut :** À extraire.

### 5. Transition WSUS vers Tanium

**Compétences :** BC02 C5 · BC02 C9

**Ce qui doit apparaître :** la **coexistence des deux outils** pendant la
bascule, le périmètre couvert par chacun (Tanium remplace WSUS sur les
serveurs, les postes utilisateurs doivent basculer vers Intune une fois
celui-ci déployé), et la gestion du risque associée. C'est une migration
d'architecture réelle, menée par étapes.

**Anonymisation :** schéma ou note de cadrage reformulée si aucun document
n'est extractible tel quel.

**Statut :** À demander.

### 6. Déploiements et désinstallations exécutés via Tanium

**Compétences :** BC02 C14

**Ce qui doit apparaître :** un **résultat d'exécution** avec le nombre de
machines ciblées, le nombre de succès et d'échecs. Le cas le plus démonstratif
est la **désinstallation d'Internet Explorer sur le parc**, avec son script.

**Anonymisation :** conserver les statistiques, retirer les noms de machines.

**Statut :** À extraire.

### 7. Incident WSUS : GPO et script de désinstallation (rollback)

**Compétences :** BC01 C1 · BC01 C4 · BC02 C14 · BC03 C3

**Ce qui doit apparaître :** l'enchaînement complet de l'incident réel — une
règle d'approbation automatique défaillante sur WSUS a diffusé une mise à jour
provoquant des dysfonctionnements sur des ordinateurs portables ; j'ai
identifié la cause, puis déployé une **GPO** et un **script de
désinstallation** pour retirer la mise à jour et rétablir les postes. Il faut
la capture du paramétrage de la GPO **et** l'extrait du script.

Cette pièce sert quatre compétences : elle prouve la reconfiguration (BC01 C4),
l'action d'exploitation (BC01 C1), la résolution d'un ticket expert
(BC02 C14) et la configuration d'une solution de sécurité classique
(BC03 C3).

**Anonymisation :** retirer le nom du domaine, les unités d'organisation et
les chemins réseau internes.

**Statut :** À extraire.

## Réponse à incident (EDR et SOC)

### 8. Alerte EDR ayant conduit à un correctif

**Compétences :** BC01 C4

**Ce qui doit apparaître :** une alerte réelle, mon intervention comme
**premier répondant**, et le lien entre l'alerte et l'identification d'un poste
à corriger. C'est ce lien qui sert le critère, pas l'alerte elle-même.

**Anonymisation :** flouter l'identité du poste, de l'utilisateur et les
indicateurs techniques (empreintes, adresses, chemins).

**Statut :** À demander (contenu sensible, accord du tuteur requis).

### 9. Analyse post-mortem d'une alerte SOC

**Compétences :** BC01 C1 · BC01 C10 · BC02 C14 · BC03 C8 · BC03 C9

**Ce qui doit apparaître :** le traitement **de l'analyse à la remédiation**,
et ma contribution réelle à la rédaction du post-mortem. Il faut que la
structure du document soit visible : constat, analyse, remédiation appliquée,
enseignements. Pour BC03 C9, c'est la **qualification** de l'alerte qui compte ;
pour BC01 C10, le raisonnement à partir des journaux.

C'est la pièce d'entreprise **la plus rentable du dossier** : elle sert cinq
compétences réparties sur trois blocs.

**Anonymisation :** ne conserver que la trame et le raisonnement. Retirer
l'intégralité des indicateurs de compromission et des identifiants internes.

**Statut :** À demander (accord du tuteur requis).

### 10. Fiche réflexe d'isolement de poste

**Compétences :** BC02 C14 · BC03 C8

**Ce qui doit apparaître :** que **je l'ai rédigée**, et la procédure elle-même
(déclencheurs, étapes d'isolement, qui prévenir, quoi ne pas faire). Elle sert
le critère de BC03 C8 sur le plan d'urgence, et démontre en BC02 C14 une
production experte et non une simple exécution.

**Anonymisation :** retirer les noms d'outils propriétaires internes s'ils sont
identifiants, ainsi que les coordonnées des personnes à contacter.

**Statut :** À extraire.

## Projet de restriction des périphériques externes

Ce projet est le gisement le plus dense du dossier côté entreprise : il alimente
seul six compétences. Les quatre pièces ci-dessous se demandent ensemble.

### 11. Carte Kanban du projet

**Compétences :** BC02 C4 · BC04 C6 · BC04 C8

**Ce qui doit apparaître :** les **colonnes et les jalons**, qui démontrent la
planification et le suivi (BC02 C4), l'usage réel d'un outil collaboratif
(BC04 C6) et la répartition des tâches entre acteurs — utilisateurs, achats,
support, hiérarchie (BC04 C8). Mon rôle de **coordination** doit être lisible
sans être présenté comme une direction de projet.

**Anonymisation :** retirer les noms des personnes assignées, remplacer par
leur fonction.

**Statut :** À extraire.

### 12. Fichier de recensement croisé des besoins

**Compétences :** BC02 C4 · BC03 C5 · BC04 C1

**Ce qui doit apparaître :** la **méthode de croisement** (qui a été
interrogé, quels usages ont été recensés, comment les besoins ont été
consolidés pour la décision). Pour BC03 C5, c'est l'**évaluation des risques
liés aux périphériques** qui est attendue, avec la règle d'attribution des
droits qui en découle. Pour BC04 C1, c'est la démarche de collecte et de
synthèse.

**Anonymisation :** conserver la structure des colonnes et quelques lignes
d'exemple neutralisées ; retirer les noms de services et de personnes.

**Statut :** À extraire.

### 13. Devis des clés USB et courriel de cadrage

**Compétences :** BC02 C4 · BC02 C6

**Ce qui doit apparaître :** l'**arbitrage d'achat** (quantité, coût unitaire,
décision) et la place de la commande dans la chronologie du projet. Pour
BC02 C6, c'est un exemple concret de ressource allouée dans un budget contraint
en entreprise, en complément du budget du homelab.

**Anonymisation :** retirer le fournisseur, les coordonnées commerciales et les
références de commande ; conserver les montants.

**Statut :** À demander (échanges commerciaux, accord à confirmer).

### 14. Scénario de test restreint et groupe pilote

**Compétences :** BC02 C5 · BC03 C5

**Ce qui doit apparaître :** le scénario tel qu'il a été joué — vérifier qu'un
périphérique **autorisé fonctionne** et qu'un périphérique **non autorisé est
bloqué**, sans casser d'usage métier — la composition du groupe pilote, et le
résultat des essais. La logique d'ordre doit être explicite : distribuer et
enregistrer les périphériques autorisés **avant** d'activer le blocage.

**Anonymisation :** conserver le scénario et les résultats, retirer
l'identification du groupe pilote.

**Statut :** À extraire.

## Support et tickets (GLPI)

### 15. Point d'accès unique au support

**Compétences :** BC02 C12

**Ce qui doit apparaître :** le **canal d'entrée unique** des demandes, le
traitement de niveau 1, et la **procédure d'escalade** vers l'équipe sécurité
avec mon rôle réel dans ce flux. Le critère demande qu'un point d'accès unique
soit « à disposition » : c'est l'existence et l'unicité du canal qu'il faut
montrer.

**Anonymisation :** capture du portail avec les intitulés de catégories, sans
aucun contenu de ticket.

**Statut :** À demander. Si aucune capture n'est autorisée, ce volet reste
exploitable **à l'oral**, sans annexe.

### 16. Tableau de bord des tickets et des SLA

**Compétences :** BC02 C13

**Ce qui doit apparaître :** les **volumes par période**, la répartition par
statut et par priorité, les délais de traitement et le **respect des SLA**.
Le critère exige explicitement qu'un tableau de bord permette le suivi du
traitement : c'est la seule pièce qui le démontre.

**Anonymisation :** conserver les graphiques et les compteurs agrégés, retirer
toute ligne nominative.

**Statut :** À demander.

:::note Repli assumé pour BC02 C13
Si l'export GLPI est refusé, le repli est constitué des délais internes connus
chez Concentrix (traitement sous 12 heures, création d'un Outage sous
5 minutes), présentés **à l'oral et de mémoire**, jamais comme une statistique
documentée.
:::

### 17. Ticket de niveau 3 ou 4 clôturé

**Compétences :** BC02 C14

**Ce qui doit apparaître :** un ticket montrant sa **clôture**, correspondant à
l'une des interventions expertes déjà documentées (rollback de la mise à jour,
alerte EDR, désinstallation d'Internet Explorer). Le critère porte sur la
clôture effective des tickets de niveau 3 et 4.

**Anonymisation :** conserver l'objet reformulé, la chronologie et le statut ;
retirer le demandeur et l'identifiant.

**Statut :** À demander.

## Sensibilisation et communication interne

### 18. Courriel type de relance des campagnes

**Compétences :** BC04 C11 · BC04 C13

**Ce qui doit apparaître :** le **message tel qu'il est diffusé** et son
rythme hebdomadaire. Pour BC04 C11, c'est la diffusion des bonnes pratiques
d'usage ; pour BC04 C13, la sensibilisation aux mesures techniques.

**Anonymisation :** retirer l'expéditeur, les destinataires, la signature et
les liens internes.

**Statut :** À extraire.

### 19. Rapport hebdomadaire des indicateurs de campagne

**Compétences :** BC04 C11 · BC04 C13

**Ce qui doit apparaître :** le **taux global**, le taux **par équipe** et le
taux **par ancienneté** — les trois axes calculés par le flux PowerAutomate que
j'ai mis en place. C'est la preuve que la diffusion est mesurée, pas seulement
envoyée.

**Anonymisation :** remplacer les noms d'équipes par des libellés génériques ;
conserver les valeurs.

**Statut :** À extraire.

### 20. Charte informatique, volets usage et sécurité

**Compétences :** BC04 C11 · BC04 C13

**Ce qui doit apparaître :** l'existence des deux volets et leur **mode de
diffusion à l'ensemble du personnel**. Les critères de ces deux compétences
portent nommément sur la charte : « volet d'usage de la charte diffusé » et
« volet sécurité de la charte diffusé à tous ». Sans elle, les deux critères
reposent uniquement sur les campagnes.

**Anonymisation :** sommaire et page de diffusion suffisent ; le corps de la
charte n'est pas nécessaire.

**Statut :** À demander.

### 21. Indicateurs de la campagne de phishing simulé

**Compétences :** BC04 C13

**Ce qui doit apparaître :** les KPI disponibles, notamment le **taux de clic**
et le **taux de signalement**. La campagne est menée au niveau du groupe et non
par moi : ma contribution doit être décrite pour ce qu'elle est, sans
appropriation.

**Anonymisation :** valeurs agrégées uniquement.

**Statut :** À demander. Rien ne sera affirmé au-delà de ce que les collègues
confirment.

## Automatisation

### 22. Flux PowerAutomate de calcul des indicateurs

**Compétences :** BC01 C9 · BC03 C18

**Ce qui doit apparaître :** le **schéma du flux** — dépôt et récupération de
fichiers sur SharePoint, calcul automatique des indicateurs de campagne — et
le fait qu'il **supprime un traitement manuel hebdomadaire**. Le critère de
BC01 C9 exige un accroissement de productivité constaté : c'est cette
suppression qu'il faut rendre visible. Pour BC03 C18, ce flux illustre les
précautions prises sur les données en environnement cloud.

**Anonymisation :** capture du graphe des étapes, noms de dossiers et
connecteurs neutralisés.

**Statut :** À extraire.

### 23. Tâche planifiée et script d'export Active Directory

**Compétences :** BC01 C9 · BC03 C7

**Ce qui doit apparaître :** la vue du planificateur de tâches Windows, un
extrait du script d'export des **utilisateurs actifs**, et surtout la
**précaution assumée** : la récupération finale du fichier reste manuelle pour
éviter toute sortie non maîtrisée de données sensibles. Cette précaution est un
argument de sécurité, pas une limite à cacher. Pour BC03 C7, l'export
hebdomadaire documente le suivi des habilitations.

**Anonymisation :** retirer le domaine, les chemins et les comptes de service ;
aucun extrait de données exportées.

**Statut :** À extraire.

## Gouvernance sécurité (COSECOPS)

### 24. Tableau de bord CVE

**Compétences :** BC02 C1 · BC03 C1 · BC04 C10

**Ce qui doit apparaître :** le tableau tel que **je le prépare** pour
alimenter le comité, et le fait qu'il sert de support à la diffusion des
constats. Mon positionnement doit rester celui d'un **contributeur** : je
dépose et je challenge, je n'anime pas le COSECOPS.

**Anonymisation :** conserver la structure et les compteurs par criticité,
retirer les noms de systèmes affectés.

**Statut :** À extraire.

### 25. Rapport PingCastle et trace du dépôt partagé

**Compétences :** BC01 C10 · BC02 C1 · BC03 C1 · BC04 C6

**Ce qui doit apparaître :** la **page de synthèse** du rapport mensuel (score
et catégories de constats), et séparément la **trace du dépôt** dans l'espace
SharePoint partagé avec le SOC. Cette seconde pièce sert BC04 C6 : elle
démontre un usage réel d'outil collaboratif entre deux équipes.

**Anonymisation :** page de synthèse uniquement, jamais le détail des constats
Active Directory. Retirer le nom du domaine et le score s'il est jugé sensible.

**Statut :** **Obtenue** (`25a`, `25b`, et la trace de transmission au SOC).
Reste l'anonymisation : nom de domaine, et score si jugé sensible.

## Identités et terminaux

### 26. Gestion des accès par groupes Active Directory

**Compétences :** BC03 C7

**Ce qui doit apparaître :** que les droits sont gérés **par groupes et non
individuellement**, ce qui est littéralement le critère de la compétence
(« droits gérés par listes ou groupes »), ainsi que le cycle de vie des comptes
et habilitations.

**Anonymisation :** nomenclature des groupes reformulée, aucun compte nominatif.

**Statut :** À extraire.

### 27. Console MDM, conformité d'un terminal

**Compétences :** BC03 C6 · BC03 C3 · BC03 C15

**Ce qui doit apparaître :** l'écran de conformité d'une tablette et les
**politiques appliquées** : code de verrouillage, chiffrement, effacement à
distance, cloisonnement professionnel. Le critère de BC03 C6 demande qu'une
**gestion unique** des accès soit en place : c'est l'unicité de la console pour
toute la flotte qu'il faut montrer.

**Anonymisation :** flouter l'identifiant du terminal et son porteur.

**Statut :** **Obtenue.** Captures de la console MDM disponibles
(`27a` à `27g`). Reste l'anonymisation : identifiant du terminal et porteur.

## Documentation d'équipe

### 28. Les douze procédures d'exploitation

**Compétences :** BC01 C4 · BC04 C1 · BC04 C3

**Ce qui doit apparaître :** le **sommaire ou la première page** de quelques
procédures, et surtout leur répartition, qui est vérifiable : **5 Tanium,
4 Trend, 2 fichiers personnels, 1 Microsoft**. Les cinq procédures Tanium
servent BC04 C3 (rendre l'équipe support opérationnelle sur l'outil) ;
l'ensemble sert BC04 C1 (base de connaissances disponible) et atteste en
BC01 C4 que j'ai formalisé la prise en main de Tanium.

**Anonymisation :** sommaire et titres suffisent ; une première page
neutralisée par procédure au maximum.

**Statut :** À extraire.

### 29. Base de connaissances d'équipe

**Compétences :** BC04 C1 · BC04 C6

**Ce qui doit apparaître :** son **arborescence** et le fait qu'elle héberge
les douze procédures. Le critère de BC04 C1 est qu'« une base de connaissances
est disponible » : c'est sa disponibilité pour l'équipe qu'il faut établir, pas
son contenu.

**Anonymisation :** capture de l'arborescence uniquement.

**Statut :** À extraire.

## Conformité, anglais et fournisseurs

### 30. Classeur de preuves ISAE 3402

**Compétences :** BC03 C2

**Ce qui doit apparaître :** la **matrice de contrôles** et mon travail réel
d'évaluation de l'applicabilité et de consolidation des preuves. Le critère de
BC03 C2 mentionne ISO 27001 ; ISAE 3402 est un référentiel différent, ce qui
doit être dit clairement plutôt que confondu. La partie ISO 27001 du dossier
repose, elle, sur Concentrix et reste orale.

**Anonymisation :** structure de la matrice uniquement, sans les constats.

**Statut :** À demander (document d'audit, accord requis, obtention
incertaine).

### 31. Courriels professionnels en anglais

**Compétences :** BC04 C2 · BC04 C10

**Ce qui doit apparaître :** des échanges professionnels réels rédigés en
anglais, avec un contenu technique. Ils constituent, avec le niveau C1, le
volet anglais du dossier tant que la traduction du portfolio n'est pas publiée.
Les **deux réunions professionnelles menées en anglais** restent orales.

**Anonymisation :** retirer expéditeurs, destinataires et objets identifiants ;
conserver le corps du message.

**Statut :** À extraire.

### 32. Relances de prestataires sur des engagements

**Compétences :** BC04 C15

**Ce qui doit apparaître :** des relances réelles sur des délais de correction,
des livrables ou des tickets en attente. Si aucune n'est extractible, ce volet
est classé **oral** et la compétence s'appuie sur une projection assumée
concernant les bonnes pratiques contractuelles.

**Anonymisation :** identité du prestataire retirée.

**Statut :** À demander ; repli **oral** assumé.

### 33. Exemple de devis ou d'arbitrage budgétaire

**Compétences :** BC02 C6

**Ce qui doit apparaître :** un arbitrage réel entre options (licences ou
matériel) avec sa justification. Cette pièce est un **complément** : la preuve
centrale de BC02 C6 reste le tableau d'allocation du cluster du homelab.

**Anonymisation :** montants conservés, fournisseur retiré.

**Statut :** À demander ; à défaut, **oral** suffira.

### 34. Texte ou support final de la compétence BC02 C1

**Compétences :** BC02 C1

**Ce qui doit apparaître :** le texte validé de cette compétence, dont
[l'état de la rédaction](/rendu/etat-redaction) indique qu'il est **validé mais
non retrouvé dans les sources**. C'est une pièce à récupérer avant toute
reprise de la rédaction du BC02, puisque la séquence redémarre à C2.

**Statut :** À retrouver (recherche dans les échanges et sauvegardes de
travail).

## Éléments Dupont classés oral, sans annexe

Ces éléments sont réels mais n'ont **aucune trace exploitable**. Ils sont
préparés pour la soutenance et ne seront jamais annoncés comme annexes.

| Élément | Compétences | Précision |
|---|---|---|
| Accompagnement de collègues sur Tanium (démonstrations, binôme) | BC04 C3 | Complète les 5 procédures écrites, qui sont la trace. |
| Allongement de la durée de vie des postes ; visioconférence | BC02 C15 | Réponse à terminer : la réponse P19.c des sources est interrompue en pleine phrase. |
| Préparation de l'arrivée de mon remplaçant | BC04 C4 | Matière concrète pour définir les compétences attendues, à compléter par l'entretien tuteur. |
| Règles cloud connues (MFA, restrictions de partage) | BC03 C18 | En appui de la politique cloud du homelab, qui reste la preuve principale. |

## Questions à poser au tuteur ou aux collègues

Ces demandes conditionnent plusieurs pièces ci-dessus et doivent partir en
premier, car leur délai de réponse ne dépend pas de moi.

1. **Console MDM** : autorisation d'une capture anonymisée montrant la
   conformité d'une tablette (pièce 27, autorisation déjà sollicitée).
2. **Campagne de phishing simulé** : quels KPI sont disponibles, taux de clic
   et de signalement (pièce 21).
3. **Contenu exact des sensibilisations** : quelles mesures techniques sont
   abordées — MFA, wifi, signalement d'un courriel suspect (pièce 21,
   BC04 C13).
4. **PCA et PRA** : où se trouve le document, est-il consultable, et quelle est
   la référence du **test de restauration auquel j'ai assisté** (BC03 C11,
   BC03 C13).
5. **Criticité des applications** : comment elle est définie, et quels RTO et
   RPO existent, même approximatifs (BC03 C11, BC03 C14).
6. **Fiches de poste** : comment elles sont rédigées, quelles compétences sont
   attendues pour un profil junior ou confirmé, exemple consultable
   (BC04 C4).
7. **Présentation des enjeux de sécurité à la direction** : arguments utilisés
   et exemple de support (BC04 C14, route entretien tuteur retenue).
8. **Volet budgétaire** : un exemple anonymisable de devis ou d'arbitrage
   licences ou matériel (pièce 33).

## Compétences dépendant d'une preuve Dupont

Index inverse : pour chaque compétence, les pièces à obtenir. Une compétence
absente de ce tableau ne dépend en rien de l'alternance.

| Compétence | Pièces |
|---|---|
| BC01 C1 | 1, 7, 9 |
| BC01 C3 | 1 |
| BC01 C4 | 2, 3, 7, 8, 28 |
| BC01 C9 | 22, 23 |
| BC01 C10 | 9, 25 |
| BC02 C1 | 24, 25, 34, chronologie du projet périphériques (11) |
| BC02 C4 | 4, 11, 12, 13 |
| BC02 C5 | 4, 5, 14 |
| BC02 C6 | 13, 33 |
| BC02 C9 | 5 |
| BC02 C12 | 15 |
| BC02 C13 | 16 |
| BC02 C14 | 6, 7, 9, 10, 17 |
| BC02 C15 | Oral (durée de vie des postes) |
| BC03 C1 | 24, 25 |
| BC03 C2 | 30 |
| BC03 C3 | 7, 27 |
| BC03 C5 | 12, 14 |
| BC03 C6 | 27 |
| BC03 C7 | 23, 26 |
| BC03 C8 | 9, 10 |
| BC03 C9 | 9 |
| BC03 C10 | 2, 3 |
| BC03 C14 | 1 |
| BC03 C15 | 27 (appui de la projection) |
| BC03 C18 | 22, oral (règles cloud) |
| BC04 C1 | 12, 28, 29 |
| BC04 C3 | 28, oral (accompagnement) |
| BC04 C4 | Oral (remplaçant) + entretien tuteur |
| BC04 C6 | 11, 25, 29 |
| BC04 C8 | 11 |
| BC04 C10 | 24, 31 |
| BC04 C11 | 18, 19, 20 |
| BC04 C13 | 18, 19, 20, 21 |
| BC04 C15 | 32 |

## Ordre de collecte recommandé

L'ordre suit le délai d'obtention, pas l'importance : ce qui dépend d'un tiers
part en premier.

1. **Relancer la demande d'autorisation MDM** (pièce 27) et poser les huit
   questions ci-dessus. Ce sont les seuls éléments dont le délai ne dépend pas
   de moi.
2. **Extraire le post-mortem SOC** (pièce 9), qui sert cinq compétences sur
   trois blocs, et l'**incident WSUS** (pièce 7), qui en sert quatre.
3. **Rassembler le bloc du projet périphériques** (pièces 11 à 14) : quatre
   pièces obtenues ensemble couvrent six compétences.
4. **Extraire les pièces sous mon contrôle direct** : journal d'exploitation,
   politique CVSS, procédures, flux PowerAutomate, export AD, campagnes de
   sensibilisation.
5. **Demander les exports GLPI et Tanium** (pièces 3, 15, 16, 17), en
   préparant dès maintenant le repli oral pour BC02 C13.
6. **Retrouver le texte de BC02 C1** (pièce 34) avant de reprendre la
   rédaction du bloc.

---
title: "Actions à mener"
sidebar_position: 0.5
---

# Actions à mener

**Consolidé au 2 août 2026.** Toutes les actions remontées par les grappes
rédigées (G2, G4, G5, G6, G8, G9), plus celles issues de l'audit initial.

Rendu écrit : **semaine 34, du 17 au 21 août 2026**. Ce qui dépend d'un tiers
est isolé sur la page [Compétences en dépendance](/dependances).

:::danger Les cinq actions qui comptent le plus
Si tu n'en fais que cinq, fais celles-ci. Chacune porte un critère qu'aucune
autre preuve ne couvre.

1. **Demander un créneau au tuteur avant son départ le 7 au soir**, et demander
   le **certificat de travail** aux ressources humaines, seul document
   d'entreprise obligatoire du dossier. Voir la page Compétences en dépendance.
2. **Procès-verbal du test de restauration** du 22 juillet (§2). Une page, sur
   des traces qui existent déjà. Porte B3C13 et renforce B3C17.
3. **Test de bascule HA contrôlé** (§1). Porte B3C16 et B3C17, débloqué depuis
   l'arrivée du quatrième nœud.
4. **Mesure iperf3 du chemin 1 Gb/s, avant le déménagement** (§1). L'état
   initial disparaît avec l'installation actuelle.
5. **Lancer l'anonymisation** (§5). 108 fichiers, aucun traité. Une preuve non
   anonymisée est une compétence non prouvée.
:::

---

## 1. Manipulations techniques

| # | Action | Sert | Effort | Quand |
|---|---|---|---|---|
| T1 | **Trois manipulations OPNsense en une session** : activer `syslog_eve` et déclarer la destination distante vers le SIEM ; supprimer les deux règles DMZ non conformes relevées par l'audit | B3C03, B3C08, B3C09 | ~30 min | Dès que possible |
| T2 | **Rééquilibrer la mémoire entre les nœuds**, prérequis du test de bascule | B3C16 | 1 h | Avant T3 |
| T3 | **Test de bascule HA contrôlé** : arrêter un nœud autre que celui qui porte le stockage, observer la relocalisation, mesurer la durée, conserver les journaux | B3C16, B3C17, B2C09 | 2 h | Après T2 |
| T4 | **Mesure `iperf3` du chemin 1 Gb/s** : date, durée, nombre de flux, sens | B2C02, B2C03 | 1 h | **Avant le 10 août** |
| T5 | Mesure `iperf3` du lien 10 Gb/s et capture Grafana pendant les essais | B2C02 | 1 h | Après le 10 août |
| T6 | **Relevé de consommation électrique** du cluster, puis comparaison après extinction d'une machine non essentielle | B2C15, B2C16 | 2 h | Après le 10 août |
| T7 | Première restauration depuis la clé chiffrée hors ligne, seule branche non testée de la chaîne | B3C13 | 1 h | Souhaitable |
| T8 | Copier les clés de chiffrement locales des machines dans le coffre de mots de passe | B3C12 | 30 min | Souhaitable |

:::caution T4 est daté
L'état initial en 1 Gb/s n'est mesurable que tant que l'installation actuelle
est en place. Après le déménagement, il est perdu et B2C02 retombe sur une
étude sans avant/après.
:::

---

## 2. Documents à produire

### Priorité haute

| # | Document | Sert | Effort |
|---|---|---|---|
| D1 | **Procès-verbal du test de restauration du 22 juillet** : date, périmètre, source, étapes, durée, contrôles, résultat, anomalies | B3C13, B3C17 | 1 h |
| D2 | **Tableau BIA** : service, impact, RTO, RPO, moyen de reprise, dépendances amont | B3C11, B3C14 | 2 h |
| D3 | **Politique de sécurité cloud, une page** : principe, ce qui va au cloud et pourquoi, ce qui n'y va pas, conditions, points de contrôle. Contenu déjà entièrement arbitré dans la page C18 | B3C18 | 1 h |
| D4 | **Note de préconisation d'une page, réellement transmise** : bilan du projet périphériques, options, recommandation, ce qu'elle fait perdre. Conserver le courriel de transmission | B4C14 | 2 h |
| D5 | **Rapport d'audit formel du homelab** : périmètre, méthode, constats classés par risque, recommandations, état de traitement | B3C01, B3C02 | 3 h |

### Priorité moyenne

| # | Document | Sert | Effort |
|---|---|---|---|
| D6 | Tableau des trois indicateurs environnementaux : définition, formule, source, fréquence, valeur, limite | B2C15, B2C16 | 1 h |
| D7 | Tableau d'allocation du cluster : processeurs, mémoire, disque, services par machine | B2C06 | 1 h |
| D8 | Inventaire du matériel : prix payé, prix du neuf, mode d'acquisition, neuf ou occasion | B2C03, B2C16, B4C16 | 1 h |
| D9 | Tableau budgétaire, **montants recoupés avec les factures** | B2C03, B2C06 | 1 h |
| D10 | Liste des achats différés avec leur justification | B2C06, B4C16 | 30 min |
| D11 | Étude d'évolution 1 Gb/s vers 10 Gb/s : état initial, gain attendu, coûts, limites | B2C02, B2C03 | 2 h |
| D12 | Schéma de topologie réseau, chemin de quorum avant et après correction | B2C02 | 1 h |
| D13 | **Procédure de mise à jour d'un service, publiée sur la documentation.** Séquence déjà décrite dans la page C11, reste la mise en forme | B2C11 | 1 h |
| D14 | Liste des constats de sécurité avec remédiation et état d'avancement | B3C02, B3C03 | 1 h |
| D15 | Version expurgée de la cartographie et de l'inventaire des actifs, adresses réduites au segment | B2C08, B3C14 | 1 h |

---

## 3. Captures du homelab

Toutes portent sur de l'existant. À grouper en une ou deux sessions.

| Domaine | À capturer |
|---|---|
| Disponibilité | Tableau Uptime Kuma avec les taux, notification reçue |
| Supervision | Tableau de bord Grafana, journaux centralisés, tableau de conformité des correctifs |
| Haute disponibilité | État du quorum et nombre de voix, service d'arbitrage listant les quatre nœuds, ressources déclarées et chien de garde, relevé de capacité mémoire |
| Réseau | Règles inter-segments représentatives, test d'isolement de la zone démilitarisée, contrôle par port du commutateur |
| Identités | Liste des applications protégées, parcours d'enrôlement imposant le second facteur, descripteurs versionnés |
| Détection | État des agents du SIEM, jeux de règles du moteur réseau |
| Sauvegarde | Exécution du contrôle d'intégrité et sa notification, journal d'une sauvegarde réussie |
| Intégration | Configuration de l'automate de versions et un exemple de demande, exécution réussie de la chaîne de validation, instantané horodaté |
| Documentation | Fiches de service, parcours de démarrage en trois étapes |

---

## 4. Demandes au tuteur et aux collègues

**À envoyer en premier : c'est le seul délai qui ne dépend pas de toi.**

| # | Demande | Sert | Criticité |
|---|---|---|---|
| Q1 | **Périmètre de la charte informatique** : existe-t-il une charte applicable à **tous les collaborateurs**, distincte de celle de la DSI, par exemple annexée au règlement intérieur ou remise à l'embauche ? Par quel canal ? | B4C11, B4C13 | **Haute, deux critères** |
| Q2 | **Comptes rendus du comité de sécurité** : en existe-t-il, rédigés par qui, diffusés comment et sous quel délai ? Exemplaire anonymisé possible ? | B4C10 | Haute |
| Q3 | **KPI de la campagne de hameçonnage simulé** : taux de clic, taux de signalement | B4C13 | Moyenne |
| Q4 | **Contenu exact des sensibilisations** : quelles mesures techniques sont abordées | B4C13 | Moyenne |
| Q5 | **PRA et PCA** : où se trouve le document, consultable ? Référence du test de restauration auquel j'ai assisté | B3C11, B3C13 | Haute |
| Q6 | **Criticité applicative** : comment elle est définie, RTO et RPO existants même approximatifs | B3C11, B3C14 | Haute |
| **Q0** | **Certificat de travail ou attestation d'employeur**, à demander aux **ressources humaines**. Le guide l'impose « a minima » en accompagnement du CV détaillé | Dossier entier | **Obligatoire** |
| Q7 | **Fiches de poste** : comment elles sont rédigées, compétences attendues pour un profil junior ou confirmé, exemple consultable | B4C04 | Haute, grappe G10 |
| Q8 | **Entretien annuel** : déroulement, objectifs fixés, grille anonymisée consultable | B4C05 | Haute, grappe G10 |
| Q9 | **Présentation des enjeux de sécurité à la direction** : arguments utilisés, exemple de support | B4C14 | Moyenne |
| Q10 | **Volet budgétaire** : exemple anonymisable de devis ou d'arbitrage licences ou matériel | B2C06 | Faible, oral suffit |
| Q11 | **Autorisations de capture** : tableau de bord des tickets et SLA, ticket de niveau expert clôturé, console de gestion du parc | B2C13, B2C14 | Haute |

---

## 5. Preuves d'entreprise

### 5.1 Anonymisation, le plus gros poste du dossier

**108 fichiers collectés, aucun anonymisé.** Estimation : 8 à 12 heures, travail
mécanique, à faire par lots quotidiens.

À masquer systématiquement : raison sociale et logo, noms de personnes, adresses
de courriel, noms de serveurs et de sites, adresses internes, identifiants de
tickets, barres de favoris et bandeaux d'application laissant voir le nom de
l'entreprise ou du client.

Ordre de priorité, par rendement décroissant :

| Pièce | Objet | Compétences servies |
|---|---|---|
| 9 | Analyse rétrospective d'une alerte, **collectée** | 5 compétences sur 3 blocs |
| 7 | Incident de mise à jour : GPO et script | 4 compétences |
| 12 | Recensement croisé des besoins | 4 compétences |
| 28 | Les douze procédures d'exploitation | 3 compétences |
| 27 | Console de gestion des terminaux mobiles | 3 compétences |
| 25 | Rapport d'analyse d'annuaire et sa transmission | 4 compétences |
| 24 | Tableau de bord des vulnérabilités | 3 compétences |
| 11, 13, 14 | Kanban, devis, scénario de test | 3 compétences chacune |
| 1 | Journal d'exploitation | 3 compétences |
| 20 | Charte informatique | 2 compétences |

:::caution Deux pièces particulièrement sensibles
Le **recensement croisé** affiche une colonne entière de noms de responsables,
des codes et libellés de sites. Le **rapport d'inventaire des périphériques**
laisse voir la barre de favoris du navigateur avec la raison sociale et le nom
du tenant. Conserver la structure des colonnes, remplacer les noms par les
fonctions, neutraliser quelques lignes d'exemple.
:::

### 5.2 Pièces à extraire, sous ton contrôle direct

| Pièce | Objet | État |
|---|---|---|
| 19 | Rapport hebdomadaire des indicateurs de campagne | **Manquante**, sert B4C11 et B4C13 |
| 23 | Tâche planifiée et script d'export des comptes actifs | **Manquante**, sert B1C09 et B3C07 |
| 34 | Texte final validé de B2C01 | **À retrouver** dans tes échanges |
| 1, 2, 4, 6, 7, 10, 11, 12, 14, 18, 22, 24, 26, 28, 29, 31 | Pièces déjà collectées | À trier et anonymiser |

### 5.3 État réel de la collecte, vérifié fichier par fichier

**26 pièces sur 34 sont collectées.** Le suffixe des fichiers indique ce qui
reste à faire dessus, pas leur absence : « à vérifier » signifie qu'il faut
contrôler que la pièce prouve bien ce qu'on attend d'elle, « à anonymiser »
qu'elle est validée et attend son traitement.

| Pièce | Objet | État |
|---|---|---|
| 1 à 15 | Journal, politique de criticité, console, paliers, transition d'outils, déploiements, incident de mise à jour, alerte, **analyse rétrospective**, fiche réflexe, kanban, recensement, devis, scénario de test, portail de support | **Toutes collectées** |
| 18, 20, 22, 24 à 31 | Relance, charte, flux automatisé, tableau de vulnérabilités, analyse d'annuaire, groupes d'annuaire, console mobile, procédures, base de connaissances, référentiel d'attestation, courriels en anglais | **Toutes collectées** |
| **16** | Tableau de bord des tickets et SLA | Absente, à demander |
| **17** | Ticket de niveau expert clôturé | Absente, à demander |
| **19** | Rapport hebdomadaire des indicateurs de campagne | Absente, **sous ton contrôle** |
| **21** | Indicateurs de la campagne de hameçonnage | Absente, à demander |
| **23** | Tâche planifiée et script d'export des comptes | Absente, **sous ton contrôle** |
| **32** | Relances de prestataires | Absente, **repli oral déjà assumé** |
| **33** | Devis ou arbitrage budgétaire | Absente, **oral suffit** |
| **34** | Texte final validé de B2C01 | Absente, à retrouver |

:::tip Correction du 2 août
Une première version de cette page classait les pièces 3, 5, 8, 9, 13, 15 et 30
comme à demander. **Elles sont en réalité collectées.** La plus importante est
la **pièce 9**, l'analyse rétrospective d'une alerte, qui sert cinq compétences
sur trois blocs : elle est disponible et n'attend que son anonymisation.

Il ne reste donc que **quatre demandes réelles à un tiers** : les pièces 16, 17,
21 et 33, dont deux ont un repli assumé. Deux pièces sont sous ton contrôle
direct, 19 et 23. Une est à retrouver, 34.
:::

---

## 6. Actions en entreprise

| # | Action | Sert |
|---|---|---|
| E1 | **Rédiger et transmettre réellement** une note de préconisation d'une page. Conserver le courriel de transmission, qui est la preuve | B4C14 |
| E2 | Conduire l'entretien tuteur sur les fiches de poste et l'entretien annuel, et le restituer | B4C04, B4C05 |

---

## 7. Rédaction

| # | Chantier | Volume | État |
|---|---|---|---|
| R1 | **Partie 1, écrit narratif** | 10 à 15 pages | **Premier jet rédigé le 4 août.** À relire, plus trois points à trancher |
| R2 | ~~Grappe G1, correctifs et parc~~ | 4 compétences | **Rédigée** |
| R3 | ~~Grappe G3, support et tickets~~ | 3 compétences | **Rédigée** |
| R4 | ~~Grappe G7, IaC et intégration continue~~ | 3 compétences | **Rédigée** |
| R5 | Grappe G10, encadrement | 3 compétences | À rédiger, dépend de Q7 et Q8 |
| R6 | ~~Grappe G12, gouvernance et audit~~ | 3 compétences | **Rédigée**. D5 reste à produire |
| R7 | ~~Rafraîchissement factuel de BC01~~ | 11 compétences | **Fait le 2 août.** Un point à confirmer : restauration depuis la clé hors ligne |
| R8 | Assemblage Word : page de garde du certificateur, partie 1, quatre blocs, annexes, sommaire, pagination | — | À faire en dernier |

---

## 8. Points de vigilance permanents

- **Aucun chiffre sans source vérifiable.** Les montants du homelab sont des
  ordres de grandeur non recoupés tant que D9 n'est pas fait.
- **Une étude reste une étude.** Le passage au 10 Gb/s, tant que T5 n'est pas
  fait.
- **Sans trace exploitable, c'est oral**, jamais annoncé comme annexe.
- **Aucune certification réseau n'est présentée comme acquise.**
- **Le cours ITIL est une formation**, pas une certification.
- **Le portfolio n'est pas bilingue** tant qu'aucune page n'est traduite.
- **CV-as-Code** ne se décrit au présent qu'une fois en production.
- **Positionnement** : contributeur au comité de sécurité, alternant, jamais
  animateur ni chef de projet.

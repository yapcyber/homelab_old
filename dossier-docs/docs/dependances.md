---
title: "Compétences en dépendance"
sidebar_position: 0.6
---

# Compétences en dépendance

**Consolidé au 2 août 2026.** Les compétences dont la validation dépend d'une
preuve qui n'est **pas encore demandée**, ou pas encore obtenue.

C'est la seule catégorie d'actions dont le délai ne t'appartient pas. Tout le
reste peut être rattrapé en travaillant plus ; ceci ne peut pas.

:::danger Un seul message suffit
Les onze demandes tiennent dans **un courriel au tuteur**. Envoyé aujourd'hui,
il débloque huit compétences. Envoyé la semaine du 11 août, il arrive trop tard
pour laisser le temps d'une relance.
:::

---

## 1. Les trois niveaux de dépendance

Je distingue trois situations, parce qu'elles n'appellent pas la même urgence.

| Niveau | Signification |
|---|---|
| **Bloquante** | Sans la preuve, le critère n'est satisfait par rien d'autre. La compétence tombe. |
| **Fragilisée** | Le critère tient sans, mais sur une base plus mince. La preuve le consoliderait. |
| **Couverte** | Un repli est déjà écrit et assumé dans le texte. La demande est un bonus. |

---

## 2. La seule compétence réellement bloquante

### B4C13 — Sensibiliser aux mesures techniques

> **Critère.** Le volet sécurité de la charte informatique de l'entreprise est diffusée à l'ensemble du personnel.

**Dépend de la question Q1**, le périmètre réel de la charte.

**Pourquoi c'est bloquant.** La charte collectée est celle de la direction des
systèmes d'information : sa rubrique destinataires vise les collaborateurs de
cette direction, alors que sa rubrique diffusion autorise une diffusion à
l'ensemble des collaborateurs. Le critère, lui, parle explicitement de
**l'ensemble du personnel**. Tant que l'ambiguïté n'est pas levée, on ne sait
pas si le critère est satisfait ou non.

Deux issues, et les deux sont acceptables : soit une charte applicable à tous
existe et il faut la produire, soit elle n'existe pas et le texte doit alors
s'appuyer explicitement sur la diffusion **autorisée** à tous plutôt que sur une
diffusion effective. Ce qui n'est pas acceptable, c'est de laisser le doute.

C'est une question, pas une pièce à produire : elle se règle en une réponse.

:::tip B2C13 n'est plus bloquante, vérification du 2 août
Cette page annonçait initialement B2C13, le tableau de bord des tickets, comme
la compétence la plus exposée du dossier, faute de pièce 16.

**C'est faux.** La capture classée sous la pièce 15, sous le nom du portail de
l'outil de gestion des demandes, **est** un tableau de bord de tickets. Elle
présente les compteurs par statut, entrants, en attente, assignés, en retard,
non résolus, fermés et total, ainsi que les colonnes de suivi des engagements de
service, dépassement du temps de résolution et progression, la priorité et
l'attribution par groupe de techniciens.

Le contenu attendu de la pièce 16 est donc **déjà collecté**, simplement rangé
sous un autre numéro. B2C13 passe de bloquante à couverte. Reste à vérifier la
capture et à l'anonymiser, l'accès administrateur permettant au besoin de
produire un export plus lisible.
:::

## 3. Les compétences fragilisées

| Compétence | Critère visé | Dépend de | Ce qui tient déjà sans |
|---|---|---|---|
| **B4C10** Information de réunion | Les comptes rendus de réunions sont diffusés rapidement | **Q2** : des comptes rendus du comité existent-ils, rédigés par qui, diffusés sous quel délai ? | La diffusion de l'information **préparatoire**, qui est la contribution réelle et traçable. Le critère porte cependant sur l'aval |
| **B4C04** Fiche de poste | Le choix des collaborateurs est justifié | **Q7** : comment les fiches de poste sont rédigées, compétences attendues, exemple | Le vécu réel : préparation de l'arrivée du remplaçant, formation des successeurs. Plus une fiche de poste type à faire relire |
| **B4C05** Entretien annuel | L'intégration des nouveaux collaborateurs est positive | **Q8** : déroulement, objectifs, grille anonymisée | Le suivi d'alternance vécu côté évalué, puis projection assumée |
| **B2C14** Tickets de niveau 3 et 4 | Les tickets de niveau 3 & 4 sont clôturés | **Pièce 17** : un ticket classé en niveau expert | **Solide sans** : l'alerte qualifiée et clôturée, le déploiement à 100 %, le rétablissement après mise à jour défaillante. Les consoles portent auteur, horodatage et résultat |
| **B3C11** Criticité de l'interruption | Le plan de reprise est priorisé, les délais validés | **Q5 et Q6** : localisation du plan de reprise, méthode de criticité, RTO et RPO | Le tableau BIA du homelab, à produire, porte le critère à lui seul |
| **B3C14** Éléments critiques | Les rôles critiques et ressources indispensables sont identifiés | **Q6** | Le journal d'exploitation, collecté, et l'inventaire des actifs |
| **B4C11** Diffuser les bonnes pratiques | Le volet d'usage quotidien de la charte est diffusé | **Q1** et **pièce 19** | La charte est collectée et son cadre de diffusion est écrit dans le document |
| **B4C14** Adhésion des décideurs | Un rapport de préconisation est transmis à la direction | **Q9** : arguments et exemple de support | **La note que tu produis et transmets porte le critère.** Q9 n'est qu'un renfort |

---

## 4. Les compétences couvertes par un repli assumé

Ces demandes restent utiles, mais leur refus ne met rien en péril : le repli est
déjà écrit dans le texte de la compétence.

| Compétence | Dépend de | Repli déjà écrit |
|---|---|---|
| **B4C15** Niveaux de service | Pièce 32, relances de prestataires | Le suivi des cycles de support des éditeurs, tracé et daté sur le homelab, plus les engagements internes chez Concentrix à l'oral |
| **B2C06** Attribuer les ressources | Pièce 33, devis ou arbitrage | L'allocation de capacité sous contrainte physique et les achats différés documentés |
| **B4C13** volet indicateurs | Pièce 21, KPI de hameçonnage | Les taux de complétion mesurés par le flux automatisé |
| **B3C02** ISO 27001 | Pièce 30, classeur d'attestation | Les failles identifiées par l'audit de gouvernance, qui franchissent la première porte du critère |
| **B2C01** Gérer les évolutions | Pièce 34, texte validé à retrouver | Le tableau de bord des vulnérabilités **satisfait déjà le critère**. Retrouver le texte évite de le réécrire, rien de plus |

---

## 5. Ce qui ne dépend que de toi

À ne pas confondre avec ce qui précède : ces pièces sont sous ton contrôle
direct, aucun tiers n'est en cause. Elles ne sont simplement pas encore
extraites.

| Pièce | Objet | Compétences |
|---|---|---|
| **19** | Rapport hebdomadaire des indicateurs de campagne | B4C11, B4C13 |
| **23** | Tâche planifiée et script d'export des comptes actifs | B1C09, B3C07 |
| **34** | Texte final validé de B2C01 | B2C01, confort |

---

## 6. Le message à envoyer

Un seul courriel, onze points. Regroupés par nature pour qu'il soit lisible.

**Autorisations de capture, anonymisées**

1. Confirmer l'autorisation d'usage de la capture du tableau de bord de l'outil
   de gestion des demandes, déjà collectée. Un export propre serait un plus,
   il n'est pas indispensable. *(sert B2C13)*
2. Un ticket classé en niveau expert, montrant sa clôture. *(pièce 17)*
3. La console de gestion du parc, état de conformité des correctifs.
   *(pièce 3, déjà collectée, confirmer l'autorisation d'usage)*

**Questions de périmètre**

4. Existe-t-il une charte informatique applicable à **tous les collaborateurs**,
   distincte de celle de la direction des systèmes d'information, par exemple
   annexée au règlement intérieur ou remise à l'embauche ? Par quel canal
   est-elle remise ? *(débloque B4C13)*
5. Le comité de sécurité opérationnelle produit-il un compte rendu ou un relevé
   de décisions ? Rédigé par qui, diffusé comment, sous quel délai ?
   *(débloque B4C10)*

**Continuité**

6. Où se trouve le plan de reprise ou de continuité, et est-il consultable ?
   Quelle est la référence du test de restauration auquel j'ai assisté ?
7. Comment la criticité des applications est-elle définie ? Des objectifs de
   reprise et de perte de données admissible existent-ils, même approximatifs ?

**Ressources humaines**

8. Comment les fiches de poste sont-elles rédigées ? Quelles compétences pour un
   profil junior ou confirmé ? Un exemple est-il consultable ?
9. Comment se déroule un entretien annuel ? Quels objectifs y sont fixés ? Une
   grille anonymisée est-elle consultable ?

**Compléments**

10. Comment les enjeux de sécurité sont-ils présentés à la direction ? Quels
    arguments emportent la décision, et sur quel support ?
11. Un exemple anonymisable de devis ou d'arbitrage sur des licences ou du
    matériel.

**Auprès des collègues**, séparément : les indicateurs de la campagne de
hameçonnage simulé, taux de clic et taux de signalement, et le contenu exact des
mesures techniques abordées dans la sensibilisation.

---

## 7. Ce qu'il faut retenir

Sur 61 compétences, **une seule est réellement bloquée** par une information non
demandée, sept sont fragilisées, cinq ont un repli déjà écrit. Le reste ne
dépend que de toi.

Le dossier n'est donc pas à la merci du tuteur. La seule question dont la
réponse change une validation est **Q1, le périmètre de la charte**. Si une
seule ligne de cette page mérite une relance, c'est celle-là.

Deux enseignements de méthode, valables pour la suite. D'abord, **vérifier une
pièce avant de la déclarer manquante** : le contenu de la pièce 16 était
collecté depuis le début, rangé sous un autre numéro, et cette erreur de
classement m'a fait annoncer une compétence bloquée qui ne l'était pas. Ensuite,
une capture peut prouver davantage que ce pour quoi elle a été prise : la même
image sert ici le point d'accès unique et le tableau de bord de suivi.

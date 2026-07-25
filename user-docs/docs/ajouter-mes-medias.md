---
title: Ajouter mes médias
sidebar_position: 20
---

# Ajouter mes propres médias

Tu peux **ajouter** tes films, séries, musique, livres, etc. via **Nextcloud**.
Ils apparaîtront ensuite dans Jellyfin, Navidrome, RomM… pour tout le monde.

:::info Règles du partage
- **Ajout uniquement** : tu peux déposer, mais **pas modifier ni supprimer** (y compris les tiens). Pour retirer un média, demande à l'administrateur.
- **Un scan antivirus** passe sur chaque dépôt.
:::

## Comment déposer

1. Ouvre **Nextcloud** → dossier partagé **« Médiathèque »**.
2. Entre dans le sous-dossier du **bon type** (films, séries, anime, cartoons, music, livres, livres-audio, comics, manga, roms).
3. Dépose ton fichier (ou ton dossier, pour une série ou un album).

Un tri automatique passe **toutes les ~15 minutes** : si le nom respecte la
convention, le média rejoint la bibliothèque ; sinon il part en **quarantaine**
(rien n'est perdu) et l'admin est prévenu.

## ⚠️ Le nommage — la seule chose qui compte

Le tri **ne devine rien** : il faut nommer correctement, sinon → quarantaine.

| Type | Convention | Exemple |
|---|---|---|
| **films** | `Titre (Année).ext` | `Inception (2010).mkv` |
| **anime / cartoons** | `Titre (Année).ext` | `Akira (1988).mkv` |
| **series** | dossier `Titre (Année)/` → `Titre - SxxExx.ext` | `Dossier: Dark (2017)/` puis `Dark - S01E01.mkv` |
| **music** | dossier `Artiste/Album/` → pistes taguées | `Daft Punk/Discovery/01 - One More Time.flac` |
| **livres** | `Titre - Auteur.ext` (epub/pdf/mobi) | `1984 - George Orwell.epub` |
| **livres-audio** | dossier `Titre - Auteur/` (mp3/m4b) | `Le Hobbit - Tolkien/` |
| **comics / manga** | `Série - TXX.ext` (cbz/cbr/pdf) | `Berserk - T01.cbz` |
| **roms** | `Jeu (Région).ext` | `Chrono Trigger (USA).sfc` |

**Astuces**
- Extensions vidéo acceptées : `mkv, mp4, avi, m4v, mov`.
- Extensions audio : `flac, mp3, m4a, m4b, ogg`.
- Une **série** ou un **album** = un **dossier** (pas des fichiers en vrac).
- Pas d'accents bizarres, pas de `[tags]` entre crochets (ça casse la reconnaissance).

## Et si mon média part en quarantaine ?

Ce n'est pas grave : rien n'est supprimé. Renomme-le correctement et re-dépose-le,
ou demande un coup de main à l'administrateur.

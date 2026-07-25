---
sidebar_position: 1
slug: /
title: Bienvenue sur YapServer
---

# Bienvenue sur YapServer 👋

Les services de la maison — films, séries, musique, photos, fichiers… — sont
accessibles depuis ton téléphone, ta tablette ou ton ordinateur. Suis ce
**parcours en 3 étapes** pour tout mettre en route (ça ne prend que quelques minutes).

:::info Tout passe par le VPN
Pour la sécurité, les services ne sont accessibles **que via le VPN** (WireGuard).
C'est la première étape, et l'installation ne se fait **qu'une seule fois**.
:::

## Étape 1 — Installer le VPN (WireGuard)

1. Installe l'application **WireGuard** (App Store, Google Play, ou sur ordinateur).
2. Ouvre-la → bouton **＋** → **Scanner depuis un QR code**.
3. Scanne le **QR code que Yanis t'a envoyé** — il est **personnel**, ne le partage pas.
4. Active le tunnel : l'interrupteur passe au **vert**. ✅

👉 Détails et dépannage : **[Se connecter au VPN](./acces/wireguard.md)**.

:::tip À retenir
Ensuite, il suffira d'**activer WireGuard** avant d'ouvrir un service. Quand tu as
fini, tu peux le désactiver.
:::

## Étape 2 — Ton compte unique

Un **seul compte** (connexion Authentik) ouvre la plupart des services.

1. Le VPN activé, va sur **[auth.yapserver.fr](https://auth.yapserver.fr)**.
2. À la première connexion, configure la **double authentification** : une appli
   comme *Aegis* ou *Google Authenticator* affiche un code à 6 chiffres à saisir.
3. C'est fait — ce compte te connectera automatiquement aux services (tu n'auras
   pas à retaper ton mot de passe partout).

👉 Détails : **[Compte & connexion unique](./acces/compte-authentik.md)**.

## Étape 3 — Les services

Le plus simple : le **portail [home.yapserver.fr](https://home.yapserver.fr)**, qui
rassemble toutes les icônes. Sinon, voici les principaux :

| Service | Adresse | Pour quoi faire | Guide |
|---|---|---|---|
| 🎬 **Jellyfin** | jellyfin.yapserver.fr | Films, séries, dessins animés | [fiche](./medias/jellyfin.md) |
| ☁️ **Nextcloud** | cloud.yapserver.fr | Fichiers, agenda, ajouter des médias | [fiche](./cloud/nextcloud.md) |
| 🎵 **Navidrome** | music.yapserver.fr | Musique en streaming | [fiche](./medias/navidrome.md) |
| 📷 **Immich** | photos.yapserver.fr | Photos, sauvegarde automatique | [fiche](./cloud/immich.md) |
| 📚 **Kavita** | kavita.yapserver.fr | BD, mangas, livres | [fiche](./medias/kavita.md) |
| 🎧 **AudioBookShelf** | audiobooks.yapserver.fr | Livres audio & podcasts | [fiche](./medias/audiobookshelf.md) |
| 🔑 **Vaultwarden** | vault.yapserver.fr | Mots de passe | [fiche](./cloud/vaultwarden.md) |

💡 Tu peux aussi **ajouter tes propres médias** : voir **[Ajouter mes médias](./ajouter-mes-medias.md)**.

## Un souci ?

1. Vérifie d'abord que **WireGuard est bien activé** (c'est 9 fois sur 10 la cause).
2. Sinon, consulte le **[guide de dépannage](./depannage.md)** ou demande à Yanis.

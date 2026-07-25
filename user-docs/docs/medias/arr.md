---
title: Radarr, Sonarr & co
---

# Les gestionnaires *Arr

## À quoi ça sert

Ces outils **automatisent** la recherche, le téléchargement et le **rangement**
des médias, pour qu'ils apparaissent proprement dans Jellyfin :

| Outil | Adresse | Rôle |
|---|---|---|
| **Radarr** | radarr.yapserver.fr | Films |
| **Sonarr** | sonarr.yapserver.fr | Séries |
| **Lidarr** | lidarr.yapserver.fr | Musique |
| **Prowlarr** | prowlarr.yapserver.fr | Gère les sources pour les 3 autres |

## Comment ça marche

1. Tu (ou [Jellyseerr](./jellyseerr.md)) demandes un film / une série.
2. L'outil cherche, lance le téléchargement via [qBittorrent](./qbittorrent.md),
   puis **renomme et range** le fichier au bon endroit.
3. Il apparaît automatiquement dans **[Jellyfin](./jellyfin.md)**.

## Bon à savoir

- Outils de **gestion** : au quotidien tu n'as pas à y toucher — pour demander un
  contenu, utilise **Jellyseerr**.
- Si un média n'arrive pas, c'est souvent ici qu'on regarde (côté administration).

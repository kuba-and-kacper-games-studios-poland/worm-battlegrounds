---
title: "New map pictures for Desert, Echo Caverns and Rolling Plains"
date: 2026-11-25
status: open
kind: changed
pages: ["Lobby", "Desert", "Echo Caverns", "Rolling Plains"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - art/map_cards/README.md
  - art/map_cards/make_cards.py
---

**What changed.** The three maps in rotation have new pictures on the lobby's public cards and on the custom lobby's
and the setup's map tiles, shot in a real match with each map's new parallax backdrop and lighting, so the cards, the
tiles and the new loading screen match. Echo Caverns' card showed its old cave; it now shows the snowy summit with its
caves and the snowy range behind. Desert: sand peaks with cacti under the mesas. Rolling Plains: the picnic table, the
pine and the rock arch with the sea islands behind. The cut (slanted, rounded) is the old pictures' own.

**Where.** MatchBoard's `MAPS` → `Thumbnail` / `TileThumbnail`: Desert 81138287783963 / 113826869502887, Echo Caverns
128031100933800 / 93769256053322, Rolling Plains 92320287823767 / 80399475408535 (decals and titles in
`art/map_cards/README.md`, all approved by moderation).

**How to check.** Studio play test, 25 Nov: the three public cards loaded the new pictures (`IsLoaded`), Rolling Plains'
and Echo Caverns' shown on the board. The map tiles weren't opened. The place isn't saved.

**For the wiki.** Lobby: the cards' pictures. Each map page: its infobox picture can be the new card. Supersedes the
pictures of `2026-11-14-map-pictures-four-maps` (Rolling Plains, Echo Caverns) and `2026-11-15-lobby-picture-fixes`
(Desert, the three tiles), and closes the "need new ones" note in `2026-11-25-three-map-rotation`.

---
title: "Lobby cards are minimal: a big map picture fading right, no player count or timer"
date: 2026-11-15
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
---

**What changed.** The owner: "the cards in active lobbies for deathmatch etc. should be more minimalistic, hide how
many players are playing, and make the image much much bigger maybe in the background fading out to the right, but
keep it readable". Each ACTIVE LOBBIES card (`PREFAB | Row`) now shows the map's picture over about 72 % of the card
(`S_MapIcon`, cropped, rounded, a `UIGradient` fading it out from 40 % to the right edge), the mode big and the map's
name under it over the picture, and Join. The player count (`S_Players`, "3/6 players") and the timer are gone. A map
with no lobby picture yet (Desert, Fluffy Fallout) shows a plain card instead of the design's placeholder. The
waiting room left the MatchBoard gui for its own `MatchWaiting` gui on the match server (see the global matches entry).

**Where.** The MatchBoard gui's `PREFAB | Row`; Board's `_refresh` sets `S_Mode`, `S_Map` and `S_MapIcon.Image` (the
map row's `Thumbnail`, or `""`).

**How to check.** In the lobby, the four cards show the mode and map over a big picture fading before Join, with no
count or timer.

**For the wiki.** Lobby: the cards' look (mode, map, picture, Join only). Desert and Fluffy Fallout get pictures once
their thumbnails are uploaded.

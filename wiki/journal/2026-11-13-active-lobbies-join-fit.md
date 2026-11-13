---
title: "Active lobbies: buttons read Join, map pictures fit"
date: 2026-11-13
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** The lobby cards' button reads "Join" (was "Join teams"); a party member still sees "Host picks". The map picture (`S_MapIcon`) is `ScaleType = Fit`, so it's never stretched.

**Where.** `Board.lua` (the join text); the MatchBoard gui's `S_MapIcon`. The gui needs exporting again in Studio.

**How to check.** The cards read JOIN, and the map pictures keep their shape.

**For the wiki.** Lobby: the card's button text and screenshot.

**From.** The testers: "change texts on active lobbies buttons from JOIN TEAMS to just JOIN", "images for map are stretched".

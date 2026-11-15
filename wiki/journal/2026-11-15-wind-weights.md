---
title: "Wind is weighted: ±10 about 1% of rolls"
date: 2026-11-15
status: open
kind: changed
pages: ["Wind"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
---

**What changed.** The wind used to be any whole number from −10 to 10 at even odds. Now its strength is picked by
Match's `WIND_WEIGHTS` = { 16, 16, 15, 13, 11, 9, 7, 5.5, 4, 2.5, 1 } (strength 0 to 10, out of 100), its side at even
odds: 0 is 16%, ±1 16%, … ±9 2.5%, ±10 1% (0.5% each way). It still changes once a round.

**Where.** `Turns._getRandomWind`. The bot gym's training sim (`Bots/Scripts/Server/Sim.lua`) still rolls even odds.

**For the wiki.** Wind: how often strong wind comes.

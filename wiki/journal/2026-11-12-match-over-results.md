---
title: "The results are the studio's MatchOver design"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The end of a match shows the studio's `MatchOver` design (ported 1:1): MATCH OVER, "You placed
2nd!" with the place in its colour, a card per player (place, avatar, name with badges, @username, coins; gold,
silver and bronze for the first three), what the player earned (coins, XP, level up) and their match stats, then
REMATCH ("Rematch  1/2  |  0:15") and BACK TO LOBBY. Four cards fit across; more share the width.

**Where.** The Results gui; MatchHud's `Results.lua`; `RESULTS_FIT_PLACINGS` (4) in MatchHud's Settings.

**How to check.** Finish a Studio match with bots.

**For the wiki.** Match screen (results): the new look and texts. Unsure: not seen in this playtest, and more than
four players' cards weren't checked.

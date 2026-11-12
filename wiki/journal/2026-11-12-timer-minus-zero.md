---
title: "Timers no longer show -0 as they run out"
date: 2026-11-12
status: open
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Panels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
---

**What changed.** The timer at the top of the match screen showed "-0" in the last moment of a turn or the drop.
Every countdown now stops at 0: the drop timer, the turn timer over the snail, the results' countdown and the lobby
board's.

**Where.** Each rounds `math.ceil(math.max(left, 0))` instead of `math.max(math.ceil(left), 0)`, which gives Lua's
−0 for a left time between −1 and 0.

**How to check.** Watch a turn's timer run out: it ends on 0. Checked in a Studio match: no label showed "-0" over
40 s of turns ending.

**For the wiki.** Nothing to change; a History line on Match screen if it lists fixes.

---
title: "The knocked-out snail's ghost always shows"
date: 2026-11-13
status: open
kind: fixed
pages: ["Snails", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Ghost.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Flight.lua
---

**What changed.** The ghost's glow is drawn over everything (`DepthMode` AlwaysOnTop), so a snail knocked out in the sea or behind ground still shows its ghost. The ghost waits for the snail's skin to stream in, and a knocked-out snail's thrown flight stops drawing, so it doesn't pull the ghost away.

**Where.** Snails' client `Ghost` (`_watchSnail`) and `Flight._step` (skips `Alive == false`).

**How to check.** Knock a snail into the sea: its ghost floats up glowing above the water.

**For the wiki.** Snails: knockouts and the ghost.

**From.** The testers: "ghost missing when you die".

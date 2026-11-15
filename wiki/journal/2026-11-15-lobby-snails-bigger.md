---
title: "Lobby: the snails on the stage are 50% larger"
date: 2026-11-15
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** The owner: "make the snails 50% larger in lobby". The party's snails on the lobby stage (the
player's on the front pod, members' on the others) are built 1.5 times their match size: Lobby's `STAGE_SNAIL_SCALE`
(1.5) times the skin's own scale (0.45, so 0.675). Scaling about the snail's pivot would sink it into its pod, so
each is lifted by what grew under the pivot and its feet stay on the platform. Matches, the Style screen and crate
previews keep their sizes.

**Where.** `Module._dress` (scales and works out the lift, `snailLifts`) and `Module._refreshSnails` (places the snail
on its marker plus the lift) in `Lobby/Scripts/Client/Stage.lua`; `STAGE_SNAIL_SCALE` in `Lobby/Settings.lua`.

**How to check.** In the lobby the snail stands bigger on the front pod, its feet on the platform. Tested in Studio:
scale 0.675, the box 1.5 times bigger, its bottom at 1.24 studs as before (the platform's top is 1.20), no errors.

**For the wiki.** Lobby: the stage's snails are shown larger than in a match.

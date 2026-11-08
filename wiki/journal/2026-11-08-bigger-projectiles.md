---
title: "Flying projectiles drawn twice as big"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** Every projectile in flight is drawn twice its old size (its model, or the plain ball when it has
none), so shots read from the match camera. Only the look changed: hits, blasts and paths are the same size as
before. A placed Dynamite keeps its own size, and so do weapons held in hand.

**Where.** Combat's `PROJECTILE_DRAW_SCALE` (2): `Flight._addShot` scales each flying model, `Shots._onShot` each
client placeholder. The hit size is still `PROJECTILE_SIZE` (1).

**How to check.** In a match a Bazooka rocket and a Grenade fly visibly bigger than the held weapon.

**For the wiki.** Arsenal: nothing to change in the numbers.

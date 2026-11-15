---
title: "A shot that falls into the open sea is gone at once (was: sank for up to 4 s)"
date: 2026-11-15
status: open
kind: changed
pages: ["Weapons", "Arena", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** The owner: "make the turn end when the projectiles hit the outer water that instakills you, right
now it takes too long for the projectile to fall". A shot that reaches the open sea (the water or lava that knocks a
snail out: Arena's `GetHazard`, the sea at the map's floor under a surface 16 studs across or more) is now gone as it
splashes in, with no blast, and the turn moves on after the usual 3 s hold (Match's `HIT_HOLD`). Before, it sank through
the sea like a pond, slowed (`SINK_*`), until it burst on the seabed, its fuse ran out, or `SINK_SECONDS` (4 real
seconds) passed. Only slow shots were caught at the surface, by chance (the 1-stud `SEA_SLACK` band). Ponds, puddles
and small flooded holes are unchanged: shots still fly on through them, slowed.

**Where.** `Projectiles.IsGone` in Combat (now: flown past `MAX_PROJECTILE_TIME`, `I.Arena.GetHazard(position) ~= nil`,
or sunk `SINK_SECONDS` in other liquid); the bots' `Predict._fly` ends a predicted shot the same way. `IsLost`
(crawling spider bombs, thrown snails) is unchanged.

**How to check.** Measured in Studio on Volcano Isle: a shot falling at 150 studs/s into the lava sea is gone at the
surface after 0.40 s (before: 1.87 s, 25 studs down).

**For the wiki.** Weapons / Arena: shots that land in the open sea are lost at once, no blast; ponds only slow them.
Bots: they no longer count on a shot bursting on the seabed.

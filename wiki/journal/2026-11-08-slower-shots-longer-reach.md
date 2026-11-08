---
title: "Shots fly 20% slower; full power reaches about 56% further"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Helpers/Ballistics.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/
---

**What changed.** Every flying shot moves in slow motion, at 80% of its old speed along the same arc (the same
gravity and paths, only played slower), so players can follow it with their eyes. Fuses stay in real seconds (the Grenade still goes
off 3 s after it's thrown). Full power reaches further: each arc weapon's top launch speed went up 25%, which is about
56% more distance on flat ground:

| Weapon | MaxSpeed before | After |
| --- | --- | --- |
| Bazooka | 120 | 150 |
| Grenade, Cluster bomb, Homing missile | 90 | 112 |
| Spartan spear | 110 | 138 |
| Spider bomb | 80 | 100 |
| Variety grenade | 85 | 106 |

The Spider bomb's throw (real Roblox physics) is slowed the same way.

**Where.** `PROJECTILE_TIME_SCALE = 0.8` in Combat's `Settings.lua`: `Ballistics` moves a shot by
`PROJECTILE_STEP * PROJECTILE_TIME_SCALE` of its own time per real step. `Projectiles.Spawn` scales an unanchored
shot's launch speed and holds up part of its weight with a `VectorForce` (`mass * g * (1 - scale²)`).
`MAX_PROJECTILE_TIME` 12 → 20. `MaxSpeed` in each weapon row.

**How to check.** `PROJECTILE_TIME_SCALE` is 0.8 and the `MaxSpeed` values are above; in a match a shot takes 1.25 times
as long as its path at real speed would.

**For the wiki.** Arsenal: the max speeds, a History line. Match modules: shots are simulated in slow motion
(`PROJECTILE_TIME_SCALE`).

**From.** The tester's notes ("projectiles move 40% slower", "max power should reach further") and the owner ("a
little slower, so they feel more arcade like"). It was 0.6 (40% slower) first; the owner found that too floaty and
asked for only 20% slower with the gravity and paths kept.

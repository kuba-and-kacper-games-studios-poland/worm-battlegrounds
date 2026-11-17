---
title: "Variety grenade: its minis dig on as small variety grenades, not worms"
date: 2026-11-17
status: open
kind: changed
pages: ["Variety grenade"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Snail.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
---

**What changed.** The owner: "on Variety grenade - instead of worms do smaller variety grenades (should dig like
worms, just replace the model)". Where each of the four minis bursts, what digs on is now drawn as that mini variety
grenade (the grenade's own model at the bomblets' `Mini` size, the same size the minis fly at) instead of the worm
model. It digs exactly as the worms did: one of the four downward directions at random, `SNAIL_SPEED` 6 studs/s for
up to `SNAIL_LIFETIME` 6 s, eating a 2-stud tunnel every `SNAIL_BITE` 0.3 s, biting snails for 5 (6 bites at most),
drowning in water or lava, squeaking and crunching (`Variety_Squeak`, `Variety_Dig`), with the variety trail, and it
points along its tunnel swaying as the worm did. Supersedes the look in 2026-11-16-variety-worms (its digging still
holds).

**Where.** Combat's `Snail.Run`: when the row's `Bomblets.Hatch` is on, the part is named after the bomb
(`VarietyGrenade`) with `Digger` true and `DrawScale` = `PROJECTILE_DRAW_SCALE` × `Mini` (2 × 0.5 = 1); the client's
`Flight` draws a `Digger` like the worm (head first, `WORM_SWAY`). A row's `Snails` without `Hatch` still dig as worms.

**How to check.** Throw a variety grenade: four minis fly out, and where each lands a small variety grenade bores
through the ground. Checked in Studio (2026-11-17): a `Digger` part named `VarietyGrenade` drew the variety model at
1.8 studs with its trail, its placeholder ball hidden.

**For the wiki.** Variety grenade: "its minis burst and dig on through the ground"; a new picture if it shows worms.

---
title: "Variety grenade: each of its 4 minis hatches a digging worm again"
date: 2026-11-16
status: open
kind: changed
pages: ["Variety grenade", "Cluster bomb", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/VarietyGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/ClusterBomb.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/_meta/_types.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Snail.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** The owner: "verity should burst into digging worms". The variety grenade still bursts into four
mini variety grenades (20 damage at the middle, 8 at the edge, radius 3.5 each), and now each mini, where it bursts,
hatches a worm that digs down through the ground one of four ways at random (6 studs a second for 6 s, eating a
tunnel), biting every snail it touches for 5, at most 6 hits, until it drowns in water or lava. A worm squeaks as it
dives in and crunches as it digs. The grenade's burst plays its own sound, and the Cluster bomb's split too.

**Where.** The row's `Bomblets.Hatch = true` and `Snails = { Count = 4, Hits = 6, Damage = 5, Radius = 2 }`,
`BurstSound = "Variety_Burst"`; the Cluster bomb's `BurstSound = "Cluster_Split"`. Bouncer's `_runBomblet` starts
`Snail.Run` at a hatching mini's blast; Combat's `SNAIL_DIRECTIONS` (moved from Bouncer), `SNAIL_DIG_SOUND_EVERY` 2,
`SNAIL_SPEED` 6, `SNAIL_LIFETIME` 6; `Snail.PlaySound` (`Variety_Squeak`, `Variety_Dig`). The worms draw
`Trail_Variety` (`PROJECTILE_TRAILS.Worm`).

**How to check.** Throw a variety grenade: four minis scatter, and a worm digs out of each one's blast.

**For the wiki.** Variety grenade: how it bursts, and the worms' numbers. Its History: worms came back on 2026-11-16.

Supersedes part of the 2026-11-13 testers' change (the minis-only burst): the minis stay, the worms are back.

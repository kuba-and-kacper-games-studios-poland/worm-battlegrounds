---
title: "Variety grenade bursts into mini grenades; cluster bomblets get trails"
date: 2026-11-13
status: open
kind: changed
pages: ["Variety grenade", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/VarietyGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/ClusterBomb.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** The Variety grenade burst into 4 worms (`Snails`: 8 hits of 5). Now it bursts into 4 mini variety grenades, half size, tumbling, each a blast of 20 damage in the middle, 8 at the edge, radius 3.5 (`Bomblets` with `Mini` 0.5). The Cluster bomb's 5 bomblets are drawn as half-size cluster bombs with the `Trail_Smoke` trail (`PROJECTILE_TRAILS.ClusterBomb`).

**Where.** The two rows' `Bomblets`; Combat's `Bouncer._runBomblet` (`DrawScale`, `Tumble`).

**How to check.** Throw each: four small variety grenades fly out with their trails; the cluster's bomblets leave smoke.

**For the wiki.** Variety grenade: the new burst and its numbers. Cluster bomb: the trails.

**From.** The testers: "verity bomb should spawn small verities instead of worms", "cluster trails missing when it expands".

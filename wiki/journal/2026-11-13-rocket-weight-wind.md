---
title: "Every thrown weapon flies like the rocket, with more power (max 180) and wind 3 to 7"
date: 2026-11-13
status: open
kind: changed
pages: ["Arsenal", "Match modules", "Weapons"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Bazooka.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Grenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/ClusterBomb.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/SpiderBomb.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/HomingMissile.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/SpartanSpear.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/VarietyGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/BlackHoleGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** Every thrown or fired arc weapon launches at `MinSpeed` 20 to `MaxSpeed` 180 and feels the wind. Before: Bazooka 20-150; Grenade and Cluster bomb 15-112; Spider bomb 15-125; Homing missile max 112; Spartan spear max 138; Variety grenade 15-106. Grenade, Spider bomb and Variety grenade ignored the wind. Combat's `WIND_ACCEL` went 3 to 7 studs/s2 per wind point, so a shot into the wind lands visibly short.

**Where.** Each weapon's row in Arsenal's `Data/Weapons`; Combat's `WIND_ACCEL`.

**How to check.** Fire the Grenade at full power into strong wind: it falls well short of the same shot with the wind.

**For the wiki.** Arsenal and each weapon's page: launch speeds and wind. The bots aren't retrained for these speeds yet.

**From.** The testers: "every weapon should have same physic weight as rocket", "overall increase shooting power", "wind doesnt effect the physics of projectiles enough".

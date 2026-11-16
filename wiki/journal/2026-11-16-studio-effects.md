---
title: "The studio's new effects: booster flames, hit sparks, fog trails, new Speed and Low gravity auras"
date: 2026-11-16
status: open
kind: changed
pages: ["Weapons", "Speed potion", "Low gravity potion", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Potions.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.** New Vfx prefabs in the place (`Workspace.Ume.ReplicatedStorage_Assets.Vfx`), from the studio:
`Jet_Booster` (its Booster FX flames, now under the jetpack), `Hit_Sparks` (its damage sparks), `Trail_Fog` (its smoke
trail). `Aura_Speed` and `Aura_LowGravity` are replaced by the studio's new Speed and Low Gravity effects (the
2026-11-12 ones are in `ServerStorage.!dump`), and a potion's aura now copies the effect's trails too. Every snail a
blow hurts throws out sparks, bigger for a harder hit. The Grenade and the Spider bomb draw the fog trail as they fly,
and the variety grenade's worms its variety trail.

**Where.** Combat's `HIT_VFX` (`"Hit_Sparks"`), `HIT_VFX_SCALE` 1.5, `HIT_VFX_DAMAGE_SCALE` 0.03 a point,
`HIT_VFX_MAX_SCALE` 4 (`Effects._onHit`); `PROJECTILE_TRAILS` gained `Grenade` and `SpiderBomb` = `Trail_Fog`,
`Worm` = `Trail_Variety`. Snails' `JET_EXHAUST_VFX` = `"Jet_Booster"`; `Potions._startAura` copies trails. Flight's
`MakeTrailCarrier` is now public (the vortex uses it).

**How to check.** Hit a snail: sparks fly off it. Throw a Grenade: a fog trail follows it. Drink a Speed potion: the
new aura. The prefabs were made in Studio and aren't in the repo; not re-checked here.

**For the wiki.** Weapons (the Grenade's and spider bomb's trails), the potions' pages (their new auras), Match screen
(hit sparks).

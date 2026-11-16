---
title: "Homing missile locks on, stalls 0.2 s, then dives (70 → 150 speed, capped turn)"
date: 2026-11-16
status: open
kind: changed
pages: ["Homing missile", "Weapons", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/HomingMissile.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/_meta/_types.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Helpers/Ballistics.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Homing.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** After flying like a rocket for its lock delay (1 s, unchanged), the homing missile locks on: it
stalls for 0.2 s with its nose turning to the target, flashes and beeps, then dives with a whoosh, a jet trail and
lightning sparks. In the dive it speeds up from 70 (was a flat 60) to 150 studs a second, at 160 a second, and turns
toward the target at most 5 radians a second, 10 more each second, so it bends into the target instead of snapping
straight at it. Bots predict it the same way.

**Where.** The row's new fields: `LockPause` 0.2, `HomingSpeed` 70, `HomingMaxSpeed` 150, `HomingAccel` 160,
`HomingTurn` 5, `HomingTurnGrowth` 10 (`Arsenal_WeaponData`). Ballistics' steering (`LockPauseSteps`), the options in
Homing.lua and Bots' `Predict.GetShot`. Client `Shots._home`: Combat's `HOMING_LOCK_VFX` (`Flash_Sniper` at 2.5),
`HOMING_DIVE_TRAIL` (`Trail_Jet`), `HOMING_DIVE_SPARKS` (`Aura_Speed`'s emitters); sounds `Homing_Lock`,
`Homing_Boost` (the sound kit's own, uploaded the same day: see 2026-11-16-weapon-sounds).

**How to check.** Fire a homing missile at a snail: it pauses a moment after a second, flashes, then curves in fast.
Bots with the Homing missile (Hard) still hit with it. The bots weren't retrained for the new path.

**For the wiki.** Homing missile: how it flies (the stats table's speed, and the lock and dive).

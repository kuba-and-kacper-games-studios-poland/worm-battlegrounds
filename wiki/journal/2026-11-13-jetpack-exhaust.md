---
title: "The jetpack shows its exhaust while flying"
date: 2026-11-13
status: open
kind: fixed
pages: ["Jetpack"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.** The jetpack's trail (`Trail_Jet`) showed nothing while hovering. Now the `Trail_Smoke` prefab's exhaust emitters (`JET_EXHAUST_VFX`) fire down from the snail whenever it's in the air with its jetpack, not falling faster than `JET_FALL_SPEED` 6, and more than `JET_GROUND_GAP` 0.6 studs off the ground.

**Where.** Snails' client `Effects` (`state.Exhaust`, `_isGrounded`).

**How to check.** Fly the jetpack: smoke and flame stream from under the snail, and stop on landing.

**For the wiki.** Jetpack: its look.

**From.** The testers: "jetpack vfx missing".

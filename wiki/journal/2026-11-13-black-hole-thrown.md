---
title: "Black hole grenade is thrown, opens on a second press, holds for 2.5 s"
date: 2026-11-13
status: open
kind: changed
pages: ["Arsenal", "Weapons"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Roller.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/BlackHoleGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** The Black hole grenade was placed at the feet and rolled (`RollSpeed` 10, `MaxRollTime` 8). Now it's thrown on an arc like the rocket (20-180, wind), opens on the first thing it touches or when its owner presses again in flight, holds still for `HoleTime` 2.5 s pulling snails within `PullRadius` 20 studs toward it (`BLACK_HOLE_PULL_SPEED` 45, was the roll's `ROLL_HOP_SPEED` 22; teammates aren't pulled), then bursts.

**Where.** Combat's `Behaviors/Roller.lua` (`_pull`), its row, Combat's Settings.

**How to check.** Throw it at a group of snails and press again mid-air: it stops there, pulls them in for 2.5 s, then explodes.

**For the wiki.** The black hole grenade's page (make it if missing): how it's used, its numbers.

**From.** The testers: "blackhole granade not working and vfx doesnt last long, should be throwable and when you click again it activates".

---
title: "Shots fly at half speed (was 20% slower)"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Settings.lua
---

**What changed.** Every shot flies at half its real speed, along the same path as at full speed: the same arcs,
reach, wind, bounces and blasts, only slower to watch. A thrown bomb's fuse stretches with it, so the Grenade (3 s
fuse) now flies 6 real seconds and bursts where it would at full speed. At 20% slower it burst after 3 real seconds,
2.4 s along its path, so it now goes a little further than in that build. The Dynamite, which is placed and doesn't fly,
still goes off 3.5 real seconds after the 3 s retreat.

**Where.** `PROJECTILE_TIME_SCALE` 0.8 → 0.5 in Combat's `Settings.lua`. `Bouncer.Run` divides a thrown bomb's `Fuse`
by the scale (`Aim ~= "Feet"`). Bots' `Predict._fly` does the same, and counts `PREDICT_SECONDS` (8 → 6.4) in the shot's
own time, so bots see as far along a shot as before.

**How to check.** In a Studio match with bots (2026-11-08), Bazooka shots flew and blasted with no errors. The
Grenade's 6 s flight wasn't caught in that run.

**For the wiki.** Arsenal: shots fly at half speed; the Grenade's fuse is 3 s of flight (6 s on the clock). Match
modules: the time scale and that fuses of thrown bombs follow it.

Supersedes 2026-11-08-slower-shots-longer-reach for the speed (0.8 → 0.5); its reach numbers (`MaxSpeed` up 25%) still
hold.

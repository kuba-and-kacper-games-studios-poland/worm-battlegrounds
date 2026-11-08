---
title: "Shotgun, Uzi and Minigun fire again"
date: 2026-11-08
status: open
kind: fixed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Hitscan.lua
---

**What changed.** The three guns (Kind `Hitscan`) did nothing when fired: the turn ended with no bullets. Every bullet
now flies, hits the first snail or chips the terrain, and draws its tracer.

**Where.** `Module.Run` in `Combat/Scripts/Server/Behaviors/Hitscan.lua` called `Projectiles.GetSnail`, which doesn't
exist; it calls `Ballistics.GetSnail` (`Combat/Scripts/Helpers/Ballistics.lua`) now. The error only showed in the
server Output (`[Combat::Fire]: Shot (Minigun) by (B_3) failed! … attempt to call a nil value`).

**How to check.** In a Studio match a Minigun shot sends its bullets' `Combat_Tracer` events one after another (100
checked on 2026-11-08); the Shotgun's pellets and the Uzi's burst land too.

**For the wiki.** Arsenal: no numbers changed; a History line that the guns work (they never fired before).

**From.** A tester's notes passed on by the owner ("shotgun doesn't work", "uzi not working", "minigun can't shoot").

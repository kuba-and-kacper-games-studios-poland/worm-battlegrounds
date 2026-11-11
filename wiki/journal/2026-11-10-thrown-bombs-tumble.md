---
title: "Thrown bombs tumble through the air"
date: 2026-11-10
status: open
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Helpers/Ballistics.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/_meta/_types.lua
---

**What changed.** Thrown bombs (Grenade, Cluster bomb, Variety grenade) used to fly
without turning until they touched the ground. They now leave the hand spinning the way they're thrown, faster the
faster they fly sideways, and keep turning through the air; once they roll, the ground sets their spin as before. Only
the look changes: the path is the same.

**Where.** New shot option `Tumble` (`Combat_ShotOptions`, set by the `Bouncer` behaviour). `Ballistics.New` gives
such a body `Spin = clamp(-velocity.X * AIR_SPIN, -AIR_SPIN_MAX, AIR_SPIN_MAX)`. New Combat settings `AIR_SPIN` 0.35
(radians a second of flight per stud a second sideways) and `AIR_SPIN_MAX` 30. Cluster bomblets don't tumble, and a
placed Dynamite (no sideways speed) gets no spin.

**How to check.** Throw a Grenade at full power: its model turns over and over in flight, the other way when thrown
left. Not checked in Studio by the docs pass.

**For the wiki.** Arsenal: nothing to change unless the page describes how thrown weapons look in flight.

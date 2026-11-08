---
title: "Explosives blow up when they touch water or lava"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Rocket.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Homing.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Roller.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Crawler.lua
---

**What changed.** A shot that touches water or lava blows up right there instead of sinking and fizzling out: the
Bazooka, Grenade, Dynamite, Cluster bomb and its bomblets, Variety grenade, Homing missile, Black hole grenade and
Spider bomb. Any liquid counts, ponds too (Desert's oasis). The Spartan spear, which pierces, still sinks.

**Where.** Each behaviour bursts when its body is `Sunk` (set by `Ballistics` when it enters a liquid cell);
`Crawler` checks `I.Arena.GetLiquid` while it flies and while it crawls. Supersedes the sinking part of
`2026-11-07-projectile-physics`: sinking now only applies to the spear.

**How to check.** In a Studio match on Desert, Dynamite placed in the oasis blew up as soon as it touched the water
(2026-11-08).

**For the wiki.** Arsenal: a tip that explosives go off in water and lava. Match modules: shots no longer sink, except
the spear.

**From.** The tester's notes ("if anything explosive touches lava, it explodes, same with water").

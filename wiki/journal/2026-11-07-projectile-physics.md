---
title: "Shots bounce, roll and sink like in Worms, smooth on every screen"
date: 2026-11-07
status: open
kind: changed
pages: ["Arsenal", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Helpers/Ballistics.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** Flying shots (Bazooka, Spartan spear, Grenade, Dynamite, Cluster bomb and its bomblets, Variety
grenade, Homing missile, Black hole grenade) no longer use Roblox physics. The game simulates them itself, the same
way on the server and on every player's screen:

- **Grenade:** bounces off ground, walls and snails, keeping half its speed into the surface (`Elasticity` 0.5) and
  80% along it (`BOUNCE_FRICTION`) each bounce; a hit softer than 8 studs a second (`REST_SPEED`) stops bouncing and
  rolls, slowing by 12 studs/s² (`ROLL_DRAG`), and it rolls off ledges. Dropped from 15 studs it bounces 4 times and
  settles in about 1.1 s; it still goes off at 3 seconds.
- **Water and lava:** a shot that lands in liquid sinks slowly and fizzles out after 1.5 s **without exploding**
  (`SINK_SECONDS`), as in Worms. Before, shots passed through the liquid and burst on the sea floor.
- **Black hole grenade:** rolls at its `RollSpeed` and hops over steps only from the ground.
- **Smoothness:** each screen predicts the shot itself and corrects to the server 10 times a second (remotes
  `Combat_Shot`, `Combat_ShotState`, `Combat_ShotEnd`), so shots fly smoothly at any frame rate and land where the
  server says. In Studio tests every copy ended within 0.01 studs of the server's.

The spider bomb and the Variety grenade's snails still crawl as before.

**Where.** `Combat/Scripts/Helpers/Ballistics.lua` (the simulation), `Projectiles.lua` (`Launch`, `Fly`, `Land`),
`Combat/Scripts/Client/Shots.lua` (prediction and corrections), the behaviors in `Combat/Scripts/Server/Behaviors/`;
the numbers in Combat's `Settings.lua` (Projectile Physics).

**How to check.** In a Studio match, a bot's grenade bounces a few times, rolls and goes off at 3 s; a shot into the
sea sinks without a blast.

**For the wiki.** Arsenal: the Grenade's bounces and roll, and that shots landing in water or lava sink without
exploding. Architecture: shots are simulated by the game on the server and each client, not by Roblox physics.
Unsure: the bounce and roll numbers were set from Worms by feel and want a play test by the owner.

---
title: "Shots aimed into the ground start on it instead of passing through"
date: 2026-11-10
status: open
kind: fixed
pages: ["Arsenal", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Aim.lua
---

**What changed.** A grenade or Bazooka shot aimed down at the ground under the snail went through about 5 studs of
ground and burst below it. The shot started a fixed 2.1 studs from the snail's middle (`ROOT_SIZE / 2 +
MUZZLE_GAP`, 1.3 + 0.8), which was inside the terrain, and the shot simulation's spherecast never hits a part it
starts inside. Now a shot starts just short of whatever is in the way (terrain or a snail), or `MUZZLE_GAP` (0.8)
past the ball when nothing is, so a shot aimed into the ground bursts on it.

**Where.** New `Projectiles.GetStart(origin, direction, shooter)` in `Combat/Scripts/Server/Projectiles.lua`: a raycast
from the ball's middle along the aim, stopping `PROJECTILE_SIZE / 2 + PROJECTILE_SKIN` short of the hit. It's on the
server API as `I.Combat.GetShotStart`. `Fire.Fire` uses it for the shot's `Origin` (placed weapons, `Aim = "Feet"`,
still start at the ball); the bots' `Predict.GetShot` and `Aim.GetContact` use it too, so they foresee the same start.

**How to check.** In a Studio match, stand on ground and fire a Grenade or the Bazooka straight down: it bursts at the
snail's feet and cuts a crater there, never under the ground. Not checked in Studio by the docs pass.

**For the wiki.** Arsenal or Match modules (Combat): a shot leaves the snail's ball, or the surface in front of it when
that's closer. Nothing a player reads changes beyond the bug.

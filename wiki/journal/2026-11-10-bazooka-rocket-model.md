---
title: "The Bazooka fires the studio's BazookaRocket model"
date: 2026-11-10
status: open
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
---

**What changed.** A Bazooka shot now flies as the studio's new rocket model (the "BazookaRocket" the owner put in
Workspace), nose first along its path, 2.2 × 0.87 × 0.87 studs (drawn at twice that on screen, as every projectile).
Before, it flew as a stand-in.

**Where.** In the place: `Workspace.Ume.ReplicatedStorage_Assets.Arsenal.Projectiles.Bazooka` (a `RootPart` facing +X
and the rocket mesh welded to it, scaled 0.446); the original `BazookaRocket` is kept in `ServerStorage.!dump`. In code,
Combat's `PROJECTILE_STAND_INS` is gone and Flight's `_addShot` takes the projectile model by the shot's name. The
place must be saved and published for it to reach the live game.

**How to check.** Fire the Bazooka in a match: the rocket flies nose first, at the size of the snail's head.

**For the wiki.** Arsenal → Bazooka: the projectile's look, if the page shows one.

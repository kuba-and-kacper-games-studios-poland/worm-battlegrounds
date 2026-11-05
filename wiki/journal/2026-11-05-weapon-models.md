---
title: "Weapon models for 9 weapons, set up in Arsenal"
date: 2026-11-05
status: open
kind: added
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Global.lua
---

**What changed.** The studio's weapon models are in the game, named after their weapons: Bazooka, Shotgun, Uzi,
Homing missile (the launcher, plus the missile as its projectile), Grenade, Dynamite, Cluster bomb, Spider bomb and
Black hole grenade (a blue glass grenade with a lever: the one model that didn't match the art sheet, named by
elimination). Players don't see them yet: Combat still draws its placeholder projectiles. Still without a model:
Baseball bat, Minigun, One Punch, Spartan spear, Variety grenade.

**Where.** In the place: `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/Models/<WeaponId>` and
`…/Arsenal/Projectiles/HomingMissile`, moved into `Assets/Arsenal` at start. Each is a Model with a hidden anchored
`RootPart` (PrimaryPart) the meshes are welded to, facing +X; held weapons have it at the grip, thrown ones at the
centre. Sizes were brought to one scale around the worm (3.5 studs tall): held weapons 2.8–4.5 studs long, thrown
ones about 1.5, the spider bomb 2.6 wide. `I.G_Arsenal.GetModel(itemId)` and `GetProjectileModel(itemId)` return
them (`Arsenal/Global.lua`, cached at start on both sides).

**How to check.** In Studio, `Workspace.Ume.ReplicatedStorage_Assets.Arsenal` holds the models; in a test,
`I.G_Arsenal.GetModel("Bazooka")` returns its Model.

**For the wiki.** Arsenal: the Black hole grenade has art now (a blue glass grenade, not the dark one with a purple
swirl the page asks for). The Spider bomb is still red with blue legs, which the page flags as too close to
Spider-Man's colours.

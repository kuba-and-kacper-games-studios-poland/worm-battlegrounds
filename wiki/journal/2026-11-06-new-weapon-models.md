---
title: "Minigun, Spartan spear and Variety grenade models, a cyan Homing missile launcher, and smiley snails"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: added
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
---

**What changed.** The studio's second batch of models is in the game. Three weapons that had no model now do:
the **Minigun** (grey, four barrels, carry handle on top; held, 4.5 studs long), the **Spartan spear** (an orange
shaft with a grey head, no red ribbon; 5 studs, thrown) and the **Variety grenade** (a yellow smiley ball, 1.8
studs). The Variety grenade's 4 **snails** now fly and crawl as small grinning smileys (0.9 studs) with their face
always to the camera, instead of yellow placeholder balls. The worm holds each weapon on its turn, and its shot flies
as its model. The **Homing missile's launcher** is now cyan (the same shape as before, to match its missile's cyan
tips), so it no longer looks like the green Bazooka; the owner picked it on 2026-11-06 ("green for normal bazooka and
cyan for homing missile launcher"). Numbers didn't change. Still without a model: Baseball bat, One Punch, the Cluster bomb's bomblets.

**Where.** In the place: `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/Models/Minigun`, `…/SpartanSpear`,
`…/VarietyGrenade` (each a `RootPart` with a `Muzzle` attachment at the barrel or tip), `…/HomingMissile` (the cyan
launcher on the old one's RootPart and Muzzle; the green one is kept in `ServerStorage.!dump.HomingMissile_Green`) and
`…/Arsenal/Projectiles/Snail`. Arsenal's `BURST_SHOTS` (`{ "Snail" }`) lets a burst's shot have a projectile model,
and `I.G_Arsenal.HasProjectileModel(shotId)` is new. Combat's `Flight.lua` draws any projectile part with a model,
weapon or not; a snail is placed upright, face to the camera.

**How to check.** In a Studio playtest, a part named `Snail`, `VarietyGrenade` or `SpartanSpear` with the
`Projectile` attribute in `Workspace.Ume.Combat` got its model drawn over it, and the model went away with the part.
No Arsenal warnings at start.

**For the wiki.** Arsenal: the Minigun, Spartan spear and Variety grenade have models now, and the Homing missile's
launcher is cyan (the art shows it green with a cyan screen). The snails are drawn as
small smiley balls, as in the weapons art, though the page calls them snails: maybe say "smiley snails". The spear
has no red ribbon, unlike the art.

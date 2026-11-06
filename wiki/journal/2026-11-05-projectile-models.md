---
title: "Shots fly as their weapon's model (grenades, missiles, the Bazooka's rocket)"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** Thrown and launched weapons now fly as their models instead of coloured placeholder balls: the
Grenade, Dynamite, Cluster bomb, Spider bomb and Black hole grenade as themselves, the Homing missile as its missile.
The Bazooka's rocket uses the homing missile's missile for now, since the studio sent no rocket for it. Rockets and
missiles point along their flight, never upside down. Thrown and rolled weapons turn with the ball under them. The
spider bomb stays upright and faces the way it crawls. Cluster bomblets, snails and the Spartan spear still fly as
placeholders (no models).

**Where.** Combat's client handler `Scripts/Client/Flight.lua`: for each projectile part (named after its weapon) it
draws `I.G_Arsenal.GetProjectileModel` on every client and hides the server's placeholder part there
(`LocalTransparencyModifier`). `PROJECTILE_STAND_INS` in Combat's `Settings.lua` maps Bazooka → HomingMissile, a
placeholder until the Bazooka has its own rocket model.

**How to check.** In a Studio playtest, the Bazooka, Grenade and Black hole grenade flew as models with the
placeholder hidden; the Bazooka's missile pointed along its path (up and right on the way up, nose down falling).

**For the wiki.** Arsenal: shots look like their weapon in flight. Still unsure: the Bazooka needs its own rocket
model from the studio.

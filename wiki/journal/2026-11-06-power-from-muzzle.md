---
title: "The power circles start at the weapon's barrel, and the crosshair keeps its size when zooming"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
---

**What changed.** Before: the power circles started just past the worm's body, not at the weapon, the weapon in the
worm's hands lagged behind the crosshair on the shooter's own screen, and the crosshair and circles shrank when the
camera zoomed out. Now the circles run from the tip of the weapon's barrel (the front of a grenade or bomb) to the
crosshair, the held weapon turns with the crosshair at once, and the crosshair and circles stay the same size on
the screen at any zoom. Shots still leave from the same point as before, just past the worm.

**Where.** A `Muzzle` Attachment on the RootPart of each model in `Arsenal/Models` (Bazooka 0, 0.9, −2.4; Shotgun 0,
0.6, −3.15; HomingMissile 0, 0.6, −2.77; Uzi 0, 1, −1.45; thrown weapons at their front). Combat's client
`I.Combat.SetAim` and `GetMuzzle`; sizes scale by the camera's distance over MatchCamera's `DISTANCE` (110).

**How to check.** Checked in Studio 2026-11-06: with the Bazooka, the first circle sits on its barrel's tip; zoomed
out to about 190 studs, the crosshair grew from 3 to about 4.8 studs.

**For the wiki.** Match screen: where the power circles start. Probably nothing else.

**From.** The owner's request (2026-11-06): "it's not coming out of weapons … make it scale if you zoom out … make
it client-side so it's not lagging".

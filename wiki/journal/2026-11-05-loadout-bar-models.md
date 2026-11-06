---
title: "Loadout bar: weapons with no icon show their 3D model"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Global.lua
---

**What changed.** In the match's loadout bar, a weapon that has no icon picture used to leave its box empty. Now the
box shows the weapon's 3D model, side-on with the muzzle to the right, sized to fill the box. Today that's the Homing
missile, Uzi, Dynamite and Spider bomb; Baseball bat, Minigun, One Punch, Spartan spear, Variety grenade and the
utilities without a picture (Bandage, Medkit, Speed potion, Parachute, Low gravity potion) still have neither. Weapons
with an icon keep it.

**Where.** `_showModel()` in `MatchHud/Scripts/Client/LoadoutBar.lua`, called from `_rebuild()` when a row's `Icon`
is `""` and `I.G_Arsenal.HasModel(itemId)`: a ViewportFrame `S_Model` over the box's `S_Icon`, its camera at
`MODEL_FOV` 30 from `MODEL_VIEW_DIRECTION` (0.3, 0.25, 1), `MODEL_PADDING` 1.15 around the model's longest side
(`MatchHud/Settings.lua`).

**How to check.** Played on the Match map in Studio: the Homing missile's box (slot 4) shows the green launcher, and a
test row of all nine models showed each one whole and readable.

**For the wiki.** Match screen → the loadout bar: a weapon without an icon shows its model. Also worth knowing for
Arsenal: the item pictures are still local to Studio (not uploaded), so a Studio update blanks them until they're
copied in again.

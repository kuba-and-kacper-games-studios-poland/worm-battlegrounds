---
title: "Utility models: worms wear the Parachute and Jetpack, and the loadout bar shows each utility"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: added
pages: ["Arsenal", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Worms/Scripts/Client/Gear.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Worms/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Worms/Settings.lua
---

**What changed.** Five of the six utilities have models from the studio: **Jetpack** (grey frame, two white tanks
with red bands), **Speed potion** (blue bottle with a lightning bolt and a cork), **Parachute** (a white canopy,
yellow inside, grey lines and harness), **Bandage** (a white roll with a red band and cross) and **Medkit** (a red box
with a white cross and a grey handle). The loadout bar shows each one in its box, as it does for weapons without an
icon. A worm now **wears** two of them while they work, on every screen: the open Parachute over its head while it
floats down (also on the drop at the match's start), and the Jetpack on its back for the rest of the turn once
used. The Parachute in the art is orange and white; this one is white and yellow. The Low gravity potion still has no
model.

**Where.** In the place: `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/Models/<UtilityId>` (Jetpack, SpeedPotion,
Parachute, Bandage, Medkit). Arsenal now caches models for utility rows too. Worms' client `Scripts/Client/Gear.lua`
puts a copy on the worm while its attribute is set: `Parachute` (WormControl sets it when the chute opens, clears it
on landing) and `JetpackFuel` (set on use, cleared at the turn's end). `GEAR` in Worms' `Settings.lua` holds each
one's attribute and offset: Parachute 4.3 studs above the worm's ball, Jetpack 1.3 behind and 0.8 up.

**How to check.** In a Studio playtest, setting `Parachute` and `JetpackFuel` on a worm put `Parachute` and
`Jetpack` models under it (the canopy showed over the worm); clearing them took them off.

**For the wiki.** Arsenal → Utilities: the Jetpack and Parachute show on the worm while they work; five utilities
have models, the Low gravity potion's is still to come. Match screen: the
loadout bar shows the utility models. Unsure: the Jetpack is worn for the whole turn after use, even once its fuel is
spent.

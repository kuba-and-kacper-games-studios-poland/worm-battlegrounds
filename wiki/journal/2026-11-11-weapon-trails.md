---
title: "Trails for missiles, the black hole and variety grenades, and the jetpack"
date: 2026-11-11
status: open
kind: added
pages: ["Bazooka", "Homing missile", "Black hole grenade", "Variety grenade", "Jetpack"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/libs/Internal/Vfx/init.lua
---

**What changed.** Four trails from the studio (Studio's `Workspace.Trails_New`) now show in matches:

| Trail (prefab) | From | On |
| --- | --- | --- |
| `Trail_Smoke` | smoke (a wavy fog, made a little grey, thinner and shorter for the owner: 0.65 s), with an exhaust of small soft grey smoke puffs and a tiny orange thruster flame at the missile's tail | The Bazooka's and the Homing missile's shots |
| `Trail_BlackHole` | blackhole (a dark cloud and an orange chromatic streak, 0.5 s) | The Black hole grenade's shot |
| `Trail_Variety` | verity (a yellow glow, 0.5 s) | The Variety grenade's shot |
| `Trail_Jet` | jet (a white wavy jet, 0.5 s) | A snail's jetpack while it climbs on it |

A shot's trail follows it through its flight (a tumbling grenade's stays smooth) and fades where the shot ends; a
missile's trail and exhaust start at its tail (Combat's `TRAIL_TAIL`, 2 studs behind its middle). The exhaust is
light: about 16 smoke puffs a second living under a second, and a few thruster sparks at a time. The
jet shows only while the active snail climbs with its jetpack (as its hum), from under the jetpack.

**Where.** The prefabs are `PREFAB | Trail_<Name>` parts in `Workspace.Ume.ReplicatedStorage_Assets/Vfx` (the place:
saved with it). Combat's `PROJECTILE_TRAILS` (item id → trail) and `TRAIL_SCALE` (1); Snails' `JET_TRAIL_OFFSET`
`(0, -0.6, 2.4)`. `I.Vfx.AddTrail` now copies every Trail of a prefab (the black hole's has two) and its other
attachments with their emitters (the smoke trail's `Exhaust`: `Smoke` and `Thruster`, Roblox's built-in smoke and
fire textures, off in the prefab and turned on while the shot flies), and returns the Trails as a list. No remote changed: every client draws them itself.

**How to check.** Fire a Bazooka or a Homing missile: a light grey smoke trail with small puffs follows it, and a tiny
flame glows at its tail. Throw a Black hole grenade or a Variety
grenade: their trails follow them. Use a Jetpack and hold jump: a jet streams from under it while it climbs.

**For the wiki.** Each weapon page (and the Jetpack's): a line on its trail in the look or effects section.

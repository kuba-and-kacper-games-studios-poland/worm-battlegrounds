---
title: "Jetpack: the studio's twin-tank model on the shell, and picking it puts it on at once"
date: 2026-11-16
status: open
kind: changed
pages: ["Jetpack", "Utilities", "Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Gear.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/_meta/_types.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The worn jetpack is the studio's new twin-tank model (from its `SnailJetPack` rig), in the place at
`Workspace.Ume.ReplicatedStorage_Assets.Arsenal.Models.Jetpack`. It's strapped to the snail's shell: it follows the
skin's shell bone through the idle, the walk and the hide, its back tank on the back of the shell and its front tank
hidden in it. Before, it sat at a fixed spot behind the ball (2.4 behind, 0.4 up). The jet now comes out under the
back tank, and its flames are the studio's Booster FX (the `Jet_Booster` effect) instead of the rocket's smoke and
thruster. Picking the Jetpack on the loadout bar now puts it on at once, with no press on the screen.

**Where.** Snails' `GEAR.Jetpack`: `Bone = "Bone.013"` (the shell's), `BoneOffset` (0.569 up, 0.747 along the bone,
turned onto the shell's back), `Offset` (0, 0.15, 1.2) on a skin without that bone; `GEAR_SKIN_SCALE` 0.45 scales the
offset for bigger skins. `Gear._step` and `Gear._getBone`. `JET_TRAIL_OFFSET` (0, -0.85, 2.2), was (0, -0.6, 2.4).
`JET_EXHAUST_VFX` `"Jet_Booster"`, was `"Trail_Smoke"`. MatchHud's `USE_ON_SELECT` (`{ Jetpack = true }`):
`LoadoutBar.Select` calls `LoadoutBar.UseHeld` for it.

**How to check.** In a match, pick the Jetpack: it goes on at once (fuel bar shows), sits on the shell and stays there
while the snail walks or hides; flying shows the booster flames under the back tank.

**For the wiki.** Jetpack: what it looks like, and that picking it puts it on (no second press). Utilities: the
Jetpack is the exception to "pick, then press to use".

Supersedes part of 2026-11-15-utilities-held: the Jetpack is no longer held first; the other utilities still are.

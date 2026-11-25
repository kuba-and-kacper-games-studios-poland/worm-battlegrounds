---
title: "Parachute icon: the owner's picture in place of the placeholder"
date: 2026-11-25
status: open
kind: changed
pages: ["Parachute"]
files:
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Utility/Parachute.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/Parachute.lua
  - art/weapons/parachute.png
---

**What changed.** The Parachute shows its own picture (`art/weapons/parachute.png`, the owner's: an orange studded canopy
on grey lines and a harness) instead of the shared placeholder icon (rbxassetid://121731184312632, which the snail
pieces still use). Uploaded as a Decal to The Snail Studio group ("Snail Parachute Icon", 81737047895876, approved);
image rbxassetid://124029473662987, its fully see-through pixels turned black so no white fringe shows.

**Where.** The Inventory row's `IconId` and the Arsenal row's `Icon` (was empty).

**How to check.** A player who owns the Parachute (it's disabled for everyone else) sees the new picture on the
loadout, in the picker and on the match bar.

**For the wiki.** Parachute: the new icon.

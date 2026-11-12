---
title: "The sea reaches 50 studs past the map's sides"
date: 2026-11-12
status: open
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** The owner: the water was "seen as cut out" at the map's sides when moving or zooming out the camera.
The sea (the liquid at the map's floor: water, Desert's lava, Rockslide Ridge's yellow sea) is now drawn 50 studs past
the map's left and right sides, up to its level, on every map. It's only drawn: the liquid's simulation still stops at
the map's sides, and anything out there is out of bounds as before (snails knocked out, shots lost). When sudden death
raises the sea, the part past the sides rises with it.

**Where.** Arena's new setting `SEA_EDGE_WIDTH` (50 studs), used in `Module._render` in
`Arena/Scripts/Server/Liquid.lua`: the sea's blocks touching a side are stretched past it (the rows of liquid standing
on the floor in the map's first and last columns, `Module._getFloorRun`), and where land stands at a side below the
sea's level (Picnic Plains' bedrock from Y 4), a block outside tops it up to the level. They are ordinary liquid
blocks in `Workspace.Ume.Arena.Liquid`, with their `Arena_Liquid` attribute, so Atmosphere's effects read them too.

**How to check.** Studio bot match on Picnic Plains, 2026-11-12: the sea's blocks reach X −191 to 191 (the bounds are
±141), Y −8 to 6.5 at the sides; zoomed out at the right edge, the water runs on past the screen with no seam. No new
warnings. Desert and Rockslide Ridge weren't loaded with this change.

**For the wiki.** Architecture: the liquid section can say the sea is drawn `SEA_EDGE_WIDTH` past the sides. Match modes
& maps: nothing a player reads, unless the page shows the maps' edges.

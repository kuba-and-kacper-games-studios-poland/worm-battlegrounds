---
title: "Map backgrounds move with the camera: parallax layers on Desert, Rolling Plains and Echo Caverns"
date: 2026-11-25
status: open
kind: added
pages: ["Desert", "Rolling Plains", "Echo Caverns", "Maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Parallax.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Mood.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/_meta/_types.lua
  - art/map_skies/parallax.py
  - art/map_skies/desert_backdrop.blend
---

**What changed.** The skybox's clouds and mesas stayed fixed on screen as the camera zoomed and panned (the owner:
"creates a weird illusion"). On Desert the sky is now a plain gradient, and the scenery stands in the world behind
the map at three depths, so it shifts and scales with the camera like real distance: stepped brick sandstone mesas and
buttes about 1100 studs back, blocky voxel clouds about 700 back, and stepped brick sand dunes with a few blocky cacti
about 350 back. They're in the maps' own brick look, rendered in Blender, hazed more the farther back they stand;
only the far layer is slightly softened (a first, stronger blur on every layer was "too much", the owner).

Rolling Plains and Echo Caverns got theirs the same day, in the same brick look, over a gradient sky: Rolling Plains
small grassy islands on the sea (the map's own grass green over its rock-brown shore, blocky oaks and pines), voxel
clouds, and a far line of hazy low islands, the sea one flat blue to the horizon (one colour behind both layers). Its first version, green hills
all the way back, had "too much grass" in a colour that didn't match the map (the owner), so it was redone the same
day. Echo Caverns a far snowy brick range, voxel clouds, and near snowy rock hills with snow-tipped pines. Desert also got
Rolling Plains' sun-ray biome effect (its `Vfx` folder; no particle clouds), at the owner's request.

**Where.** Atmosphere's new client handler `Scripts/Client/Parallax.lua` builds a map's layers in
`Workspace.Ume.Atmosphere.Parallax` from its mood row's `Parallax` list (each row: `Image` or `Color`, `Depth`, `X`,
`Bottom`, `Width`, `Height`; Settings' `PARALLAX_CANVAS` 1024); Mood calls it with the map's bounds and clears it in
the lobby. Desert's row: a new gradient-only `Sky` and 12 layer rows. The pictures and their ids are in
`art/map_skies/README.md`; the Blender scene is `art/map_skies/desert_backdrop.blend`.

**How to check.** Play a match on Desert and zoom out and in: the map grows and shrinks a lot, the far mesas barely,
the clouds and dunes in between. Checked in Studio playtests at both zooms.

**For the wiki.** Desert, Rolling Plains and Echo Caverns: a line on their backgrounds. Maps: backgrounds move with
the camera.

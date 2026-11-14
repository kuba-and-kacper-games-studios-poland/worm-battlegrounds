---
title: "New map: Echo Caverns, a cavern under a snow-capped rock dome, over water"
date: 2026-11-14
status: open
kind: added
pages: ["Match modes & maps", "Echo Caverns", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** Echo Caverns (map id `EchoCaverns`) is built and in the match rotation for 2, 4 and 6 snails. It's
the studio's underground rock map, built in Studio ("rock underground something", the owner; Echo Caverns is a
working name). 296 × 114 studs: a cavern under a snow-capped rock dome, over a sea of plain water (Arena's own water
colour). Stalactites hang from the dome; rock columns stand like mushrooms on the boulders along the floor, with brown
slabs leaning among them. Everything stands on the sea's bed: six islands, no floating ledges. Columns the studio's
build left hanging just over the floor were taken down to it, gaps of 2 studs or less by the floor were closed (no
snail fits in one), and crumbs under 24 square studs went. The water between the islands is ponds (5 to 15 studs
across) except one stretch, x 0 to 18 from the map's middle: 18 studs of open sea, which knocks snails out
(`SEA_MIN_WIDTH` 16).

For now it borrows Rockslide Ridge's cave mood (the `Cave` preset, cave dust, ripples on the water, grit from the
ceiling) and music, and Rockslide Ridge's lobby card picture, until it has its own (`shortcut:` comments mark both).

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.EchoCaverns` (slot 8, at X 1500, Z −300
in Studio), made in MapLab from the studio's build (the game home's `assets/models/maps/echo_caverns/`, card
`asset.yaml`): `Terrain/Island_1`–`6` (`Island_3` is the dome and the right wall, x −95 to 148, up to Y 81), 921
parts named `Rock`, `LightRock`, `DarkRock`, `DarkStone`, `Cap`, `Snow`, `Strata`, `Clay`, `Bedrock` (bedrock from
Y −8 to 0 with `Arena_Indestructible`); no backdrop; 21 props the studio built, rebuilt part for part (17 `GrassTuft`
in `Decor/Grass`, 4 `RockPile` in `Decor/Rocks`). Markers `Sea` (`Water`, Y −8 to −2) and `Bounds` (296 × 114 × 11).
The land has the depth effect (1.2 studs over 3 levels). MatchBoard's `MAPS.EchoCaverns` (`Thumbnail` Rockslide
Ridge's `rbxassetid://123838177297909`) and `MAP_POOL`; Atmosphere's `PROFILES.EchoCaverns` (Rockslide Ridge's old
row, with water ripples).

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("EchoCaverns")` loads it at X 0 on the plane
with 921 terrain parts and 8 water blocks, its Bounds at 0, 49, 0, and no Arena warnings. Not played as a match yet.

**For the wiki.** Match modes & maps: Echo Caverns is built and in rotation (sizes 2 · 4 · 6; "a cavern under a
snowy dome, stalactites over rock columns"). A page of its own, Echo Caverns: the dome, the columns, the ponds and
the one open stretch of sea. Architecture: slot 8. Still to come: its own lobby card picture, mood and music, and
maybe its final name.

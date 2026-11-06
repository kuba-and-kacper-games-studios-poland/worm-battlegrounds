---
title: "Destructible arena: hand-built parts carved by CSG, stop-motion stud liquids"
date: 2026-11-03
status: merged
merged: 2026-11-06
kind: added
pages: ["Architecture", "Match modules", "Roadmap"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/
  - worm-battlegrounds-game/.claude/rules/game/practices.md
---

**What changed.** The `Arena` module exists (server only). It replaces the wiki's plan of a 2-stud cell grid,
greedy-meshed into parts, with this:

- **Terrain** is a hand-built map template: long parts for the shapes, smaller parts for details, in SmoothPlastic
  with MaterialService's `2022 Stud` variant. Parts marked `Arena_Indestructible` hold everything up.
- **Blasts** subtract a cylinder whose axis runs along Z (`GeometryService:SubtractAsync`, `SplitApart`), so craters
  are round and smooth, not stepped. A cut takes about 10 ms per part in Studio.
- **Falling ground**: after a carve, any group of pieces that no longer touches indestructible ground is welded, falls
  with server physics, and anchors where it lands (after 0.5 s below 0.5 studs/s, or 4 s at most). A bridge cut at
  both ends falls into the sea in one piece.
- **Liquids** (water, lava) are a grid of half-stud cells stepped at 8 fps, for a stop-motion look. Each run of
  liquid merges with the same run in the rows above into one rectangle in the `2022 Small Stud` variant, so a calm
  map is a handful of parts (5 on Picnic Plains) and moving water a few dozen. They flow into craters, spill out of
  broken basins, level out, and are pushed up by debris landing in them. A falling cell drops up to 6 cells a step; a
  cell that can't fall moves sideways toward the nearest way down along its row, up to 12 cells a step for water and
  3 for lava. Then pressure evens out each connected body: up to 8 of its highest cells a step (2 for lava) move into
  the lowest free cells beside it that sit below them, so water levels through gaps and under debris that dips into
  it. `I.Arena.GetLiquid(position)` tells later modules whether a worm is in one.

**Where.** `Arena/Server.lua` (`I.Arena`: `Load`, `Carve`, `GetBounds`, `GetLiquid`, `IsSettled`),
`Scripts/Server/Loader.lua`, `Carver.lua`, `Debris.lua`, `Liquid.lua`; numbers in `Arena/Settings.lua`
(`LIQUID_CELL` 0.5, `LIQUID_FPS` 8, `LIQUID_FALL` 6, `LIQUID_SPREAD` Water 12 / Lava 3, `LIQUID_PRESSURE` Water 8 /
Lava 2, `LIQUID_VARIANT`, `SETTLE_*`, `DEBRIS_*`). Templates go in `SAssets.Arenas.<MapId>` with `Terrain`, `Decor` and `Markers` (`Bounds`,
`DropZone`, boxes with `Arena_Liquid`). Admin command: `/arena load <map>`, `/arena carve <x> <y> <radius>`. No
remotes, Topics or saved data.

**How to check.** Start a Studio test (the `STUDIO_TEST_MAP` shortcut loads `PicnicPlains`, in about 0.2 s), open
the command bar (Ctrl + [) and run `/arena carve 0 2 4`, `/arena carve -40 13 5`, `/arena carve 33 13 5`: the bridge
falls into the sea, its low end dipping into the water. `/arena carve -50 4 9` floods the left shore's crater. About
5 s later the water is level, within half a stud, from the crater to the right shore, on both sides of the plank.
Through a map load and 7 carves, the server averaged 4.2 ms a frame in Studio, with a worst frame of 32 ms.

**For the wiki.** Architecture → "Terrain: a grid drawn as merged parts" and the arena template table, Match modules
→ Arena (handlers, API, settings, done-when), and the Roadmap's P1 tasks no longer match: terrain is authored parts
carved by CSG, falling pieces anchor where they land instead of being written back into a grid, and only liquids use a
grid. Still unsure: the 6 real maps aren't built (only the greybox Picnic Plains, in the place); gravity, lighting
presets and map rows from the P1 plan aren't done yet (collision groups came later:
`2026-11-03-arena-plane-hazards`). Liquid can't spread thinner than one half-stud
cell, so a still surface can keep half-stud bumps, and water a falling piece displaces is pushed up onto that piece
before it slides off. An earlier test run had one server frame of about 160 ms around the carves; the last run
didn't repeat it, and its cause wasn't found.

**Merged.** Smooth round craters were replaced by stepped ones (2026-11-05-voxel-craters), and the indestructible bedrock became cuttable (2026-11-05-bedrock-destructible); the pages say what's true now.

---
title: "New map: Desert, two storeys over lava with an oasis"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: added
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/_meta/README.md
---

**What changed.** A second arena map, `Desert`, made in MapLab (the game home's map kit) from the owner's brief: a
desert like Minecraft's or Terraria's, lava at the bottom instead of water, water at an oasis, cacti, desert rocks,
dry bushes and palms. It's a two-storey map. The bottom storey is one main island standing on the lava (x −110 to
112): a hill on the left, a valley, the oasis pool, a plateau and a ridge on the right, sloping down to the lava at
both ends. The upper storey is two long floating islands, x −128 to −36 (top about Y 66) and x −6 to 122 (top
about Y 74, the bigger one), 20 or more studs above the ground. The land is sand on top (3 to 6 studs), dark sand,
then sandstone with wavy dark bands; clay lines the pool. Props: 9 saguaro cacti (some with a pink flower), 8 dry
bushes, 5 red sandstone rocks, 3 palms by the oasis, all part-built so blasts cut them.

**Where.** In the place: `Workspace.Ume.ServerStorage_Assets/Arenas/Desert`. Terrain 461 parts in `Island_1`,
`Ledge_1`, `Ledge_2` (parts `Sand`, `DarkSand`, `Sandstone`, `DarkSandstone`, `Clay`, `DarkStone`); the bedrock
(`DarkStone`, Y 4 to 8) is `Arena_Indestructible`, every ledge part has `Arena_Floats`. Decor: `Backdrop` 17 parts
(distant dunes and mesas), `Cacti`, `Trees` (palms), `Bushes`, `Rocks`. Markers: `Bounds` 282 × 114 × 11 at 0, 49,
0; `Lava` (`Arena_Liquid = "Lava"`) Y −8 to 4 across the map, first among the liquids, so sudden death raises lava;
`Oasis` (`Arena_Liquid = "Water"`) x −30 to 0, Y 16 to 23. The map's sources (`generate.py`, `land.png`,
`map.json`) are in the game home's `assets/models/maps/desert/`, outside this repo.

**How to check.** Played in Studio with `I.Arena.Load("Desert")`: it loads in 0.43 s, the pool holds water, lava
lies beside and under the island, `GetLiquidKind()` is `Lava`; blasts on an upper island, a cactus, the pool's rim
and the hill cut in 49 to 121 ms, with no warnings. MapLab's validation passes with 0 errors and 0 warnings.

**In matches.** `MatchBoard`'s `MAPS` has a row `Desert = { Name = "Desert", Sizes = { 2, 4, 6 }, Thumbnail = "" }`
(no picture yet), and `MAP_POOL` is `{ "PicnicPlains", "Desert" }`, so quick matches, public rows and custom lobbies
pick it (checked: `I.MatchBoard.GetMap(4)` returns both maps). Its first playtest showed two game limits, fixed in
the entry "Worms start on every storey, and leaning props stay up".

**For the wiki.** Match modes & maps: a new map, Desert (a page or a row, with its two storeys, the lava and the
oasis). Unsure: its display name and sizes for the match board, and whether it joins the six planned maps' list or
replaces one.

**Merged.** Whether Desert is a seventh map or replaces a planned one is asked on Match modes & maps (question desert-map). Part counts and markers come from this entry; the place itself wasn't opened to check them.

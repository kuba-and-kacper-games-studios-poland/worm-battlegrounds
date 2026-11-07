---
title: "New map: Rockslide Ridge, rock pillars over a yellow sea"
date: 2026-11-07
status: open
kind: added
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/_meta/README.md
---

**What changed.** A third arena map, built by the owner in Studio (`Workspace.New.new_map`) and imported as it
stood. It takes the name of the planned map whose wiki row it fits: Rockslide Ridge ("Rock cliffs and ledges that
crumble under fire", 2 · 4 · 6 players; map id `RockslideRidge`, whose MatchBoard row already existed). Grey and
brown stud rock: eight pillars and islands standing on the sea floor, eight floating ledges among them (a long
overhead ridge across the top, Y 68 to 96, and a low bridge over the middle lake), and a rock wall behind. The sea
is yellow. It's now in the rotation (`MAP_POOL`: Picnic Plains, Desert, Rockslide Ridge) and the custom lobby's map
choices.

**Where.** Template `Workspace.Ume.ServerStorage_Assets/Arenas/RockslideRidge`, imported at the positions it was
built (the parts' 180° turn removed, which leaves each box the same), then moved whole into its slot, x 655 to 945
with the plane at Z = 0 (see 2026-11-07-arena-slots). `Terrain/Island_1`–
`8` (46 floor parts with `Arena_Indestructible`), `Ledge_1`–`8` (138 parts with `Arena_Floats`), 295 parts named
`Stone` (105, 102, 92), `Rock` (88, 83, 78), `Dirt` (90, 76, 66); `Decor/Backdrop` (104 thin parts behind). All in
SmoothPlastic with the `2022 Stud` variant (they were Plastic). Markers: `Sea` (`Arena_Liquid = "Water"`, Y −4.5 to
14.5) and `Bounds` (290 × 111 × 25). The map's own layered water model was left out: Arena draws the liquid.
New: a liquid marker's `Arena_LiquidColor` (Color3) colours that liquid on its map (Arena's `Liquid.lua`, `colors`),
else `LIQUID_COLORS`; the Sea's is 248, 217, 109, the top layer of the owner's water.

**How to check.** Join a public card on Rockslide Ridge: the arena loads 295 terrain parts with 8 numbered ledges,
the liquid blocks are 248, 217, 109. Checked 2026-11-07 in a Studio playtest: snails dropped onto it, bots played
turns, blasts cut it, no errors in the output. The original `Workspace.New.new_map` is still in the place.

**For the wiki.** Match modes & maps → Rockslide Ridge: built (its look and layout, the yellow sea), "Maps now" gains
it. Architecture: the map list, and `Arena_LiquidColor`. Still unsure: whether the overhead ridge should float or
fall (it's a floating ledge, so blasts cut its loose pieces down), and the yellow's shade under the game's colour
correction.

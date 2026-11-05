---
title: "Picnic Plains: the studio's map replaces the greybox"
date: 2026-11-05
status: open
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
---

**What changed.** The first map, Picnic Plains (map id `PicnicPlains`), is now the studio's built map instead of the
greybox: three grassy rock islands at the waterline and four floating ledges, with trees, bushes and a blue-grey
backdrop wall behind them, over a sea 282 studs wide and about 14.6 studs deep. Ground no blast can cut
(`Arena_Indestructible`): each island's waterline blocks (48 parts). The ledges float (see the entry "Floating
ledges and props that react to blasts"). Trees, bushes and the backdrop are decor: never carved, and they collide
with nothing. The mesh
water strip that came with the map is replaced by the game's own stud water (the `Sea` liquid marker).

**Where.** In the place: `Workspace.Ume.ServerStorage_Assets/Arenas/PicnicPlains` (Terrain 318 parts in
`Island_1`–`3` and `Ledge_1`–`4`, left to right; Decor 68 in `Backdrop`, `Trees` (`Pine`, `Oak`, `Birch`),
`Bushes`, `Rocks`; Markers `Bounds` 281.6 × 114 × 11 at 0, 49, 0 and `Sea` with `Arena_Liquid = "Water"` from −8 to
6.6), moved into `SAssets.Arenas` at start. The Arena module now caches and
checks every template once at start (`_cacheTemplates()` in `Arena/Scripts/Server/Loader.lua`) instead of on each
load. The greybox, the map's mesh water and its unused `DropZone` marker are kept in `ServerStorage.!dump`.

**How to check.** Played on the Match map in Studio: the map loads with no warnings, the sea fills with stud water,
and the worms land on the islands and ledges.

**For the wiki.** Match modes & maps → Picnic Plains: its look and layout (islands, floating ledges, sea), replacing
the greybox description; Architecture's greybox note.

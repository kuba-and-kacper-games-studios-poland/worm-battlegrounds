---
title: "New map: Lakeside Showdown, a lake between two grassy banks, with lily pads"
date: 2026-11-13
status: open
kind: added
pages: ["Match modes & maps", "Lakeside Showdown", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** Lakeside Showdown (map id `LakesideShowdown`), one of the six planned maps, is built and in the
match rotation beside Picnic Plains, Desert, Rockslide Ridge and Volcano Isle, for 2, 4 and 6 snails. The owner
drew it as a reference picture: a lake between two grassy banks with trees, rocks and lily pads. It's 282 studs wide
and 114 tall, like Picnic Plains, the sea from Y −8 to 6.5. Left to right:
- one wide island standing on the sea, its outer ends sloping down into it, so the sea still knocks snails off at the
  sides;
- a raised, rolling grassy bank on each side (tops about Y 33) with an oak, a birch, a pine, rocks and bushes, down to
  a sandy beach at the lake (Y 22);
- the lake: a deep bowl in the middle, 78 studs across (x −39 to 39), its floor at Y 9 and its water up to Y 21, with
  steep walls and a sand bed. It's a pond: a snail with its head under loses 5 health a turn (never below 1), and
  only the sea knocks out, until sudden death's rising sea joins it;
- two lily pads floating on the lake (x −27 to −11 and 11 to 27): flat green leaves, one stud over the water on a
  darker stud under it, each a floating ledge (30 square studs) a snail can stand on, with a white water lily on it.
  A blast that splits a pad keeps its biggest piece floating and drops the rest.
The ground is grass over warm dirt, darker dirt deeper down, grey stones scattered through it, and dark bedrock under
Y 8. The backdrop is a teal forest treeline with low hills behind the lake.

For now it borrows Picnic Plains' mood (the `Plains` lighting preset, pollen and leaves in the air, glints on the
water) and music, and Picnic Plains' lobby card picture, until it has its own (`shortcut:` comments mark both).

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.LakesideShowdown` at X 2000 (slot 6),
made in MapLab (the game home's `assets/models/maps/lakeside_showdown/`, drawn by its `source/generate.py`, card
`asset.yaml`): 322 land parts (`Island_1`, `Ledge_1` and `Ledge_2` the pads), 54 backdrop parts, 16 props (2 oaks,
2 birches, 2 pines, 4 rocks, 4 bushes, 2 lilies). Two new land materials for the pads, `LilyPad` (3d8a3a) and
`DarkLilyPad` (2b6430), and a new prop, the water lily (`lily`, in `Decor/Flowers`, parts named `Flower`), in
map-kit 0.8.0. Markers `Sea` (`Water`, Y −8 to 6.5), `Lake` (`Water`, Y 9 to 21) and `Bounds` (282 × 114 × 11).
MatchBoard's `MAPS` row `LakesideShowdown` (it was there with no picture; now `Thumbnail` is Picnic Plains'
`rbxassetid://114380640476396`) and `MAP_POOL`. Atmosphere's `PROFILES.LakesideShowdown` (Picnic Plains' row).

**How to check.** A Studio bot match on it, 2026-11-13 (Match's `STUDIO_METADATA.MapId` and `Ume_StudioMapId`
"Match" for the test, then put back): it loads at X 0 with `Island_1`, `Ledge_1` and `Ledge_2`, 16 props and 18 water
blocks reaching Y 21 in the lake; four snails dropped on the banks (Y 28 to 34); the Plains lighting; no new warnings
in the Output. Not played to the end, and no shot was fired at the pads.

**For the wiki.** Match modes & maps: Lakeside Showdown is built and in rotation (sizes 2 · 4 · 6; "a lake between two
grassy banks; lily pads float on it"), in the built maps' list. A page of its own, Lakeside Showdown, like the other
maps': the banks, the lake as a pond, the lily pads as floating ledges. Architecture: the arena templates now run to
slot 6 (X 2000). Still to come: its own lobby card picture, mood and music.

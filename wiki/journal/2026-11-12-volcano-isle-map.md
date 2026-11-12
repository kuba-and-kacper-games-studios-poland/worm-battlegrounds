---
title: "New map: Volcano Isle, a volcano over a sea of neon lava"
date: 2026-11-12
status: open
kind: added
pages: ["Match modes & maps", "Volcano Isle", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
---

**What changed.** A new arena, Volcano Isle (map id `VolcanoIsle`), in the match rotation beside Picnic Plains,
Desert and Rockslide Ridge, for 2, 4 and 6 snails. The owner asked for a new map and suggested a volcano with a more
complicated layout and small passages. It isn't one of the six planned maps (Molten Spires, the planned lava map, is
rock pillars in lava): it's an extra one.

The layout, left to right, 282 studs wide like Picnic Plains:
- a rocky west islet standing on the lava, with a cave in its face toward the volcano, and a long basalt shelf floating
  over it (the upper storey);
- a small floating rock between the islet and the volcano;
- the volcano: a flat porch on each flank, a crater at the top holding a lava lake, and inside it a lava tube right
  through its base from porch to porch, through a magma chamber with a small lava pool; a cave at each of its feet.
  The tube has two mouths, so the whole cone over it is a floating ledge, like Rockslide Ridge's ceiling: a blast that
  splits it keeps its biggest piece up and drops the rest;
- an east islet with a cave and a shelf over it, like the west's.

The sea is lava, and all its lava glows: drawn in Neon, colour 255, 81, 58 (the owner: "change bottom water to lava,
so a lava rises not water, make lava part neon so it slightly glows"). Falling into the lava sea knocks a snail out
and sudden death raises it, as the sea does on every map. The crater lake and the chamber pool are ponds: a snail
with its head under loses 5 health a turn (never below 1), until the rising lava joins them in sudden death. Dead
trees, dry bushes, rocks and basalt columns stand on the tops; they break under blasts like the other maps' props.

Its mood: a new lighting preset, `Volcano` (the Desert's light, later in the day and through smoke: warm, reddish,
hazier), ash drifting in the air, lava bubbles and embers on the lava. Its music is the Desert's tracks for now (a
stand-in until the sound kit makes Volcano Isle's own). Its lobby card picture, the summit and crater down to the
chamber's pool, is uploaded (the owner approved it).

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.VolcanoIsle` at X 1200 (slot 4), made in
MapLab (`assets/models/maps/volcano_isle/`, its `generate.py`); 479 land parts in 3 islands and 4 ledges (the cone,
`Ledge_3`, 171), 57 backdrop parts, 17 props. Markers `Sea` (Y −8 to 6.5), `Crater` and `Chamber`, all `Lava` with
`Arena_LiquidColor` 255, 81, 58 and the new `Arena_LiquidNeon` (true), which Arena's `Liquid.lua` reads in `Build`
and applies in `_render` (`Material` Neon instead of SmoothPlastic with `2022 Small Stud`); a map without it draws its
liquid as before. MatchBoard's `MAPS` row `VolcanoIsle` (`Name` "Volcano Isle", `Sizes` 2, 4, 6, `Thumbnail`
`rbxassetid://110823072321769`, the image of decal 113926023651297 in The Snail Studio group) and `MAP_POOL`. Atmosphere's `PROFILES.VolcanoIsle` (`Preset` "Volcano", `Ambient_CaveDust` at rate 0.6, `Lava_Bubble`
and `Ember` surfaces, `Wind_OpenAir`). `Lighting.Presets.Volcano` in the place. SoundsList's `Music_VolcanoIsle` and
`Music_VolcanoIsle_SuddenDeath` (Desert's ids, with a `shortcut:` comment). The card picture is
`assets/ui/map_thumbnails/export/volcano_isle.png`.

**How to check.** Studio bot match on Volcano Isle, 2026-11-12 (Match's `STUDIO_METADATA.MapId` set to it, then put
back): it loads with 7 terrain groups and 13 Neon lava blocks reaching X 1009 to 1391 (the bounds were 1059 to 1341;
since `2026-11-12-maps-play-at-x0` it plays at X −141 to 141);
the client's lighting is the Volcano preset (ClockTime 16.4, brightness 2.7), `Music_VolcanoIsle` plays; snails
walked into the tube; no new warnings. On screen Neon with the preset's bloom shows the lava much lighter than its
colour (about 255, 180, 150).

**For the wiki.** Match modes & maps: Volcano Isle in the maps table (theme: a volcano over lava; sizes 2 · 4 · 6;
"a volcano with a lava tube through it and a crater lake; the lava sea glows"), and the built maps' list. A page of
its own, Volcano Isle, like the other maps' if they have one: the layout above, the tube and the floating cone, the
caves, which liquid knocks out and which only hurts. Architecture: the arena templates' slots (VolcanoIsle at
X 1200) and the liquid's `Arena_LiquidNeon`. The open question `desert-map` (on Match modes & maps) asks whether
Desert replaces Molten Spires; Volcano Isle is a second lava map beside it, worth naming there.

---
title: "Only Echo Caverns, Desert and Rolling Plains play; Echo Caverns is now a snowy mountain"
date: 2026-11-25
status: open
kind: changed
pages: ["Maps", "Echo Caverns", "Desert", "Rolling Plains", "Picnic Plains", "Volcano Isle", "Rockslide Ridge", "Mirage Mesa", "Lakeside Showdown", "Fluffy Fallout"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds.rbxl
---

**What changed.** Only three maps play while the maps are tested (the owner: "we are keeping only 3 maps in game for
now"): Echo Caverns, Desert and Rolling Plains are the whole rotation and the whole custom lobby list. Picnic Plains,
Volcano Isle, Rockslide Ridge, Mirage Mesa, Lakeside Showdown and Fluffy Fallout stay built but play nowhere; Training
Meadow is still the tutorial's map.

The three are the owner's newest builds, put into the arena templates as they were built (stud parts made
SmoothPlastic): Echo Caverns is no longer a cavern but an open snowy mountain with caves and root bands (192 studs
wide, land up to Y 90); Rolling Plains is a newer build of the same meadow with its arch; Desert is the same map. The
templates they replaced are in `ServerStorage.!dump.Arenas_before_2026-11-25`.

Each has the studio's biome effects (a `Vfx` folder): Rolling Plains has Picnic Plains' clouds and sun rays and
leaves falling from its four big oaks; Echo Caverns the clouds and sun rays; Desert the lava fire sheet over its lava.

Themes (Atmosphere moods): Desert keeps its own. Rolling Plains keeps Picnic Plains' mood and now its sky too. Echo
Caverns had Rockslide Ridge's dark cave mood, which closed in the sky; as a mountain it takes the meadow's bright
`Plains` light and a sky of its own (Mountains: a crisp alpine morning with far snowy peaks toward the sides), slow
drifting motes instead of cave dust, no grit from the ceiling, and keeps its own music, the howling wind and its
water's ripples.

**Where.** MatchBoard's `MAP_POOL` and `CUSTOM_MAP_POOL` (`{ "EchoCaverns", "Desert", "RollingPlains" }`);
Atmosphere's `RollingPlains` and `EchoCaverns` rows; Match's `STUDIO_METADATA` plays Rolling Plains (was Picnic
Plains, now out of rotation). The maps and their `Vfx` in `Workspace.Ume.ServerStorage_Assets.Arenas` (the place).

**How to check.** The lobby's cards and the custom lobby list only these three. Checked in Studio playtests on all
three: each loads with its sky and its effects running, no errors; on Echo Caverns Lighting's Sky `SkyboxFt` is
`rbxassetid://134775140145734`. The lobby cards still show Rolling Plains' and
Echo Caverns' old pictures (`MAPS` `Thumbnail`), which need new ones. The place isn't saved yet.

**For the wiki.** Maps: only these three in play for now. Echo Caverns' page: it's a snowy mountain now. The other
maps' pages: out of rotation for now.

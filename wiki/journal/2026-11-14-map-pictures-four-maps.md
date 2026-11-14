---
title: "Map pictures for Rolling Plains, Echo Caverns and Lakeside Showdown; a new one for Rockslide Ridge"
date: 2026-11-14
status: open
kind: added
pages: ["Lobby", "Rolling Plains", "Echo Caverns", "Lakeside Showdown", "Rockslide Ridge"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** The owner: "make images of the maps and upload them to roblox like we did with other". Rolling
Plains, Echo Caverns and Lakeside Showdown showed another map's picture on the lobby cards, the custom lobby's map
buttons and the teleport card (Picnic Plains' or Rockslide Ridge's); each now has its own. Rockslide Ridge's picture
showed its old build; it now shows the lava cave. Each is a zoomed-in landscape with no map edge in it, cut to the
card's slanted, rounded shape, as the others are:
- Rolling Plains: the left shoulder's big oaks, the picnic set, the pine and the rock arch against the hills;
- Echo Caverns: the dome's underside and stalactites over the rock columns, down to a strip of sea;
- Rockslide Ridge: the ceiling's stalactites over the floating slabs and pillars, a strip of glowing lava;
- Lakeside Showdown: the lake with its lily pads, both banks' trees and the floating islands' undersides.
Training Meadow, the tutorial's map, still shows Picnic Plains'.

**Where.** MatchBoard's `MAPS` → `Thumbnail`: `RollingPlains` `rbxassetid://118659936926806`, `EchoCaverns`
`rbxassetid://97183016065357`, `RockslideRidge` `rbxassetid://101364558522354` (was 123838177297909),
`LakesideShowdown` `rbxassetid://73998072466850`. Decals 106172600811858, 128681307391304, 78469107543000 and
112168649885270 ("Map Card <Map>"), owned by The Snail Studio group, all approved by moderation. The pictures, 1024 ×
272, are in the game home's `assets/ui/map_thumbnails/` (its `source/README.md` has the framing).

**How to check.** In Studio each id loads (`ContentProvider:PreloadAsync`: Success, 2026-11-14). Not yet seen on a
lobby card in a playtest.

**For the wiki.** Lobby: every map in the pool has its own picture now. Rolling Plains, Echo Caverns, Lakeside
Showdown, Rockslide Ridge: their infobox picture can be this one. Supersedes the "Picnic Plains' / Rockslide Ridge's
picture for now" lines in `2026-11-13-lakeside-showdown-map`, `2026-11-14-rolling-plains-map` and
`2026-11-14-echo-caverns-map`, and the Rockslide Ridge picture in `2026-11-09-map-pictures-on-lobby-cards`.

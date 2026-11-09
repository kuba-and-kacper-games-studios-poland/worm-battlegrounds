---
title: "The active lobby cards show a picture of their map (Picnic Plains, Desert, Rockslide Ridge)"
date: 2026-11-09
status: open
kind: added
pages: ["Lobby", "Picnic Plains", "Desert", "Rockslide Ridge"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** The owner asked for screenshots of the maps behind the ACTIVE LOBBIES cards. Each card now shows a
landscape picture of its map instead of the design's placeholder picture: zoomed in so no edge of the map shows,
framed high so Picnic Plains and the Desert show no sea or lava, and Rockslide Ridge shows the underside of its roof
and a strip of sea. Each picture is cut to the card's slanted, rounded shape, so nothing sticks out past its frame
(the first upload was a plain rectangle and did). The custom lobby's map buttons and the teleport card ("Heading to …") use the same pictures,
fitted inside their boxes. Maps not built yet (Fluffy Fallout, Lakeside Showdown, Molten Spires, The Big Mashup) have
no picture.

**Where.** MatchBoard's `MAPS` → `Thumbnail`: PicnicPlains `rbxassetid://114380640476396`, Desert
`rbxassetid://140014161821553`, RockslideRidge `rbxassetid://123838177297909`. The pictures (1024 × 272) and how they
were shot are in the game home's `assets/ui/map_thumbnails/`.

**How to check.** Play the Studio map: each lobby card's background is its map. Checked in Studio on 2026-11-09: all
three load.

**For the wiki.** Lobby: the cards show their map. Each map's page could use its picture as the page image.

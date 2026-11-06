---
title: "Islands' bedrock can be blasted through to the water"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Debris.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
---

**What changed.** The bottom layer of every island (the dark stone at the waterline, Y 4 to 8 on Picnic Plains and
Desert) used to be indestructible: blasts stopped at it, so there was always a floor under the worms. Now blasts cut
it like any other terrain, so a player can blast a hole through an island to the water (or lava), and a worm next
to the hole can fall in. A piece of bedrock still holds up the island above it while it reaches down to the map's
floor (the bottom of the lowest bedrock, Y 4 on both maps); a piece cut loose from it falls into the sea.

**Where.** `Carver.Carve` no longer skips `Arena_Indestructible` parts. `Loader.Load` notes the floor
(`Loader.GetFloor`), and `Debris._getGroup` counts a part as ground only when it has `Arena_Indestructible` and its
bottom is within `CONTACT_MARGIN` (0.15 studs) of the floor. The attribute keeps its old name; the maps are unchanged.

**How to check.** In a match, shoot the waterline next to a worm a few times: the crater opens to the water, water
flows in, and the worm drowns if it falls in. Islands still stand after a hole is cut through their bedrock.

**For the wiki.** Match modes & maps (and the maps' pages when they exist): the islands can be blasted down to the
water. Architecture's Arena section still says bedrock stays when a blast carves; it no longer does.

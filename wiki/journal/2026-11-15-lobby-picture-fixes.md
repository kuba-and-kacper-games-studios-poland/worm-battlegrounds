---
title: "Lobby and crate gui fixes: map pictures fit their cards and tiles, Desert and Fluffy Fallout pictures, NEW tag no longer cut"
date: 2026-11-15
status: open
kind: fixed
pages: ["Lobby", "Crates", "Fluffy Fallout", "Desert"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Result.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
---

**What changed.** The owner's list ("fix uis for now"):

- **Active lobby cards:** the map picture stuck out of the card's frame. It now covers the card's whole fill, stretched,
  so its slanted, rounded cut lines up with the frame, and still fades out to the right before Join.
- **Custom lobby map tiles:** the picture was a square-cornered box that ran under the map's name. Each map now
  has a tile picture of its own (`TileThumbnail` on MatchBoard's `MAPS` rows), cut to the tile's slanted shape, shown
  over the tile's whole fill under its outline and fading out toward the bottom behind the name (the owner: "they
  should take entire container within it's bounds, separate image, and add uigradient that fades that image to the
  bottom"). The nine tile pictures are uploaded to The Snail Studio group (image ids in `MAPS` → `TileThumbnail`:
  Picnic Plains 70528973496836, Desert 95484779686713, Fluffy Fallout 103570575490285, Rolling Plains
  119350227368156, Echo Caverns 113242205351682, Volcano Isle 72281204382629, Mirage Mesa 85483220004379, Lakeside
  Showdown 106543031741291, Rockslide Ridge 76070824844534).
- **Crate reveal:** the big card's NEW! tag was cut off at the top. The card's slot (`S_CardSlot`, a CanvasGroup that
  clips) is now a fifth bigger than the card, which sits centred in it at the same size as before.
- **Fluffy Fallout** has its lobby picture: image 70830416217312 (decal 104189335529280, The Snail Studio group),
  MatchBoard's `MAPS.FluffyFallout.Thumbnail`. **Desert** has its lobby picture too: image 83756913609980 (decal
  76929075876620), `MAPS.Desert.Thumbnail`.

**Where.** MatchBoard gui `PREFAB | Row` › `S_MapIcon`; CustomLobby gui `PREFAB | MapChoice` › `S_Icon`; Crates gui
`S_CardSlot` and Crates' `Result.ShowBig` (`CARD_SHARE`).

**How to check.** Lobby: Fluffy Fallout's, Desert's and Rolling Plains' cards show their picture inside the frame.
Custom: every map tile's picture fills the tile inside its outline and fades out toward the name (checked in a
playtest, 2026-11-15). A crate that gives a new piece shows NEW! whole.

**For the wiki.** Lobby: how the cards and the custom lobby's map tiles look. Fluffy Fallout: its picture.

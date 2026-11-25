---
title: "The lobby gets a brick backdrop on the loading card"
date: 2026-11-25
status: open
kind: added
pages: ["Lobby", "Loading screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Settings.lua
  - art/map_skies/parallax.py
---

**What changed.** The loading card's "Back to the lobby" scene showed only the lobby skybox's front face, an older
smooth-painted picture with a foggy lower half that looked like a placeholder (the owner). It now has backdrop layers
in the maps' brick look, like the map cards: snowy brick peaks over green foothills far back, Rolling Plains' voxel
clouds, and a brick meadow with oaks and pines up front, over the gradient sky Rolling Plains uses.

**Where.** Atmosphere's `PROFILES.Lobby.Parallax` (12 rows; the lobby itself never builds them, Mood shows no layers
there). Transition's `LOBBY_LOOK.Sky` and `Horizon` switch to that gradient sky (rbxassetid://99363908139132, 0.565),
changed by the loading-screen work. Picture ids: `art/map_skies/README.md`.

**How to check.** Leave a match: the "Back to the lobby" card shows the brick meadow and peaks, moving like the map
cards.

**For the wiki.** Loading screen: the lobby's card has its own scene too.

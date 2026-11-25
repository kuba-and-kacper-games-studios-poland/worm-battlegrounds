---
title: "Echo Caverns' clouds 110 studs higher and a little fainter"
date: 2026-11-25
status: open
kind: changed
pages: ["Echo Caverns"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Parallax.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Transition/Client.lua
---

**What changed.** On the snowy mountain map (Echo Caverns) the four voxel clouds behind the map sat at the peaks'
height. They now stand 110 studs higher (their `Bottom` 146/196/136/226 → 256/306/246/336: 70 at first, 40 more after the owner's "put them a bit higher") and are 20 % see-through
(the owner: "they are too low… a bit more subtle - but only a small tweak in transparency"). Parallax rows take an
optional `Transparency` for their picture since this change; the map and its loading card both draw it.

**Where.** Atmosphere's `PROFILES.EchoCaverns.Parallax` (the Clouds rows); `Parallax.lua` and Transition's scene
builder read `Transparency`.

**How to check.** In an Echo Caverns match the clouds float above the peaks at the top of the view, slightly faded.
Checked in Studio.

**For the wiki.** Echo Caverns: nothing a player reads; a History line at most.

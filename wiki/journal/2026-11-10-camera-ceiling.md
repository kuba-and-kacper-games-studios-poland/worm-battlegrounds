---
title: "The match camera may rise 40 studs above the map, and follows a shot up any height"
date: 2026-11-10
status: open
kind: changed
pages: ["Controls & platforms", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/_meta/README.md
---

**What changed.** The camera used to stop where the top of the view met the top of the map's play area, so a snail
standing high up (on Rockslide Ridge's overhead ridge, or flying its jetpack) sat near the top of the screen. Now the
view may rise up to 40 studs above the map's top, so that snail is centred. While the camera follows a shot in flight
there's no ceiling at all: a high lob stays in view all the way up. The sides and the bottom still stop at the map's
edges.

**Where.** New MatchCamera setting `CEILING_EXTRA` = 40 (studs above the `Bounds` marker's top).
`Module._getClamped(point, bounds, camera, ceiling)` raises the bounds' top by `ceiling`; `Module._update` passes
`math.huge` while the target is a flying shot (a `BasePart`, and not holding on a blast), else `CEILING_EXTRA`.

**How to check.** On Rockslide Ridge, play a turn on the overhead ridge (Y 68 to 96): your snail is near the middle
of the screen, not at its top edge. Lob a Grenade steeply at full power with "Camera follows shot" on: the camera
rises with it past the map's top. Not checked in Studio by the docs pass.

**For the wiki.** Controls & platforms (the camera): it can look above the map to keep a high snail centred, and
follows a shot as high as it goes.

---
title: "Match camera zooms with the mouse wheel and a pinch (45 to 200 studs)"
date: 2026-11-05
status: open
kind: added
pages: ["Controls & platforms", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.** In a match, the mouse wheel zooms the camera in and out on what it follows (the active worm, or
a shot in flight), and on touch screens two fingers pinch to zoom out and spread to zoom in. The zoom stays for the
rest of the match. Before, the camera sat at one fixed distance.

**Where.** MatchCamera's `Client.lua`: `_zoomTo`, the wheel in `InputChanged` (skipped while a gui scrolls), and
`TouchPinch`. Settings: `DISTANCE` 110 (the start), `ZOOM_MIN` 45, `ZOOM_MAX` 200 (studs from the plane),
`ZOOM_STEP` 0.15 (each wheel notch changes the distance by 15 % of itself), `ZOOM_SPEED` 10 (easing).

**How to check.** In a match, two wheel notches in take the camera from 110 to about 79.5 studs (checked in a
Studio playtest). The pinch wasn't tried: Studio's playtest has no touch.

**For the wiki.** Controls & platforms: zoom with the mouse wheel, pinch on touch (gamepads have no zoom yet).

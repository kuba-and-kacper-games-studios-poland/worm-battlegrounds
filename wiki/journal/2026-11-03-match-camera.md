---
title: "Match camera: side-on, FOV 30 from 110 studs, follows the worm and pans"
date: 2026-11-03
status: merged
merged: 2026-11-06
kind: added
pages: ["Match modules", "Controls & platforms", "Roadmap"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/
---

**What changed.** The `MatchCamera` module exists (client). Once a map is loaded the camera is scriptable, looks along
−Z from 110 studs (`DISTANCE`) with a field of view of 30 (`FOV`), and stays inside the Bounds marker. It follows the
worm with an `Active` attribute, else the local player's worm, else the arena's middle, catching up at
`FOLLOW_SPEED` 6. Players pan by dragging with the right mouse button, with two fingers on touch, or with the right
stick while LT is held (60 studs/s at full lean, `STICK_PAN_SPEED`); the pan resets when the camera follows another
worm. It locks `FOV_Controller` while it runs.

Not built: following the shot and its explosion (needs Combat), the `CameraFollowsShot` setting, panning at the
screen's edge, and zooming out to fit wide maps like The Big Mashup.

**Where.** `MatchCamera/Client.lua`; numbers in `MatchCamera/Settings.lua`. No remotes, Topics or saved data.

**How to check.** In a Studio test the camera faces the arena square on, follows the worm while it walks, and a
200-pixel right-drag moved the view 10.92 studs (checked in Studio on 2026-11-03).

**For the wiki.** Match modules → MatchCamera: what's built, `DISTANCE` 110, and what waits for Combat. Controls &
platforms: the pan inputs. Still unsure: touch and gamepad panning weren't tested.

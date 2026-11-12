---
title: "Match camera: every turn starts on its snail, high shots near the top, a zoom that breathes"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.** Three asks from the owner, on 2026-11-12:

- **Every turn starts on its snail, always.** "Always at the start of turn move the camera towards the one that is
  playing", then "move the camera even if player is moving it by himself, force it". When a turn starts (Match's
  `Match_TurnStarted`) the camera drops the blast it held, the view the player moved by hand and their pan, and glides
  to the active snail at `TRAVEL_SPEED` (1.6). While it glides, the player's hand (a drag, a finger, the stick, the
  screen's edge) moves nothing, until the view gets there or `TRAVEL_MAX` (2.5 s) runs out. Then the hand is free
  again. A view moved by hand also stays while the player keeps holding the pan (the right mouse button, a finger, LT),
  not only 5 s after the last move (`MANUAL_HOLD`).
- **High shots ride near the top of the screen.** A shot in flight climbs to 0.7 of the view's half height over the
  middle (`SHOT_TOP`) before the view rises with it, from the height the view had at take-off, so the map stays in
  view under a high lob. The view zooms out to fit both, up to 1.5 times the player's zoom (`SHOT_ZOOM_OUT`, never past
  `ZOOM_MAX`), and back in as the shot comes down.
- **A zoom that breathes.** Gliding to the next snail, the view zooms out by up to 0.2 of the player's zoom
  (`TRAVEL_ZOOM_OUT`, the full amount from 80 studs away, `TRAVEL_ZOOM_DISTANCE`) and back in as it arrives. A blast
  the camera follows pushes the view in by 0.06 of the zoom (`BLAST_KICK`; 0.12 for a blast of 6 studs or more,
  `BIG_BLAST_KICK`), easing back over 0.6 s (`BLAST_KICK_SECONDS`).

Supersedes part of 2026-11-12-camera-calmer: a view moved by hand no longer stays into the next turn. The rest of that
entry still holds.

**Where.** `_onTurnStarted`, `turnGlideUntil` (cleared when the view reaches the `Active` snail), `_addPan`, and the
zoom's `breath` and `shotFloor` in `_update`, all in `MatchCamera/Client.lua`; the settings above in its `Settings.lua`.

**How to check.** Studio bot match, 2026-11-12, with the right mouse button held and dragged back and forth across four
turn starts. Each time the view went to the active snail, or to the arena's edge clamp for a snail near the edge
(137 studs away → 1.3 within 3.3 s). Earlier the same day: a high lob zoomed the view out to about 192 studs while the
shot sat at about 0.68 of the half height over the middle.

**For the wiki.** Match screen, the camera: each turn starts on its snail; high shots show near the top with the map
under them; the zoom moves with the action. Controls & platforms: panning during the turn's first moments waits for the
camera to arrive.

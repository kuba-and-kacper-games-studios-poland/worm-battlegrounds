---
title: "Drop: place your worm anywhere it fits; the timer ends once everyone placed"
date: 2026-11-05
status: open
kind: changed
pages: ["Match modes & maps", "Match screen", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/DropPicker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
---

**What changed.** At the start of a match, a player used to slide their landing spot left and right along one line
at the top of the map, and the drop always lasted the full 15 seconds. Now they place it anywhere on the screen
inside the play area where a worm fits: not inside terrain (walls, ground) and not in water or lava. The marker
follows the mouse (or the left stick on a gamepad) and is faded where the worm doesn't fit; a left click, a tap or the
gamepad's A places it, and clicking again moves it while the drop lasts. Others see a player's marker faded until they
place it. The drop ends as soon as every connected player has placed (bots always have); otherwise after 15 seconds.
Bots, and players who don't place theirs, now start standing on land: a random spot on top of the ground (never over
water, never on a steep slope), at least 16 studs apart while there's room. They used to parachute in from 70 studs
up, spread along the whole width, so some fell into the sea. Only a worm whose player placed its spot parachutes
from there.

**Where.** `_drop()`, `PickDrop()` and `_isEveryonePlaced()` in `Match/Scripts/Server/Phases.lua`; the remote
`Match_PickDrop @ (player, x: number, y: number)` (was `x` only), fired by the client in `DropPicker.lua` on a click,
tap or A press. The server keeps a spot only where `I.Arena.IsFree(position, ROOT_SIZE / 2)` says a worm fits
(`Arena/Server.lua`: inside `Markers.Bounds`, out of liquid, touching no terrain). The start spots come from
`I.Arena.GetLandSpots(count, radius)`: a ray down every `LAND_SPOT_STEP` (2) studs, ground flat enough
(`LAND_SPOT_MIN_NORMAL` 0.7), kept `LAND_SPOT_GAP` (16) studs apart. The `DropZone` marker and `I.Arena.GetDropZone`
are gone. Attributes: the match folder's
`DropMinX`, `DropMaxX`, `DropMinY`, `DropMaxY` (the bounds; `DropY` is gone) and `DropEndsAt` (set to now when
everyone placed early); each participant entry's `DropX`, `DropY` and `Placed`. `DROP_SECONDS` stays 15.

**How to check.** Played on the Match map in Studio (`Ume_StudioMapId = "Match"`, one player and three bots):
clicking on an island's rock left `Placed` false and the marker faded (pin `ImageTransparency` 0.6) under the
cursor; clicking in the sky placed it (`Placed` true, `DropX` 5.5, `DropY` 54.9), the drop ended at that click
(8.5 s in, not 15), and the worm parachuted down from there onto the island. Without placing, the three bots and the player started
standing on islands and ledges (at x −97.5, −51.5, −21.5, 120.5), didn't move, and the first turn began 1.4 s
after the drop. Touch taps and the gamepad weren't
tried. The match camera shows about 118 × 59 studs of the arena at once, so spots off screen need a right-drag pan
first.

**For the wiki.** Match modes & maps (the drop) and Match screen (the drop panel): place your worm anywhere it fits,
and the drop ends when everyone has placed. The drop panel still says "Pick where to land"; it could say "Click where
to land" ("Tap" on phones).

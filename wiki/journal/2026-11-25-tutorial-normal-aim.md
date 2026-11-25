---
title: "The tutorial aims with the normal preview dots, no whole path line"
date: 2026-11-25
status: open
kind: changed
pages: ["Tutorial", "Aiming"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The tutorial match no longer shows the whole path of an arced shot (the gold dotted line to a red
mark where it lands, since the testers' 2026-11-15 notes). It shows the same aim as every match: the 9 preview dots
from the snail in the power's colour over a fifth of a full-power flight, no wind (the owner: "so player is not
confused that he has it here and does not have it in the main game"). The admin aimbot still shows the whole path.

**Where.** MatchHud's `Aim.lua`: `_drawPrediction` draws only for a player with the `Aimbot` attribute, and
`_drawPreview` no longer skips the tutorial. `PREDICTION_*` settings now serve the aimbot alone.

**How to check.** Play the tutorial (Workspace `StudioTutorial` on, the profile's Tutorial flags reset): aiming the
Bazooka shows the nine dots, no line to the landing. Not run in the tutorial itself; the same dots were checked in a
normal Studio match.

**For the wiki.** Tutorial: no prediction line; the player aims as in any match. Supersedes the tutorial part of the
prediction line (2026-11-15) and of 2026-11-25-aim-preview-back's "the tutorial still shows the whole path".

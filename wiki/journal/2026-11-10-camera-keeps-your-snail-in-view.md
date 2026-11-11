---
title: "The match camera keeps your snail in view, and moves once after a blast"
date: 2026-11-10
status: open
kind: changed
pages: ["Controls & platforms", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.**

- **Your turn:** the pan can no longer leave your own snail off the screen. It stays within 70% of the view's half
  size from the middle, and while the snail moves (faster than 3 studs a second) the view eases back onto it.
- **After a blast** (with "Camera follows shot" on): the camera stays on the blast until the next turn starts, and
  for at least the hold it had before (1.5 s, 2.5 s for a big blast), then moves once, to the next snail. Before, it
  moved on after the hold, sometimes to a snail and then again to the next one.
- **While a shot flies** it stays on that shot, instead of hopping between a Cluster bomb's bomblets.
- **Between turns** it stays on the snail it last followed, instead of swinging over to your own snail and back.

**Where.** New MatchCamera settings `LEASH` 0.7, `RECENTER_SPEED` 2.5 and `RECENTER_MOVE_SPEED` 3, used in
`Module._update` while `I.Match.IsMyTurn()`. The hold: `blastHeld` set in `Module._onExplosion`, cleared by
`Module._onTurnStarted` (Match's client Topic `Match_TurnStarted`). `BLAST_HOLD`, `BIG_BLAST_HOLD` and
`BIG_BLAST_RADIUS` are unchanged (1.5, 2.5, 6) and now the least hold. `Module._getTarget` keeps the followed shot or
snail. Supersedes the "before it moves to the next snail" part of `2026-11-09-camera-holds-on-blasts`.

**How to check.** On your turn, pan far away with the right mouse button and walk: the view slides back to your
snail. Fire a Cluster bomb with "Camera follows shot" on: the camera stays on one piece, then on the blast until the
next turn's snail is shown. Not checked in Studio by the docs pass.

**For the wiki.** Controls & platforms (the camera): your own snail never leaves the screen on your turn; after a blast
the camera waits for the next turn.

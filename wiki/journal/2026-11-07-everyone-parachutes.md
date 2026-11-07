---
title: "Every snail parachutes in at the drop, bots and unplaced players from over land"
date: 2026-11-07
status: open
kind: changed
pages: ["Match modes & maps", "Match screen", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** Back to the studio's wiki ("Then the worms fall onto the map with parachutes"). Before: only a
player who placed their spot parachuted; bots and players who didn't place started standing on the ground. Now every
snail parachutes in: a placed one from its spot, the others from up to 20 studs over a random spot of land (lower where
a floating ledge or the top of the play area is in the way), so their markers show in the sky during the drop too.

**Where.** `Module._getSkySpot` in `Match/Scripts/Server/Phases.lua`; `_land` applies `Parachute` to every snail.
`DROP_HEIGHT` 20 in Match's Settings. Spots still come from `I.Arena.GetLandSpots`.

**How to check.** Start a match with bots and don't place: every snail, yours too, floats down by parachute.
Checked 2026-11-07 in a Studio match (one player, three bots, the player didn't place): every drop spot was in the sky over land, and all 4 snails had `Parachute` set during the landing.

**For the wiki.** Match modes & maps → Starting a match → The landing: every snail parachutes in.

Supersedes the landing part of 2026-11-05-drop-anywhere; placing anywhere a snail fits still holds.

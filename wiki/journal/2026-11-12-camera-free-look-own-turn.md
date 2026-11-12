---
title: "Your own turn: the camera pans anywhere, at any zoom"
date: 2026-11-12
status: open
kind: changed
pages: ["Controls & platforms", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.** The owner: zoomed in, the view couldn't be moved down to see the map's bottom. On the player's own
turn the pan was leashed: their snail had to stay within 70 % of half the view's height from the middle, so the
closer the zoom, the shorter the leash (about 8 studs at the closest zoom, 37 at the farthest). The leash is gone: on
their own turn the player drags the view anywhere in the arena at any zoom, and while their snail moves (faster than
3 studs a second) the view still eases back onto it. Their snail can now be off the screen while they look around.
The arena's edges still limit the view, as before, by the zoom.

**Where.** `MatchCamera`: the leash block in `Module._update` (Client.lua) is now only the recentre while the snail
moves; the `LEASH` setting (0.7) is removed; `RECENTER_SPEED` 2.5 and `RECENTER_MOVE_SPEED` 3 are unchanged.
Supersedes the "Your turn" part of `2026-11-10-camera-keeps-your-snail-in-view`; the rest of that entry (the blast
hold, staying on one shot, between turns) still holds.

**How to check.** Studio bot match on Picnic Plains, 2026-11-12: zoomed fully in (45 studs) on the player's turn, a
right-drag took the view down to the bounds' bottom (Y −8), 20 studs under the snail; before, it stopped about 8
studs under it.

**For the wiki.** Controls & platforms (the camera): on your turn you can look anywhere; walking brings the view back
to your snail. Remove "your own snail never leaves the screen on your turn" if the 2026-11-10 entry was merged.

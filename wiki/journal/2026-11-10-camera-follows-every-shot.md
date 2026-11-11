---
title: "The match camera follows every shot to its end, and glides to the next snail"
date: 2026-11-10
status: open
kind: fixed
pages: ["Match screen", "Camera", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.**

- **Shots are followed again.** A bug kept the camera from following a flying shot: it slid to the arena's middle
  instead (a ceiling of `math.huge` turned the bounds' width into NaN). Now it flies with the shot, a little ahead of
  it (`LEAD_SECONDS` 0.35, at most 18 studs), on every screen with Camera follows shot on.
- **Guns and swings** (Uzi, Minigun, Shotgun, the bat, One Punch) have no flying part, so the camera now glides to
  the middle of where their bullets or swing landed and stays there until the next turn starts (at least 1 s).
- **Snails sent flying are followed:** while the camera holds after a shot, a snail moving faster than 25 studs a
  second (knocked back, or falling after the ground under it went) is followed until it slows, plus 0.6 s.
- **A shot that ends with no blast** (it sank) holds the camera where it ended for at least 1 s.
- **The move to the next snail glides** (`TRAVEL_SPEED` 2.5 for at most 1.5 s, instead of the follow speed 6), so it
  reads as a move instead of a jump.
- **Panning near an edge:** the view's push at the arena's edge no longer builds up as if the player had panned, so
  the camera no longer stays off to one side after a shot near an edge.

**Where.** MatchCamera `Client.lua`: `_update` (the pan measured from `base`, the chase, the vanished shot),
`_onTracer` (listens to Combat's `Combat_Tracer`), `_hold`, `_getFlyingSnail`, `_getClamped`. Settings:
`TRAVEL_SPEED`, `TRAVEL_MAX`, `TRAVEL_DONE`, `CHASE_SPEED`, `CHASE_HOLD`.

**How to check.** In a solo match the camera stays near the rocket as it flies (checked on Rockslide Ridge: 5 to 10
studs ahead of it), settles on the blast, then glides to the next snail. A gun's turn moves the view to where the
bullets hit.

**For the wiki.** The match screen / camera page: what the camera shows during a turn, a shot, and between turns, and
that the Camera follows shot setting turns the shot follow off.

**Unsure.** The gun and swing glide and the chase of a flying snail weren't seen in a playtest (the bots fired only
the Bazooka there); they follow the same hold as blasts.

---
title: "The match camera stays on a blast 1.5 s (2.5 s for big ones) before moving on"
date: 2026-11-09
status: open
kind: changed
pages: ["Controls & platforms", "Settings"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.** The owner found the camera moved on too fast after a shot exploded. With the "Camera follows
shot" setting on, the camera now stays on the blast for 1.5 seconds, or 2.5 seconds for a blast of radius 6 studs
or more (the Bazooka's, for example), before it moves to the next snail. A shot that flies meanwhile (a cluster's
pieces) still takes the camera at once, and the player can still pan and zoom during the hold. With the setting off,
nothing changes: the camera stays on the snail.

**Where.** MatchCamera's new settings `BLAST_HOLD = 1.5`, `BIG_BLAST_HOLD = 2.5` and `BIG_BLAST_RADIUS = 6`.
`Module._onExplosion` in `MatchCamera/Client.lua` listens to Combat's `Combat_Explosion` remote and keeps the blast's
point and when the hold ends; `Module._update` centres on that point until then.

**How to check.** Play a match against bots with "Camera follows shot" on: after a Bazooka blast the camera stays
still on it for about 2.5 s, then glides to the next snail. Checked in Studio on 2026-11-09: the camera held until
2.4 s after the shot ended, with no errors.

**For the wiki.** Controls & platforms (the camera), or the Settings page's "Camera follows shot": after a blast the
camera lingers on it, longer for big blasts.

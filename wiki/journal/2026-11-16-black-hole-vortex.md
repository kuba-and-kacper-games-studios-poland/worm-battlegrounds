---
title: "Black hole: pulls harder (speed 10 → 16, radius 20 → 24), smooth on every screen, a vortex and sounds"
date: 2026-11-16
status: open
kind: changed
pages: ["Black hole grenade", "Weapons"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/BlackHoleGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Roller.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Vortex.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Drag.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Helpers/Drag.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Drag.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.** An open black hole draws snails in faster, 16 studs a second (was 10), from 24 studs (was 20). A
snail it pulls through the air now moves smoothly on every player's screen (before, it stepped along on everyone's but
the server's). Steps and ledges no longer stop the pull: a snail slides along the ground only toward a hole about level
with it (less than 4 studs above) and while nothing holds it back; a hole higher up, or a step or wall that stops its
slide, lifts it and draws it straight in through the air (before, a snail under a hole opened above a ledge stayed
where it was). The open hole shows a vortex: three arms of its trail orbit it, closing in and spinning faster until it
bursts, and it sounds an opening whomp, a hum while open, a collapse just before the burst, and a burst.

**Where.** `PullRadius` 24 on the row; Combat's `BLACK_HOLE_DRAG_SPEED` 16. The drift is written on the snail as
attributes (`DragFrom`, `DragTo`, `DragSpeed`, `DragReach`, `DragEase`, `DragStart`; Snails' `DRAG_EASE` 0.35 s ease
in; `DRAG_SLIDE_MAX_RISE` 4 studs, `DRAG_SLIDE_STUCK` 0.25 of the drag speed), turned into a position by `Snails/Scripts/Helpers/Drag.lua` and drawn by the client `Drag` handler. The server
fires the new RemoteEvent `Combat_HoleOpened(center, seconds)` to everyone; the client `Vortex` handler draws it:
`VORTEX_TRAIL` `Trail_BlackHole`, `VORTEX_ARMS` 3, `VORTEX_RADIUS` 7 to `VORTEX_END_RADIUS` 0.6, `VORTEX_SPIN` 1.2 turns
a second plus `VORTEX_SPIN_GROWTH` 1.4 a second, `VORTEX_COLLAPSE` 0.9 s; sounds `BlackHole_Open`, `BlackHole_Hum`,
`BlackHole_Collapse`, `BlackHole_Burst` (the sound kit's own, uploaded the same day: see 2026-11-16-weapon-sounds).

**How to check.** In a two-player test, open a black hole over the other snail: on both screens it drifts in
smoothly, the vortex spins in, and the burst lets it drop. Not checked across two clients here. Checked in a Studio
test by calling `I.Snails.Drag` on a bot: a point 14 studs up drifted it in and held it (1.2 s), flat ground slid it
at 16 studs/s, and a 2-stud step in its way switched it to the drift, which reached the point in about 1 s.

**For the wiki.** Black hole grenade: the pull radius and speed in its stats, and what an open hole looks and sounds
like.

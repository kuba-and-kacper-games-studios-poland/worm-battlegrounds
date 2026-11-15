---
title: "Shots, thrown snails and falling ground drawn on a steady clock; snail tags redraw only when they change"
date: 2026-11-15
status: open
kind: fixed
pages: ["Architecture", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Falling.lua
---

**What changed.** The owner on the dev servers: rockets "sometimes stop for few frames mid-air", and a hit snail's
health bar stutters while it moves.

- Every client drew shots (Combat's `Shots`), thrown snails (Snails' `Flight`) and falling ground (Arena's `Falling`)
  from `Workspace:GetServerTimeNow()` each frame. A live client's estimate of the server's clock gets corrected now and
  then; a correction backwards holds everything drawn on it still until the clock catches up. They now draw on
  `I.Match.GetDrawTime()` (Match's client), which runs at the local clock's rate and eases toward the server's clock
  over `DRAW_CLOCK_EASE` (1 s), jumping only when `DRAW_CLOCK_SNAP` (0.5 s) off.
- A snail's tag (`SnailTag`) redrew its whole health bar, a new gradient each time, on every attribute of its snail,
  and the server rewrites `Stamina` all the time while a snail walks. It now redraws only on what it shows
  (`TAG_ATTRIBUTES`: `Health`, `MaxHealth`, `Color`, `Active`, `Ghost`).

**Where.** `Module.GetDrawTime` in `Match/Client.lua` (on `I.Match`, client only), its settings in `Match/Settings.lua`;
`_onShot` and `_step` in `Combat/Scripts/Client/Shots.lua`; `_step` in `Snails/Scripts/Client/Flight.lua`; the fall
loop in `Arena/Scripts/Client/Falling.lua`; `TAG_ATTRIBUTES` and `_addTag` in `Snails/Scripts/Client/Tags.lua`.

**How to check.** On a live server, rockets fly without pausing and a thrown or walking snail's tag follows it
smoothly. Studio can't show the clock's corrections (no network): there five Bazooka shots drew with no still frame.
Still unsure: the clock is the likely cause from the code, not measured live; if a rocket still pauses there, the next
suspect is the shot's copy hitting something only that client has, then waiting for the server's correction.

**For the wiki.** Architecture: the client's drawing clock (`I.Match.GetDrawTime`) beside the shot simulation and
flights. Nothing players read beyond smoother motion.

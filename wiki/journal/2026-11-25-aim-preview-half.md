---
title: "Aim preview dots half as long (9 → 5 dots, 0.2 → 0.1 of a flight)"
date: 2026-11-25
status: open
kind: changed
pages: ["Aiming"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The dotted preview of an arced shot (and now of a homing missile's launch) covers half as much of
the path: `PREVIEW_SHARE` 0.2 → 0.1 of a full-power shot's flight time, with `PREVIEW_DOTS` 9 → 5 so the dots keep
their spacing (the owner: "make the dots on aiming shorter a bit (like in half)").

**Where.** MatchHud's `Settings.lua` (Aiming: `PREVIEW_DOTS`, `PREVIEW_SHARE`).

**How to check.** Aim a bazooka: five dots, reaching about half as far as before.

**For the wiki.** Aiming: the preview shows only the first stretch of the path (a tenth of a full-power flight). The
2026-11-24 aim entries still hold apart from the length.

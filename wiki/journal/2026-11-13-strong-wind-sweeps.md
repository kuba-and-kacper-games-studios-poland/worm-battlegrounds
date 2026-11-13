---
title: "Strong wind sweeps steep shots back: wind's push grows with its strength (wind 6: 42 → 96 studs/s²)"
date: 2026-11-13
status: open
kind: changed
pages: ["Wind", "Weapons", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Global.lua
---

**What changed.** The wind's push on a shot was `wind × WIND_ACCEL` (7) studs/s², the same per point at any strength.
Now each point pushes harder the stronger the wind: `wind × (WIND_ACCEL + WIND_ACCEL_GROWTH × |wind|)`, with
`WIND_ACCEL` 7 and the new `WIND_ACCEL_GROWTH` 1.5.

| Wind | Push before | Push now | Swept back if steeper than (before → now) | A 45° full shot's drift (before → now) |
| --- | --- | --- | --- | --- |
| 1 | 7 | 8.5 | 88° → 87.5° | 6 → 7 studs |
| 3 | 21 | 34.5 | 84° → 80° | 18 → 29 studs |
| 6 | 42 | 96 | 78° → 64° | 35 → 81 studs |
| 8 | 56 | 152 | 74° → 52° | 47 → 128 studs |
| 10 | 70 | 220 | 70° → 42° | 59 → 185 studs |

"Swept back" means a full-power shot aimed up into the wind lands behind the shooter, back on the wind's side, when
it comes down at the height it left. For example, at wind 6 a full shot at 70° into the wind used to land 44 studs out
on the side it was aimed at; now it lands about 37 studs on the other side. Gravity is 196.2, so from wind 10 the wind
pushes harder than gravity pulls. Worked out from the flight formula, not yet seen in a match.

**Where.** Combat's `GetWindAcceleration` (Global.lua) and `WIND_ACCEL_GROWTH` in its Settings. Everything that
flies or predicts a shot reads that function (the Bouncer, Rocket, Roller and Homing behaviours, the aim guide and the
bots' brain and predictions), so bots aim with the new wind. Their trained genomes weren't retrained for it.

**How to check.** In a match at wind 6 (`I.Match.SetWind(6)` on the server, for testing), fire the Bazooka at full power nearly straight up,
a little into the wind: it comes down on the far side of the shooter. A shot at about 45° lands about 80 studs short.

**For the wiki.** Wind: the push table and the swept-back angles. Weapons: wind matters far more for steep shots.
Supersedes the wind part of `2026-11-13-rocket-weight-wind` (the push per point, 7, still holds as the base).

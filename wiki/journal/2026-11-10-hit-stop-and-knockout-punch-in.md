---
title: "Big hits stop the world for a beat (0.07 s, 0.16 s on a knockout), the camera punches in on knockouts, damage numbers grow with the hit"
date: 2026-11-10
status: open
kind: added
pages: ["Match screen", "Controls & platforms", "Match modules", "Data & networking"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.**

- **Hit stop:** a hit of 30 damage or more freezes the blast for 0.07 s on every screen: the effects' particles
  stop, the thrown chunks of ground hang in the air, and the camera holds still. Then everything goes on as it was. A
  stop already running isn't made longer by another hit. The shot simulation and the server never stop.
- **Knockout punch-in:** a blow that knocks a snail out (its health from above 0 to 0) stops it for 0.16 s, whatever
  the damage, and the camera moves to the snail and zooms in to 65% of the player's zoom for 0.9 s, then goes back.
- **Damage numbers by size:** under 25 damage the number is white at its normal size; from 25 it's yellow
  (255, 220, 60) and 1.3 times as big; from 45 orange (255, 120, 40) and 1.65 times. Numbers from 25 up punch in from
  1.5 times that size in 0.18 s.

**Where.** Server: `Blast.Hit` (Combat) fires `Combat_Hit` with a new 4th argument, `knockout: boolean` (`Health`
was above 0 before the hit and is 0 after). Client: `Effects._onHit` calls `Effects._hitStop(seconds)`, which sets
`TimeScale` 0 on every ParticleEmitter in `Workspace.Ume.Combat` and anchors its unanchored `Debris` parts (keeping
their velocity), calls `I.MatchCamera.Freeze(seconds)`, and puts them back after. New Combat settings
`HITSTOP_DAMAGE` 30, `HITSTOP_SECONDS` 0.07, `HITSTOP_KNOCKOUT` 0.16. New client API on MatchCamera (set in `Init`):
`I.MatchCamera.Freeze(seconds)` and `I.MatchCamera.PunchIn(point)`; new MatchCamera settings `PUNCH_ZOOM` 0.65 and
`PUNCH_SECONDS` 0.9. Snails: `Tags._popDamage` picks the last `POP_TIERS` row the damage reaches (rows: from damage,
size multiplier, colour: `{0, 1, white}`, `{25, 1.3, (255, 220, 60)}`, `{45, 1.65, (255, 120, 40)}`); new settings
`POP_TIERS`, `POP_PUNCH` 1.5, `POP_PUNCH_TWEENINFO` (0.18 s Back Out).

**How to check.** In a Studio match, hit a bot with a Bazooka (35 at the middle): the blast hitches for a moment and
the number is yellow. Knock a bot out with hits (`snails kill` isn't a blow, so it doesn't count): a longer hitch and the camera closes in on
it. A Grenade's splash edge (under 25) pops a white number with no hitch. Not checked in Studio by the docs pass.
Unsure: particles played outside `Workspace.Ume.Combat` (Snails' effects) don't freeze.

**For the wiki.** Match screen: the hit stop, the knockout punch-in and the damage number colours and sizes (a small
table: 0, 25, 45). Data & networking: `Combat_Hit`'s new `knockout` argument. Match modules: MatchCamera's new API.

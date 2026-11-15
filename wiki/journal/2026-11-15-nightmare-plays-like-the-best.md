---
title: "Nightmare bots: steadier hand, black holes opened mid-air, a turn ahead, habits, the next player, spear and One Punch"
date: 2026-11-15
status: open
kind: changed
pages: ["Match modules", "Bots", "Custom lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/_meta/_types.lua
---

**What changed.** The owner: "make the nightmare bots even more op", then picked four of the ideas proposed for it.
Nightmare (the secret difficulty, custom lobbies only) now:

- **Shakes less and looks wider** (`SKILLS.Nightmare`): `AimNoise` 0.5° → 0.25°, `PowerNoise` 0.008 → 0.004,
  `Ranging` 0.6 → 0.5, `RangingMin` 0.15 → 0.1, `Spots` 14 → 18, `Finalists` 24 → 36, `AirShots` 6 → 8, `Hunt`
  0.5 → 0.75, `StartNoise` 0.15 → 0.1.
- **Checks its shots hold a hair off** (`Sure` 6; Hard has 2): its 6 best plans are flown again one `AimNoise` and
  one `PowerNoise` off each way, scored by the mean of five flights.
- **Opens the black hole in the air** (`AirPops` 3): it aims black holes at points `AIR_POP_HEIGHTS` (8, 14) studs
  over the target and over the middle of the target and its nearest enemy, and presses again (`I.Combat.Detonate`)
  when the flight gets there (the shot's `OpenStep`, within `AIR_POP_REACH` 4): the snails are pulled up into it,
  take the blast and fall.
- **Thinks a turn ahead** (`Lookahead` 1): each of its best plans also counts its own best Bazooka shot next turn
  from where it ends up, less what the enemies can do back to it there (the next to play fully, the others
  `LOOK_OTHERS` 0.5).
- **Remembers habits** (`Memory` 1): every snail's damage a turn and how far it walks this match (`Bots_Habit`, from
  `Match_TurnStarted`, `Combat_ShotFired` and `Combat_ShotResolved`; one not seen yet: `HABIT_DAMAGE` 25,
  `HABIT_MOVE` 8). Heavy hitters are targeted first, and their reply is counted from as far as they walk.
- **Goes for the next player** (`Tempo` 1): the enemy whose turn is next (Match's `TurnOrder`) ranks nearer as a
  target, and hurting or knocking it out counts more (a knockout takes its turn away).
- **Carries more** (`LOADOUTS.Nightmare`): the Spartan spear and One Punch on top of what it had.

**Where.** Bots' `SKILLS` (`Sure`, `AirPops`, `Lookahead`, `Memory`, `Tempo` new), `LOADOUTS`, `AIR_POP_*`,
`HABIT_*`, `LOOK_OTHERS`; `Brain._steady`, `_getPops`, `_lookAhead`, `_getReach`, `_getHabit`, `_getTargets`,
`_simulate`; `Predict.GetShot` and `_fly` (`openNear`, `OpenStep`); `Server` habits and the second press; `Sim`
habits and `_getNext`.

**How to check.** PC gym: a Nightmare black hole "opened in the air" dealt 95; every shot in logged matches went at
the next player. Live Studio match (cooldowns refilled each turn for the test): black holes lifted their targets
about 10 studs and hit them for 94; no own damage; no errors.

**For the wiki.** Bots (Nightmare): what it does that the other difficulties don't, and its loadout.

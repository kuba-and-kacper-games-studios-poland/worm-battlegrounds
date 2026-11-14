---
title: "Snails drop apart: bots never start within 20 studs of another snail"
date: 2026-11-13
status: open
kind: fixed
pages: ["Match flow", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** Several bots often parachuted onto the same spot (the owner: "3 bots are in the same place"). The
drop drew exactly one land spot per snail, and each bot picked its favourite of them without ruling out a taken one;
Hard's trained genome even liked company (its `Crowd` weight is negative). Now the drop draws Match's
`DROP_SPOT_CHOICES` (6) random land spots per snail, and:

- a bot (`I.Bots.GetStart`) never takes a spot within Bots' `START_GAP` (20 studs) of one taken already, a player's or
  a bot's (with none that far, the farthest one); among the rest, safe ones first (no deadly drop right beside it, no
  blast at its feet dropping it into the sea), then the one its genome likes (high, away from edges and thin ground)
  with its difficulty's `StartNoise` on top (Easy 1, Medium 0.5, Hard 0.25, Nightmare 0.15), so the same map never
  gives the same spots;
- a player who doesn't place starts on the first random spot at least Arena's `LAND_SPOT_GAP` (16) from everyone's
  (`Phases._getFreeSpot`), instead of the n-th spot in the list.

The tutorial's two spots are unchanged.

**Where.** Bots' `START_GAP`, `SKILLS[*].StartNoise`, `Brain.GetStart`; Match's `DROP_SPOT_CHOICES`,
`Phases._drop`, `Phases._getFreeSpot`. The gym seats its matches the same way (`Sim.Play`).

**How to check.** Start a custom lobby alone with three Nightmare bots, several times on one map: the bots land on
different spots each match, never two within 20 studs, and none on the edge of a drop into the sea.

**For the wiki.** Match flow (the drop): where bots and unplaced players start. Match modules (Bots): `GetStart`.

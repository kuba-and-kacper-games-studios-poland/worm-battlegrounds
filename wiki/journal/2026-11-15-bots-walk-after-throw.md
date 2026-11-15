---
title: "Bots run for cover after a thrown shot, as players do"
date: 2026-11-15
status: open
kind: added
pages: ["Match modules", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Gym.lua
---

**What changed.** The owner: "make the bots overall more realistic to behave like real players, so their moves are
not restricted". Players keep moving after an `Arc` or `Target` shot until it bursts (practices, "A thrown shot
leaves the snail moving"); bots stood still. Now every bot, after a thrown shot from the ground, walks on with the
stamina it has left to the spot its genome likes best for the spot alone (cover, edges, exposure), every `MOVE_STEP`
studs its walk reaches, where its own shot's blasts and craters don't reach it; or it stays. Placed Dynamite still
runs as before. The gym moves its stand-in snails the same way and counts it ("walked on" in the report).

**Where.** `Brain.GetRetreat`; `Server.TakeTurn` (Repositioning); `Sim._playTurn`; `Gym` stats `Retreats`.

**How to check.** PC gym runs: bots walked on after 20 to 50 % of their shots; live Studio matches: bots walked 3 to
10 studs after their throws, with no damage to themselves.

**For the wiki.** Bots: they move after throwing.

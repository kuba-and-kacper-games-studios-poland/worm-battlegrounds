---
title: "The jetpack rests the turn after it flew (1 turn cooldown)"
date: 2026-11-15
status: open
kind: added
pages: ["Jetpack"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Move.lua

---

**What changed.** A snail that burned jetpack fuel on its turn can't fly on its next one; its fuel is kept for
the turn after. The owner: "when used, cannot be used in another turn, so 1 turn cooldown". Bots obey it too.

**Where.** Snail attributes `JetpackFlew` (set when fuel is burned: SnailControl's `_setFuel`, the bots'
`Move._saveFuel`) and `JetpackRest` (set from `JetpackFlew` on `Match_TurnStarted`, SnailControl's
`Control._onTurnStarted`). While resting, the client's `_step`, the server's height check and the bots read no fuel.
The bar's Jetpack slot shows a cooldown of 1, and the fuel bar "Jetpack next turn".

**How to check.** Fly on a turn: on the next one the snail can't rise, the slot shows a 1-turn cooldown; the turn
after, it flies again. Tested in Studio on a player; bots resting weren't watched.

**For the wiki.** Jetpack: the stats table's cooldown (a turn's rest after a turn it flew), and a tip to plan flights
every other turn.

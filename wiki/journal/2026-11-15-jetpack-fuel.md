---
title: "Jetpack: one a match with 6 s of fuel that lasts across turns; flying costs fuel, not stamina"
date: 2026-11-15
status: open
kind: changed
pages: ["Jetpack", "Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/Jetpack.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
---

**What changed.** The Jetpack has 1 use a match (was 2). Using it puts on `JETPACK_FUEL` 6 s of flight (was 3 s a use,
emptied at every turn's end); the `JetpackFuel` attribute now stays from turn to turn until it's spent, then the
jetpack comes off and its bar slot locks. Flying in the air on fuel costs no stamina. The bar's Jetpack slot shows the
fuel left as a percent ("75%") while there is some. A shiny Jetpack still holds 20% more (7.2 s, "120%").

New remote: `SnailControl_Fuel @ (player, left: number)`, the client's report of the fuel left every
`FUEL_REPORT_INTERVAL` (0.2 s) while it flies; the server only lowers the fuel, and at the turn's end takes at least
what the snail's climb burned. Bots put the jetpack on once and fly on its fuel in later turns.

**How to check.** Use the Jetpack, fly 2 s, end the turn; next turn hold jump: it flies again for the 4 s left. Fly
sideways with an empty stamina bar: it moves.

**Still unsure.** The bot gym's training sim (`Bots/Scripts/Server/Sim.lua`) still treats each flight as a use, so
trained genomes don't know the fuel carries over.

**For the wiki.** Jetpack: uses, fuel, no stamina while flying, the fuel % on the bar.

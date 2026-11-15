---
title: "Jetpack fuel shows on a bar over the stamina bar"
date: 2026-11-15
status: open
kind: added
pages: ["Jetpack", "Match HUD"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Client.lua

---

**What changed.** While the player's snail wears a jetpack, its fuel shows on a bar over the stamina bar, the
stamina bar's twin in orange: "Jetpack 75%" (the share of the 6 s tank it went on with), or "Jetpack next turn" while
it rests. It empties as the player flies, from the client's own count.

**Where.** The MatchHud gui's `U_Stamina` › `U_Fuel` (`S_Bar` orange 255, 150, 40); MatchHud's `Turn._tick` and
`_cutBar`; its settings `FUEL_FORMAT` ("Jetpack %d%%") and `FUEL_REST_TEXT` ("Jetpack next turn"); the share from
`I.SnailControl.GetFuelShare()`.

**How to check.** Use the Jetpack in a match: the orange bar shows over the stamina bar and drops while flying.

**For the wiki.** Jetpack: its fuel shows on the HUD. Match HUD: the fuel bar over the stamina bar.

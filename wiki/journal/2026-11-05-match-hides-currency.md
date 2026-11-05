---
title: "Match screen: the currency bar no longer covers the turn banner and timer"
date: 2026-11-05
status: open
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** During a match, the lobby's currency bar (coins, diamonds and the green + button) showed at the top
middle of the screen, under the "Your turn!" banner and the turn timer and wind. Now it's hidden while the player is
in a match and comes back in the lobby. The match screen's top shows only the turn banner, the timer and the wind,
as the Match screen page describes.

**Where.** `_refreshShown()` in `MatchHud/Client.lua` turns off each gui in `HIDDEN_IN_MATCH` (`{ "Currency" }`, in
`MatchHud/Settings.lua`) while the Player attribute `InMatch` is true. The Currency gui is tagged
`UserInterface_PreventHiding`, so the framework turns it on at start; before, only the Lobby module hid it in a match,
and the Lobby module doesn't run on a match server.

**How to check.** Played on the Match map in Studio: during a turn, `PlayerGui.Currency.Enabled` is false and the top
of the screen shows only "14 > Wind 4".

**For the wiki.** Match screen: no currency during a match (coins earned show on the results).

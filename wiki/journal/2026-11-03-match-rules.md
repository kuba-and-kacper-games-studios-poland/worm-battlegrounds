---
title: "Match rules: drop, 15-second turns, wind, sudden death, rejoin and rematch"
date: 2026-11-03
status: merged
merged: 2026-11-06
kind: added
pages: ["Match modes & maps", "Match modules", "Architecture", "Data & networking", "Roadmap"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/
  - worm-battlegrounds-game/src/core/game_instance/Start/configs/place_loader.lua
---

**What changed.** The `Match` module runs a whole match on a match server: it reads the metadata MatchBoard sends,
waits up to 20 s for the roster (`WAIT_FOR_PLAYERS`), fills empty seats with bots, then plays the drop (15 s to pick a
landing spot, `DROP_SECONDS`), the landing, and turns of 15 s (`TURN_SECONDS`) with wind up to ±10 (`WIND_MAX`) until
one team is left. Sudden death starts at round 10 (`SUDDEN_DEATH_ROUND`) and raises the water 4 studs a round. At the
end it publishes `Match_Ended`, runs a 20 s rematch vote (`REMATCH_SECONDS`; the tutorial match skips it) and sends
everyone else to the lobby. A player who drops keeps their seat for 60 s (`REJOIN_SECONDS`) and can come back from
the lobby; **Leave** knocks the worm out (cause "Left") and leavers aren't paid.

The place now has two maps: `Lobby` and `Match` (`place_loader.lua`), with module lists for each (`MATCH_ONLY`,
`LOBBY_ONLY`). In Studio the Workspace attribute `Ume_StudioMapId` picks which one a test loads.

**Where.** `Match/Scripts/Server/` (`Phases`, `Roster`, `Turns`, `Placement`, `Stats`, `Connection`, `Rematch`). Remotes
`Match_PickDrop`, `Match_Leave`, `Match_Rematch` (no arguments), `Match_KnockedOut` to everyone. State on
`ReplicatedStorage.Ume.Match` attributes (`Phase`, `ActiveId`, `TurnEndsAt`, `Wind`, `Round`, …) and one
`Configuration` per participant. Profile `Match.Rejoin = { PlaceId, AccessCode, Until }`.

**How to check.** A Studio test on the Match map plays a 4-worm deathmatch against bots to the end and shows Results.

**For the wiki.** Match modes & maps (the timings above), Match modules → Match, Architecture → maps and travel.
Unsure: rejoin and rematch need a published place with two accounts.

---
title: "Every public match starts with all its snails: a bot plays for a player still loading"
date: 2026-11-15
status: open
kind: changed
pages: ["Bots", "Match", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
---

**What changed.** The owner: "if someone hasn't loaded yet because of a bad device, bot will play for him for that
time, he'll not be eliminated etc. so at the start always full amount of worms will be there". Before, a match seated
only the players who had arrived and loaded. Now a public match seats everyone its closed roster holds: a player who
hasn't arrived or whose data hasn't loaded is seated from the card their lobby wrote (Matchmaking's `GetCard`: display
name, VIP, level, loadout, shiny items, skin), with `Connected` false, and the dropped-player bot (Match's
`Autopilot`, Bots' `TAKEOVER_DIFFICULTY`) plays their snail with their loadout. Once their data loads they take over
from their snail's next turn (`Connection._onPlayerAdded` sets `Connected`). They're never knocked out for arriving
late.

**Where.** `Roster._getSeats` and `Roster.Build` (the card in each seat, `Match_RosterEntry.Card`); the card type is
`Matchmaking_Card`.

**How to check.** Studio: two fake seats claimed for absent players, the timer runs out, the match starts with them
seated `Connected` false, Autopilot plays their turns and fires shots, and both are still alive in round 3.

**For the wiki.** Bots: they also stand in for a player still loading at the start, as for a dropped player. Match:
every public match starts with all its snails.

---
title: "Parties join active lobbies whatever their size"
date: 2026-11-13
status: open
kind: fixed
pages: ["Lobby", "Party", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
---

**What changed.** A party's leader joining a public row takes the whole party in when the row has a free seat for each, even when the party is bigger than one team (three in Duos). They share a team where it fits, and the rest spill onto the next team with room. A row that fills starts at once (it already did).

**Where.** `Rows.Join`: the only check is `#row.Players + #group > row.Size` (the team-size check is gone). `Launch`: a player whose party's team is full goes to `_getTeamWithRoom`.

**How to check.** A party of 3 joins an empty Duos row: all three are in it, two on one team and one on the next.

**For the wiki.** Party and Lobby: how a party joins a public row and how teams split. A History line.

**From.** The testers: "you can't connect to duos when there's 3 people in party", "active lobbies are broken".

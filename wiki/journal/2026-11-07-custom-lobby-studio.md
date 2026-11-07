---
title: "Custom lobbies start alone in Studio, with bots"
date: 2026-11-07
status: open
kind: changed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
---

**What changed.** A custom lobby needs 2 or more players and has no bots (the Lobby page), so in a Studio playtest,
which has one player, Start never worked ("Invite at least one more player first."). Now, only in Studio
(`RunService:IsStudio()`), the owner may start it alone and the match fills its empty places with bots at
MatchBoard's `PUBLIC_DIFFICULTY`. Live servers are unchanged: 2 or more players, no bots, no coins.

**Where.** `Module.Start` in `MatchBoard/Scripts/Server/Custom.lua` (the `#row.Players < 2` check); `Module.Build`
in `Match/Scripts/Server/Roster.lua` (the bots' `metadata.Kind ~= "Custom"` check).

**How to check.** Studio playtest: Custom → pick a map → Create → Start. Checked 2026-11-07: a 4-player Desert
custom match started with the player and bots `B_2`–`B_4`.

**For the wiki.** Architecture → testing in Studio: custom lobbies start alone there, with bots. The Lobby page's
custom lobby rules stay as they are.

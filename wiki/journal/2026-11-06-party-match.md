---
title: "Play with party: friends only, bots on or off (half coins without bots)"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: added
pages: ["Lobby", "Match modes & maps", "Progression"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/Settings.lua
---

**What changed.** In a party, the lobby's Play solo reads **Play with party**. The leader picks No bots, Easy, Medium
or Hard and starts a friends-only deathmatch (every worm for itself): with bots, one bot per party member (a party of 3
plays with 3 bots), paid like a public deathmatch of that size; with No bots, only the party plays and it pays half
of that. Other members pressing it are told only the leader can start. Party matches give the usual 100 XP.

**Where.** Remote `MatchBoard_PlayParty @ (player, difficulty)`: leader of a party of 2+, difficulty `Easy`, `Medium`,
`Hard` or `None`. Match metadata `Kind = "Party"`, `Mode = "Deathmatch"`, `Difficulty = "None"` for no bots (Roster
seats no bots then). `PARTY_BOTS_PER_PLAYER` 1, `PARTY_MAX_SIZE` 8 (MatchBoard); `PARTY_NO_BOTS_SHARE` 0.5 and
`XP_KINDS.Party` (MatchRewards), coins from `DEATHMATCH_COINS` by worm count, rounded down.

**How to check.** Needs two players (a Studio test with 2 players, or the published game): make a party, the leader
presses Play with party, picks No bots, Start. Not checked yet: one test player can't make a party.

**For the wiki.** Lobby: Play with party and its setup. Match modes & maps: the party match. Progression: party coins
(as a public deathmatch, half without bots) and XP.

**From.** The owner's request (2026-11-06): "option to play only with friends… with disabled bots then less coins by
50%".

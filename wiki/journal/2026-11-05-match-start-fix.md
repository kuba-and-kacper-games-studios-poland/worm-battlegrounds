---
title: "Matches start once players' data loads; leaving the tutorial match counts as playing it"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Lobby", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
---

**What changed.** In the published game, a match server could stay on "Waiting for players 1 / 1" forever. The
wait ended as soon as the player joined, before their saved data had loaded (that takes a few seconds after a
teleport). Seating them then read their loadout and skin from data that wasn't there yet, and the error stopped
the match loop. A new player hit this on their first join (the tutorial match). Leaving sent them to the lobby,
which sent them straight back to the tutorial, because it still wasn't played.

Now:
- A player counts as arrived (the overlay's count) only once their data and client have loaded (`I.Player.Valid`).
  The match still starts without them after `WAIT_FOR_PLAYERS` (20 s), and seating skips anyone still loading.
- A match that can't play (its map doesn't load, or an error stops it) sends everyone to the lobby instead of
  leaving them waiting.
- Leaving the tutorial match early (Leave game, or a match that can't play) counts as playing it: the player gets
  the tutorial's 100 coins and goes on to the free tutorial crate in the lobby. Closing the game mid-tutorial
  doesn't, so they get the tutorial again on their next join.

**Where.** `Roster.WaitForPlayers` and `Roster.Build` (the `I.Player.Valid` checks); `Phases._mainLoop` runs
`Play()` in a `pcall`, and `Play()` now returns `false` when the map didn't load; `Connection.SendToLobby` calls
`I.Tutorial.CompleteMatch` and saves when the match's `Kind` is `Tutorial`.

**How to check.** Published game, fresh profile: the first join lands in the tutorial match against one bot, the
overlay shows 1 / 1, and the drop starts. Press Leave game: back in the lobby, the Crates button's badge reads
FREE, and no teleport back to the tutorial. Studio (Workspace attribute `StudioTutorial` = true): the same, on
one server.

**For the wiki.** Lobby → First time playing: leaving the tutorial match early still counts it as played (coins
and the free crate). Match screen: a match that can't start sends everyone back to the lobby.

Still unsure: the teleport timing was only reasoned out from the code. Studio can't teleport, so the fix needs a
published test to confirm it.

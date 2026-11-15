---
title: "Joining an open public match and rejoining a match work again"
date: 2026-11-16
status: open
kind: fixed
pages: ["Matchmaking", "Architecture"]
files:
  - worm-battlegrounds-game/src/core/game_instance/Start/tasks/place_loader/Teleport.lua
---

**What changed.** Pressing Join on a lobby card that found an open public match on another server failed with
"Couldn't start the match. Try again!", and the lobby's rejoin offer failed with an error. Both teleport through
`I.TeleportToServer` with an access code and no job id, and it set `TeleportOptions.ServerInstanceId` to nil, which
Roblox refuses ("Unable to assign property ServerInstanceId. string expected, got nil"). It now sets only the one it's
given: `ServerInstanceId` for a job id, `ReservedServerAccessCode` for an access code. Opening a new match
(`I.Teleport`) was never affected.

**Where.** `I.TeleportToServer` in the place loader's `Teleport.lua` (a framework file the game changed; callers:
MatchBoard's `Launch.Send` with an access code, Lobby's `_onRejoin`, the admin teleport command).

**How to check.** Checked in Studio on 2026-11-16: `I.TeleportToServer` with an access code returned true and Studio
sent the player to the match place; with a job id it no longer errors. Not checked on live servers.

**For the wiki.** Nothing for players beyond Join and rejoin working; the Architecture page may note the fix in its
History.

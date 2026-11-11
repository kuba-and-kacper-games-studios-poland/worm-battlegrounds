---
title: "A dropped player's snail is played by a bot until they come back (rejoin offer 60 s → 15 min)"
date: 2026-11-10
status: open
kind: changed
pages: ["Match modes & maps", "Lobby", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
---

**What changed.** A player who dropped out used to keep their seat for 60 seconds, their snail skipping its turns,
and was then knocked out as a leaver. Now their snail stays in the match for good and a bot plays its turns, at
Medium skill with the player's own loadout. A player who drops during their turn hands the rest of it to the bot,
with at least 12 seconds left on the timer. The lobby offers to send them back for 15 minutes (900 s, up from 60).
Back in the match, they get control from their snail's next turn, with whatever the bot did (moves, shots, uses)
kept, on their team again. The Leave button still forfeits (a knockout, "Left").

**Where.** `Turns.RunTurn` plays a turn with `autopilot` (a bot participant, or a player not `Connected`) and sets the
match folder's new attribute `Autopilot` (true only for a player's snail played by a bot; cleared at the turn's end);
a drop mid-turn calls `I.SnailControl.EndTurn`, resets the deadline to at least `TAKEOVER_SECONDS` (12, Match
settings) and starts `I.Bots.TakeTurn`. `Turns._canPlay` no longer skips disconnected players. Match settings
`REJOIN_SECONDS` 60 → 900 (now only how long `Match.Rejoin.Until` lets the lobby offer the rejoin). Removed:
`Connection`'s rejoin deadlines and `_checkDeadlines`. `Connection._onPlayerAdded` reassigns the team
(`Roster.AssignTeam`) and sets `ReplicationFocus` back to the snail. New server API `I.Match.IsAutopilot()`;
`I.Match.IsActivePlayer` and the client's `I.Match.IsMyTurn` are false while `Autopilot`. Combat's `Combat_Fire`,
`Combat_UseUtility` and `Combat_Detonate` handlers now need `IsActivePlayer`, and `Combat_Select` is refused while a
bot plays that snail; `ShowAim` turns the snail to face its aim under autopilot too. Bots: new server setting
`TAKEOVER_DIFFICULTY` = "Medium", used by `TakeTurn` for a participant without `Difficulty`. Supersedes the rejoin part
of `2026-11-03-match-rules` and the 60 s in `2026-11-03-lobby-matchboard-party`.

**How to check.** Needs two clients (Studio's local server test with 2 players, or a published place): in a match,
close one player's client; on their next turn the snail moves and fires by itself, and `Workspace.Ume.Match`'s
`Autopilot` is true during it. Rejoin from the lobby: the next turn is the player's. Not checked by the docs pass.

**For the wiki.** Match modes & maps (or the match rules): a dropped player's snail is played by a bot until they
come back; only leaving forfeits. Lobby: the rejoin offer lasts 15 minutes. Match modules: the `Autopilot` attribute
and `IsAutopilot`.

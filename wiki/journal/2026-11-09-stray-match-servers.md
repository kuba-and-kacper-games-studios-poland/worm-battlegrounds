---
title: "A match place server no lobby sent a match to plays nothing and sends players to the lobby"
date: 2026-11-09
status: open
kind: fixed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
---

**What changed.** Players could join the match place (Arena) directly, through a public server, instead of being sent
there by a lobby. Such a server used to play the Studio stand-in match (`STUDIO_METADATA`, a public deathmatch) for
whoever joined, and MatchRewards paid it like a real match: a way to farm on your own server.

Now a match place server that has no match from a lobby plays nothing and teleports everyone to the lobby. This only
applies outside Studio; in Studio the Match map alone still plays the stand-in.

**Where.** The new `Connection.IsStray()` returns true when `I.Config.Metadata` is nil and the server isn't Studio.
`Connection._onPlayerAdded` sends such a server's players to the lobby. `Phases._mainLoop` returns before playing.

**How to check.** Not testable in Studio (Studio is excluded). On a live public server of the match place, a joining
player is teleported to the lobby and no match starts.

**For the wiki.** Architecture, the two places: a match place server plays only the match a lobby sent it. Turning
off direct access to the match place on the Creator Hub would also help, if Roblox allows it for that place.

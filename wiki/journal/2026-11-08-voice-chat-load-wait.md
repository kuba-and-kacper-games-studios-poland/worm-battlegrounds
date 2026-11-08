---
title: "Joining together no longer waits 30 s per player"
date: 2026-11-08
status: open
kind: fixed
pages: ["Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Utils/VoiceChat/Client.lua
---

**What changed.** Players who joined a server together (a party teleported into a match, friends joining the lobby
at once) waited about 30 s for each other player before their screen loaded: 90 s with three others. Now they load
as fast as a player who joins alone.

**Where.** VoiceChat's client `Start` waited for each player already in the server to get their `VoiceChat`
`AudioDeviceInput` (`player:WaitForChild("VoiceChat", 30)`), one after another. The server gives that input only
after the player's data loads, and loads their data only once their client has started every module, so players
arriving together waited on each other. Each wait now runs on its own thread (`task.spawn(Module._watchPlayer, …)`).

**How to check.** Not checked live yet: join a server with 2 or more friends at once, or teleport a party into a
match, and the teleport card should clear in seconds. In Studio alone the client starts in about 0.14 s, as before.

**For the wiki.** Architecture: the load order (client starts its modules, then the server loads the player's data,
then `OnLoaded` and the character), and that a client's Init and Start never wait on other players.

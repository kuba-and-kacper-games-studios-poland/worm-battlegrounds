---
title: "Holes cut on each screen at once; cut-loose ground falls straight down on the map's plane"
date: 2026-11-09
status: open
kind: changed
pages: ["Match modes & maps", "Match modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Helpers/Cutter.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Debris.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Falling.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
---

**What changed.** Blast holes now open at once on every screen: each client cuts the hole itself as soon as the
server announces the blast, instead of waiting for the server's pieces to replicate one part at a time. The server
also cuts every part at once now and swaps them in one frame. The explosion effect plays before the cut, not after.
Ground cut loose no longer tumbles on Roblox physics: it falls straight down by the game's gravity, never turning
and never leaving the map's plane, lands on whatever terrain is under it and stays there, so players can drop chunks
into gaps to make bridges. A chunk with nothing under it falls 20 studs below the arena and is removed, as before.

**Where.** Arena's new remotes `Arena_Carve (carveId, center, radius)` and `Arena_Fall (group, drop, started)`,
fired by the server to everyone; carved pieces carry the attribute `Arena_Carve` (the carve's number). The shared
cutter is `Scripts/Helpers/Cutter.lua` (`Build`, `Subtract`). The fall is Debris' `_fall`, `_watch` and `_getDrop`
(a `Workspace:Shapecast` of each part straight down). New setting `PREDICT_TIMEOUT` (3 s: a hole a client cut alone
is undone if the server never cuts it). Removed settings: `SETTLE_SPEED`, `SETTLE_HOLD`, `DEBRIS_SETTLE_TIME`
(Arena's; the physics settle is gone). `DEBRIS_KILL_DEPTH` stays 20. In Combat's `Blast.Explode`,
`Combat_Explosion` now fires before `I.Arena.Carve`.

**How to check.** In a Studio match, the client's `Workspace.Ume.Arena.Predicted` fills with pieces 35–110 ms before
the server's pieces arrive (more on live servers), then empties; a chunk cut off a ledge drops straight down and its
X, Z and rotation never change.

**For the wiki.** Match modes & maps → Movement and physics: debris falls straight down and stays where it lands
(bridges are possible), no tumbling. Match modules: Arena now runs on the client too (Carver, Falling), the Debris
row no longer welds or uses physics, the two remotes. Architecture: Arena's client side.

**From.** The owner's notes (2026-11-09): smoother holes on the client, and chunks locked to the map's axis.

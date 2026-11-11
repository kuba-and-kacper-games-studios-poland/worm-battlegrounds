---
title: "Custom lobby matches on Picnic Plains: aim, drop and shots fixed; no team warning"
date: 2026-11-10
status: open
kind: fixed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
---

**What changed.** Matches from custom lobbies, which start on Picnic Plains, had the aim inverted, couldn't pick a
drop spot, and fired invisible shots that carved the bottom of the map. The `PicnicPlains` template in the place had
been dragged in Studio to Z −810.5, off the play plane (Z = 0) that the drop picker, the aim and the shot simulation
read. Arena now puts a map back on the plane at start when it isn't, with a warning. Team matches also printed
"Team (Red) already exists!" when a server played a second team match: the Roblox team is now made only once.

**Where.** `Loader._cacheTemplates` in `Arena/Scripts/Server/Loader.lua`: when a template's `Markers.Bounds` pivot is
more than 0.01 off Z = 0 it warns "Map (<MapId>) Bounds sit at Z <z>, not 0 - moved back onto the plane!" and moves
the template by that much. `Roster.AssignTeam(participant)` (Match, server) creates the team only when `Teams` has
none of that name, then assigns the player; `Roster.Build` and `Connection._onPlayerAdded` (a player back after
dropping) use it.

**How to check.** Start a match from a custom lobby: Output shows no Team warning, and the place's warning for
Picnic Plains only while the template is still off the plane. The aim follows the mouse and the drop marker shows.
Not checked in Studio by the docs pass.

The template was moved back onto the plane in the open place on 2026-11-10
(`Workspace.Ume.ServerStorage_Assets.Arenas.PicnicPlains` pivot 0, 8, 0; its `Markers.Bounds` 0, 57, 0), so the
warning should no longer print. That move is only in the open Studio session: the owner must save and publish the
place for it to stay.

**For the wiki.** Architecture (maps): every map's Bounds stand on Z = 0, and one that doesn't is moved back at start.
Match modes & maps: nothing a player reads, beyond the bug.

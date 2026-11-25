---
title: "Public JOIN and the waiting room work again on live servers"
date: 2026-11-24
status: open
kind: fixed
pages: ["Public matches"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/WaitingRoom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/_meta/_types.lua
---

**What changed.** Two reads across the two places broke public matches live; Studio's map loads both halves, so
tests never showed them.

- In the lobby, JOIN failed with "Couldn't join a Deathmatch match" whenever it had to open a new match: MatchBoard
  read `I.Settings["Match"].WAITING_SECONDS`, and the lobby place doesn't load Match. MatchBoard's `Settings.lua` now
  has its own `WAITING_SECONDS` (15, a copy of Match's), used by `Public._getNewLobby`.
- On the match server, the waiting room errored every refresh (`WaitingRoom:140`, index nil with `MAPS`): it read
  `I.Settings["MatchBoard"]`, which the match place doesn't load. The room showed, but its title, player count, list
  and vote count never filled in. The lobby now sends the mode's and map's names and the mode's icon in the public
  match's metadata (`Match_Metadata.ModeName`, `ModeIcon`, `MapName`, from `Public._getMetadata`), Match's `Phases`
  writes them on `Workspace.Ume.Match` as attributes, and the waiting room reads those.

**How to check.** On the live game (or with `Ume_StudioMapId = "Lobby"`), JOIN on an empty card opens a match and
teleports; on the match server the waiting room shows "Deathmatch · <map>", the players seated and "Players n/size".

**For the wiki.** Nothing players see changes beyond these working; a History line at most.

---
title: "The custom lobby is the studio's CustomLobby and CustomLobbyPlayers designs"
date: 2026-11-12
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
---

**What changed.** Custom opens the studio's two designs (ported 1:1): the create step (the maps list, mode, players
2/4/6/8, bots None to Nightmare, CREATE LOBBY) and the room (members with @usernames, who can be invited, INVITE
FRIENDS, START for the owner, LEAVE). The picked choices are outlined white, the rest grey. The room's info line reads
"Teams  |  4 players  |  Desert  |  Hard bots".

**Where.** `U_Create` and `U_Room` in the CustomLobby gui; `Custom.lua` (`_setPicked` reads the `Look_*` attributes).

**How to check.** Lobby, then Custom: pick a map, mode, size and bots, then Create lobby; the room shows.

**For the wiki.** Lobby (custom lobbies): the new look; the steps are unchanged. Unsure: not clicked through in this
playtest.

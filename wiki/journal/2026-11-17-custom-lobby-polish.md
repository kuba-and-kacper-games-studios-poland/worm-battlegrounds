---
title: "Custom lobby: the lobby slides away, sizes a map can't hold fade out, and the server checks the size"
date: 2026-11-17
status: open
kind: changed
pages: ["Custom lobbies"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
---

**What changed.** Opening the custom lobby's window slides the bottom board, SOLO VS BOTS and Custom off the screen and
hides the loadout, as the solo setup does; closing brings them back. Player counts the picked map isn't made for fade
out and can't be picked, and picking a map moves the count to the nearest it holds. The server now refuses a size
outside 2 to 8 or one the map isn't made for (before, any even number passed). The lobby's second step sits in the same
centre as the first.

**Where.** `Board._slidePlay`, Lobby's `PANEL_WIDGETS` (`CustomLobby`), `Custom._fitSize` and `_setFaded`, server
`Custom.Create`.

**For the wiki.** Custom lobbies.

**Changed after the owner's second look (same day).** Both steps of the custom lobby's window sit centred under the
lobby's top bar (0.564 down, their aspect ratios kept): at the middle, the new FREE WEAPONS tile covered the window's ✕.

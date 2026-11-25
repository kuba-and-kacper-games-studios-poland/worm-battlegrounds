---
title: "Lobby: one gear tile opens PLAY WITH FRIENDS (Local, Custom); match setups take the whole screen"
date: 2026-11-25
status: open
kind: changed
pages: ["Lobby", "Local play", "Custom lobbies", "Play solo"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FriendsMatch/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchSetup/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/WidgetManager/Scripts/Dim.lua
---

**What changed.** The lobby's blue LOCAL and CUSTOM buttons are gone (the owner: "one small square button with game
settings gear"). In their place above PLAY SOLO sits a square gear tile (the EMOTES tile's look, the pad's X), which
opens **PLAY WITH FRIENDS**: "How do you want to play?" with two big buttons, **LOCAL** ("Friends on this screen,
taking turns") and **CUSTOM** ("Make a room: map, bots, then invite friends"). They open the local setup and the
custom lobby as before, with the same party rules (LOCAL refused in a party; CUSTOM "Host picks" for a party member,
"Party lobby" once in their leader's lobby). The owner rated the preview, then asked: "hide other uis, center it and
make the background darker". So PLAY WITH FRIENDS, the custom lobby and the solo, party and local setup all hide the
lobby's other guis and the stage's nameplates while open, sit in the middle of the screen (were 0.564 down), and dim
the background darker (0.3 transparency, the usual 0.5 for other windows).

PLAY SOLO is now centred on the PUBLIC MATCHES bar and a little taller (128 px on a 1080 p screen, was 111 sitting
on its bottom), with a slightly heavier outline, and the gear sits higher, its bottom level with the PUBLIC MATCHES
title (the owner: "make it bigger, so it is aligned with the bottom lobby matches gui", then "its too big, make it a
bit more slick" at the bar's full height; "move the settings gear logically higher").

**Where.** The gui `FriendsMatch` (new) and `MatchBoard`'s `S_Friends`; MatchBoard's `FRIENDS_GUI_NAME` and Board
(LOCAL and CUSTOM now found in `FriendsMatch`); Lobby's `FULL_SCREEN_WIDGETS` (adds FriendsMatch, CustomLobby,
MatchSetup; `PANEL_WIDGETS` lost the last two); WidgetManager's `Dim` reads a widget's `WidgetManager_Dim` attribute.

**How to check.** In the lobby, the gear above PLAY SOLO opens PLAY WITH FRIENDS over a dark, blurred lobby with no
other ui; LOCAL and CUSTOM open their setups the same way; closing brings the lobby back. Checked in Studio on
2026-11-25 (gear, LOCAL, CUSTOM, closing).

**For the wiki.** Lobby: the gear tile and PLAY WITH FRIENDS replace the Local and Custom buttons; Local play and
Custom lobbies: how to reach them now.

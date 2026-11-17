---
title: "Party panel follows a custom lobby's size (two columns from 5), emote bubble clear of the name"
date: 2026-11-17
status: open
kind: fixed
pages: ["Lobby", "Custom lobbies"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
---

**What changed.** While a player picks a size on the custom lobby's create step, the Party panel already shows that
many places (before, it stayed at 4 until the lobby existed). More than 4 cards fill a second column of compact cards
(avatar, level and crown), instead of one column squeezed to half size.

**Where.** Party's `COLUMN_CARDS` 4, `SECOND_COLUMN_X` 1.3; MatchBoard's `I.MatchBoard.GetPickedSize` and its
`MatchBoard_RoomChanged` on a picked size. The emote bubble's move is in the match screens' entry.

**For the wiki.** Custom lobbies: the panel.

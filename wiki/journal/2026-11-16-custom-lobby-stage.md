---
title: "Custom lobby on the lobby stage: 8 pods, camera fits everyone, Party column lists the lobby"
date: 2026-11-16
status: open
kind: added
pages: ["Lobby", "Party", "Custom lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Settings.lua
---

**What changed.** While a player is in a custom lobby, the lobby's stage shows its members (in this server) on a new
set of eight pods: three in front, two raised behind them, three higher at the back, packed close. The camera backs
off along its look (and so rises) just far enough to fit every snail, easing there. The Party column at the left lists
the custom lobby instead of the party: its members, a crown on the lobby's owner, no Kick or Leave, and a + card per
free place up to the lobby's size, which opens the custom lobby's window. The custom lobby's member list ends with an
"Open slot" line (faded) per free place.

**Where.** The pods are a place asset, `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB | CustomPods"]`
(`Pods` › `Pod_1` to `Pod_8`, each with a `Snail` marker), authored 300 studs beside the stage; each client puts it on
the stage's pivot in place of the stage's own pods. Lobby's `CUSTOM_PODS_PREFAB`, `STAGE_FIT_MARGIN` (0.82),
`STAGE_CAMERA_EASE` (0.08), `Stage._getFitCFrame`. MatchBoard's client now has `I.MatchBoard.GetCustomRoom()` and the
client Topic `MatchBoard_RoomChanged` (published on every refresh of the player's lobby), plus
`CUSTOM_OPEN_SLOT_TEXT` ("Open slot") and `CUSTOM_OPEN_SLOT_TRANSPARENCY` (0.5). Party's `CUSTOM_GUI_NAME`
("CustomLobby").

**How to check.** Make a custom lobby of 8 and invite a player: the stage swaps to the eight pods, both snails show
and the camera pulls back; the Party column shows the two of you, a crown on the owner and six + cards. Not checked
with eight players; a full lobby of 8 may not fit the Party column's height.

**For the wiki.** Lobby: the stage in a custom lobby. Party: the column lists the custom lobby while you're in one.
Custom lobby: open slots in the member list.

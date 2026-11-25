---
title: "Nameplates over the stage snails, and \"+\" bubbles over free pods"
date: 2026-11-24
status: open
kind: added
pages: ["Lobby", "Party", "Custom lobbies"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Nameplate/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/InviteBubble/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** Every snail on the lobby stage wears the studio's nameplate: the player's level in a gold badge,
then their display name over their @username. The party's other snails wear theirs a quarter smaller than the
player's own. Over each free pod floats a small, faded "+" bubble (a copy of the party column's + card); pressing it
opens the party invite, or the custom lobby's window while the player is in one. The bubbles show only while the
player may invite (no party, its leader, or in a custom lobby) and isn't in a match.

**Where.** Lobby's `Stage.lua` (`_label`, `_refreshInvites`); Lobby settings `NAMEPLATE_NAME` "U_Nameplate",
`NAMEPLATE_SCALE` 2.3, `NAMEPLATE_GAP` -0.9 (studs from the snail's top before it holds its weapon),
`NAMEPLATE_OTHER_SCALE` 0.75, `INVITE_NAME` "U_InviteBubble", `INVITE_HEIGHT` 5. New guis `Nameplate` (billboard 6 ×
1.1 studs) and `InviteBubble` (1.7 × 1.25 studs), exported into `Workspace.Ume.ReplicatedStorage_Assets/Lobby` as
`PREFAB | Nameplate` and `PREFAB | InviteBubble` (`RootPart` › `Attachment` › `U_Nameplate` / `U_InviteBubble`).

**How to check.** Join the lobby alone: your snail has your name and level over it and three "+" bubbles float over
the empty pods; press one and the invite list opens. In a party as a member, no bubbles.

**For the wiki.** Lobby: the nameplates and the + bubbles (screenshot). Party: inviting from the stage.

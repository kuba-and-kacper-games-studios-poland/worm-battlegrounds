---
title: "Lobby fixes: clean invite window, centred PLAY SOLO, JOIN spam, whole emotes"
date: 2026-11-24
status: open
kind: fixed
pages: ["Lobby", "Emotes"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
---

**What changed.** Fixes from the owner's lobby notes:

- **Invite Players hides the lobby pieces it would overlap.** The FREE WEAPONS tile overlapped the window. Now the
  top row (the menu with FREE WEAPONS, the coins) and the board hide while it's open, as for the weapon picker. Party
  and Loadout stay. This is Lobby's `PANEL_WIDGETS.PartyInvite`.
- **PLAY SOLO's icon and text are centred as one group** (MatchBoard's `_centreSolo`, `SOLO_ICON_GAP` 0.25). Measured
  in Studio: 62 px either side on a 429 px button. "Play with party" and "Waiting for host" are centred the same way.
- **The Custom Lobby window's title icon is the new Custom glyph** (image 89277478392791), replacing the old
  `art/modes` picture.
- **JOIN can't be spammed.** A press within `JOIN_PRESS_GAP` (1 s) of the last sends nothing. Before this, fast
  presses went past the server's rate limit (2 a second) and Studio printed "went over the rate limit on RemoteEvent
  (MatchBoard_Join)". That was the rate limit doing its job, not a bug, but the client no longer sends what it would
  refuse.
- **An emote plays whole on the lobby stage.** The stage's bazooka pose (priority Action4) played over the wave. Now
  every track at Action priority or above stops while the snail emotes, then plays again from where it was
  (SnailRig's `MUTED_PRIORITIES`, `_mutePoses`). That covers the stage pose and the held weapon's pose, in a match
  too.
- **The emote cloud stands over the nameplate.** In the lobby, ChatBubbles anchors the bubbles to the nameplate's top
  plus `STAGE_GAP` (0.3, was 0.6 over the body's top). Before, the cloud covered the name.

**How to check.** Open the party invite: no FREE WEAPONS, top row or board. In the lobby, PLAY SOLO's triangle and
text are centred. Press JOIN eight times fast: the Output has no rate-limit warning. Press Wave in EMOTES: the snail
waves facing the camera without its bazooka, its cloud over its name, then strikes its pose again.

**For the wiki.** Lobby: the invite window, the centred PLAY SOLO. Emotes: an emote plays on its own, over no pose.

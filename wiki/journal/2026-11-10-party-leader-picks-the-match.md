---
title: "In a party only the leader picks the match; custom lobbies take the whole party"
date: 2026-11-10
status: open
kind: changed
pages: ["Lobby", "Lobby & meta modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.**

- **Party members' buttons are greyed out:** a lobby card's Join reads "Host picks", Solo vs bots reads "Waiting for
  host", and Custom reads "Host picks". Pressing any of them says "Your party's leader picks the match."
- **Custom lobbies take the party:** only a party's leader can make one ("Only your party's leader can make a custom
  lobby."), and the whole party is put in it at once, their windows staying closed; their Custom button then reads
  "Party lobby" and opens it. A party too big for the lobby is refused ("Your party doesn't fit: pick more players."):
  in Teams it must fit on one team (half the size).
- **A Teams lobby without bots** can't start when everyone is in the owner's party ("Your party plays on one team:
  invite players from outside it, or add bots.").
- **The window closes** when the player's lobby closes without them pressing Leave (it started, or its owner closed
  it), instead of flipping to the create step.

**Where.** Client `Board._refresh` and `Board._setLocked` (keeps the design's look in the button's `Look_MainColor`,
`Look_StrokeColor`, `Look_TextColor`, `Look_HoverScale`, `Look_ClickScale` attributes; Custom's `Interact_Function`
is `""` while locked). New MatchBoard settings `LOCKED_MAIN_COLOR` (70, 70, 80), `LOCKED_STROKE_COLOR`
(130, 130, 130), `LOCKED_TEXT_COLOR` (153, 153, 153). Server `Custom.Create` and `Custom.Start`; `Rows.GetGroup`
(was `_getGroup`, now public). Client `Custom._onRoomRemoved`. No remotes changed.

**How to check.** Needs two players in a party (Studio's local server test): the member's three buttons are grey with
those texts; the leader makes a custom lobby and the member's Custom reads "Party lobby". Not checked by the docs pass.

**For the wiki.** Lobby (parties and custom lobbies): only the leader picks; custom lobbies take the whole party; a
Teams lobby needs players from outside the party or bots.

---
title: "Local play: 2 to 8 friends on one screen, one controller passed round"
date: 2026-11-17
status: open
kind: added
pages: ["Game modes", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/HandOff.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LocalHandOff/init.lua
---

**What changed.** A new LOCAL button beside Custom opens the setup as "Local play": the number of players (2 to 8),
bots (none, or one per player at a difficulty) and the map. Each local player gets a snail of their own ("Player 2"…),
all played from the host's screen. Before each local player's turn a card names them ("PLAYER 2'S TURN · pass the
controller") and the turn waits for a press (30 s at most) before its timer starts; the turn banner names the snail.
Local matches pay no coins or XP and count toward no statistic. One controller passed round only for now; one pad each
needs a check on Xbox first.

**Where.** `MatchBoard_PlayLocal(difficulty, mapId, players)`, metadata `Kind = "Local"`, roster seats with `Guest`;
guests are `P_<hostId>_<n>` with the host's `UserId`. `I.Match.GetControlledId(player)` (server) and
`I.Match.GetMyParticipantId()` (client) answer "which snail this player plays now"; SnailControl follows every snail of
the screen's player. The hand-off: the `HandOff` match attribute, `Match_HandOffReady`, `LOCAL_HANDOFF_SECONDS` 30.

**How to check.** LOCAL, 3 players, Start: three snails; each turn shows the card first; the HUD and controls drive the
active one.

**For the wiki.** Game modes: Local play.

**Changed after the owner's second look (same day).** "This Player Turn gui is also weird… make sure it does not
overlap other guis": the `LocalHandOff` card (a dark band of its own, popping over the HUD's turn callout, since the
turn was announced before the hand-off) is gone. The server names the hand-off (`HandOff`) before the turn shows
(`ActiveId`), and the HUD's own turn callout holds with the snail's avatar, "Player 2's turn" in its colour and
MatchHud's `HANDOFF_TEXTS` line ("Pass the controller, then click when ready"; tap on phones, A on a pad), the turn's
timer hidden, until the press; then the line becomes "Aim and fire!" with the turn's bugle and the callout goes as
usual. LOCAL is now CUSTOM's blue button beside it, and the local setup is the custom lobby's window (see
2026-11-17-play-solo-maps): PLAYERS as buttons 2 to 8, BOTS from OFF, "No rewards".
Files added: `MatchHud/Scripts/Client/Turn.lua`, `MatchHud/Settings.lua`, `Match/Scripts/Client/HandOff.lua` (the
press only).

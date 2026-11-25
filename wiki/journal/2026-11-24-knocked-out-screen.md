---
title: "Knocked-out screen: who did it, rewards at once, Play again"
date: 2026-11-24
status: open
kind: added
pages: ["Match", "Rewards", "Controls"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/KnockedOut.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Settings.lua
---

**What changed.** When the player's own snail goes out, the match HUD's knocked-out block (`U_KnockedOut`) is now a
full screen in the dialog look (dark rounded panel, white Londrina text), replacing the old "YOU WERE KNOCKED OUT!"
with two buttons:

- **KNOCKED OUT!** and, under it, who did it: the killer's picture framed in their team colour, their name in that
  colour and the weapon's icon, with "with the Bazooka". With no snail to name it says how instead ("You fell into the
  water", "You fell into the lava", "You fell out of the arena", "You knocked yourself out"), bigger, in the killer
  card's place.
- **The player's place, coins and XP**, with their damage, knockouts and best shot. "Waiting for the match to end..."
  until their whole team is out.
- **PLAY AGAIN** (gold, A; public and solo matches only), **SPECTATE** (slate, X: closes the screen to watch on) and
  **LOBBY** (red: leaves). It pops in (`KO_POP_START_SCALE` 0.85, `KO_POP_TWEENINFO` 0.3 s back out); a turn callout
  still up is taken down, and none shows while the screen does.

**A team that's out is paid at once.** When a team's last snail goes out (not by leaving), its place is final (teams
that go out later rank above it), so MatchRewards pays its players then and sends `MatchRewards_Earned (place,
lastPlace, earned, stats)`. Local matches and the last two teams still wait for the end. At the end those players aren't
paid again; their Results show the same rewards. Anti-farm still applies: the last two places get no coins before
`ANTI_FARM_ROUNDS` rounds or a knockout by another player.

**Play again.** `Match_PlayAgain (player)` (rate limit 1/s), from a knocked-out player in a Public or Solo match, saves
`Profile.Match.PlayAgain = { Kind, Mode, Difficulty, Until }` (`PLAY_AGAIN_SECONDS` 90) and sends them to the lobby.
The lobby reads and clears it on join (on the Studio map, as `InMatch` turns false) and calls
`I.MatchBoard.PlayAgain`: Solo plays solo again at that difficulty, Public joins that mode's public card (its filling
match). Match's `I.Match.GetPlacements` and `GetStats` are new for the early pay.

**Pad.** Console's new `Spectate` action (X, hint "Watch", a gui action) presses SPECTATE; A presses PLAY AGAIN.

**How to check.** In a Studio match, admin `snails kill` on your own snail: the screen pops in with the cause, 4th place,
the stats and +100 XP ("+0 coins" before round 2: anti-farm). Play again on the Studio map sends you back to the lobby
(it holds one match at a time); a profile with `Match.PlayAgain` set and `InMatch` toggled true → false seats the player
in a new public match (checked 2026-11-24). The full trip runs only on live servers.

**For the wiki.** Match: the knocked-out screen and its three buttons, Play again. Rewards: a team out is paid when its
last snail goes out. Controls: X spectates after being knocked out.

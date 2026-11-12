---
title: "The setup is the studio's Play Solo panel, with the win reward in coins"
date: 2026-11-12
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** Solo vs bots opens the studio's `PlaySolo` design (ported 1:1) in place of the GUI kit panel: PLAY
SOLO, a red ✕, Easy / Medium / Hard (No bots too in a party), WIN REWARD with a coin and the amount, and a yellow
START. The picked difficulty is outlined white. The difficulty descriptions are gone (the design has none). A solo win
shows 20 / 35 / 60 coins for Easy / Medium / Hard; a party match shows how it pays instead, without the coin.

**Where.** `U_Setup` in the MatchBoard gui; `Setup.lua` (`_refresh`); MatchBoard's `REWARD_TEXT` and
`SOLO_WIN_COINS` (a copy of MatchRewards' `SOLO_COINS`, in its ServerSettings: change both together). The panel hangs beside Party as before.

**How to check.** In the lobby, Solo vs bots, then pick Hard: the reward reads 60.

**For the wiki.** Lobby: the solo setup's look and the win reward per difficulty; a screenshot. The ✕ closes the panel
(checked in a later playtest, with the pointer over it first).

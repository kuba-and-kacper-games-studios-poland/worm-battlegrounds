---
title: "Play Solo opens at the bottom centre, and the board slides away for it"
date: 2026-11-12
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** SOLO VS BOTS opens the Play Solo panel at the bottom centre of the screen (same height as before;
it used to hang from the bottom left beside Party). The lobby's ACTIVE LOBBIES row and the SOLO VS BOTS and CUSTOM
buttons no longer vanish at once: they slide down off the screen (0.3 s), and slide back up (0.35 s, with a small
overshoot) when the panel closes. The waiting room, after joining a public match, uses the same slide and keeps its
place beside Party.

**Where.** `U_Setup`'s AnchorPoint 0.5, 1 at 50 % across, 97.8 % down in the MatchBoard gui; Board's `_slidePlay`;
MatchBoard settings `PLAY_SLIDE_MARGIN` (0.05), `PLAY_OUT_TWEENINFO`, `PLAY_IN_TWEENINFO`. Supersedes the panel
position in 2026-11-12-play-solo-panel; the rest of that entry holds.

**How to check.** In the lobby press SOLO VS BOTS: the board slides down and the panel shows at the bottom centre;
press ✕ and the board slides back.

**For the wiki.** Lobby: where the setup panel opens, and the board making room for it.

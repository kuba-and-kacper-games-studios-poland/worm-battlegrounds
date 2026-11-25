---
title: "After the tutorial, the lobby's JOIN buttons glow to point at public matches"
date: 2026-11-25
status: open
kind: added
pages: ["Tutorial", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/Spotlight.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** The owner: "a hint tip on the screen, something subtle and professional, that tells player that he
can join the public matches... shouldnt be annoying and should disable after a while", then "maybe the JOIN buttons
glowing - now players might try to click the PUBLIC MATCHES text". Once the tutorial is done, 3 seconds after each
arrival in the lobby every JOIN on the board glows, pulsing warm yellow, and one small line, "Hit JOIN to play with
other players!", stands beside the PUBLIC MATCHES title, with no arrow. It shows for 12 seconds, hides under any
window, and never shows again once the player has played 2 matches (their `MatchesPlayed`, the tutorial's counting).

**Where.** Tutorial's `PUBLIC_HINT`, `PUBLIC_GLOW_TRANSPARENCY` ({0, 0.55}), `PUBLIC_GLOW_RATE` (4),
`PUBLIC_HINT_DELAY` (3), `PUBLIC_HINT_SECONDS` (12), `PUBLIC_HINT_MATCHES` (2), `BOARD_GUI_NAME`; LobbyHints'
`_tickPublic`, `_stopPublic`, `_setJoinGlow`; Spotlight's `"Beside"` placement; the MatchBoard gui's `S_Glow` behind
each row's `S_Join`.

**Checked.** In Studio, with the profile's `MatchesPlayed` set to 0 on the client: 3 s after the lobby showed, the line
stood beside PUBLIC MATCHES and every JOIN wore a bright pale-yellow rim (JOIN's own picture stretched 1.12 × 1.25
behind it), pulsing. A soft round glow was tried first and cut off by the board's row, which clips above and below.

**How to check.** On a profile with the tutorial done and fewer than 2 matches played, open the lobby: after 3 s the
JOINs pulse and the line shows beside the title for 12 s.

**For the wiki.** Tutorial (what comes after it) or Lobby: a line about the hint and when it stops.

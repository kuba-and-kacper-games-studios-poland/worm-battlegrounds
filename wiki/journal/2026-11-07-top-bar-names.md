---
title: "The match's top bar reads Leave game and Mute music"
date: 2026-11-07
status: open
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The top bar buttons take the studio's wiki names: "Leave" is "Leave game", "Music" is "Mute music".
Leave game still asks first ("Leave the match? Your snail will be knocked out."), so nobody leaves by a slip.

**Where.** MatchHud's `LEAVE_TEXT` and `MUSIC_TEXT`.

**How to check.** In a match, the top-left buttons read Leave game and Mute music (seen in Studio 2026-11-07).

**For the wiki.** Match screen → Top bar: the button names (the question before leaving stays).

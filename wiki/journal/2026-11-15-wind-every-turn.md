---
title: "The wind changes every turn, never the same twice in a row"
date: 2026-11-15
status: open
kind: changed
pages: ["Wind", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** The owner, after the wind stayed at −8 for three turns: "fix it so the wind power changes every
turn". Match rolled the wind once every snail in play had played on it (a whole round, the testers' 2026-11-13 rule);
now it rolls a new one as each turn starts, and rolls again while it matches the turn before, so it always changes.
The odds are unchanged (`WIND_WEIGHTS`, ±10 about 1%, either side at even odds), and the HUD's number flashes and
Atmosphere's gust plays on every turn now.

**Where.** `Module._rollWind()` in `Match/Scripts/Server/Turns.lua` (the `windPlayed` table is gone); the `Wind`
attribute on the match folder.

**How to check.** Watch the HUD's wind over several turns: it's different each turn. Tested in Studio on the Match
map: −7, 2, 0, −1, −2, 0, 6 over seven turns.

**For the wiki.** The wind's page and the match screen: it changes every turn, not every round. The bots' PC gym
(`Bots/Scripts/Server/Sim.lua`) still holds the wind for a round, with even odds: only training sees it, and it can
follow Match's rule when the bots are next retrained. Supersedes the "holds for a whole round" part of
`2026-11-13`'s wind entries; the weights still hold.

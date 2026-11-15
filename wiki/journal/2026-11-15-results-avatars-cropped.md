---
title: "Match over: the players' pictures keep their shape (were squashed)"
date: 2026-11-15
status: open
kind: fixed
pages: ["Match over"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/init.lua
---

**What changed.** On the MATCH OVER screen, each card's picture (an avatar's headshot, or the bot picture) was
stretched to its box, and the cards narrow when more than four players share the row (MatchHud's
`RESULTS_FIT_PLACINGS`), so with five or more the faces were squashed thin. The picture (`PREFAB | Placing` ›
`S_Avatar`) is now cropped (`ScaleType.Crop`): it keeps its shape and fills its box, its sides cut a little on narrow
cards.

**Where.** The Results gui's `PREFAB | Placing` › `S_Avatar`; exported to StarterGui (`PreventClosing` set again).

**How to check.** A match with six players: every face on the results cards looks round, not squashed.

**For the wiki.** Nothing to change unless the match over page shows a screenshot.

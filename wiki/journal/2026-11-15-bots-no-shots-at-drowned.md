---
title: "Bots no longer shoot where a snail just drowned"
date: 2026-11-15
status: open
kind: fixed
pages: ["Match modules", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
---

**What changed.** The owner: "sometimes they shoot after the enemy is dead in the last place he was… water rises,
someone dies and in that same turn bot shoots there". Sudden death raises the sea at the start of a turn
(`Turns.RunTurn`, `I.Arena.RaiseLiquid`); a snail it drowns is still `Alive` for a moment, so the bot planned on it
and fired at its last spot. Now the brain leaves out snails already in the open sea or past the bounds (Arena's
`GetHazard`), and the bot checks its target again after it thinks, after it walks and after it aims: when it's gone
(knocked out, or in the sea) it plans again from where it stands, once more if that happens while it aims.

**Where.** `Brain._getLiving` (used by `GetPlan` and `GetRetreat`); `Server.TakeTurn`, `_isGone`, `_planAgain`.

**How to check.** In a live Studio match, after a snail went out no bot fired at its spot (every later shot's
target was alive). The sudden-death case itself wasn't seen in a test match.

**For the wiki.** Bots: they aim again when their target goes out.
